/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
part of '../db_util.dart';

class RegisterAccountHandler extends ApiHandler {
  static late Box _otpRegisterBox;

  static Future<void> staticApiHandlerInit() async {
    _otpRegisterBox = await Hive.openBox('otpRegister');
    DbUtil.openedBoxes.addAll([_otpRegisterBox]);
  }

  @override
  Future<bool> handlePreLoginApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    final registerAccountCommand = cmd.registerAccountCommand;
    final bindAccountCommand = cmd.bindAccountCommand;
    if (registerAccountCommand != null && registerAccountCommand.type == IdentityType.guest) {
      await handleRegisterGuestCommand(registerAccountCommand, resp);
    }
    else if (bindAccountCommand != null) {
      await handleBindGuestCommand(bindAccountCommand, resp);
    }
    else {
      return false;
    }
    return true;
  }

  @override
  Future<bool> handleApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    return false;
  }

  int generateUniqueOtpCode() {
    while(true) {
      var otpCode = du.generateOtpCode();
      if (_otpRegisterBox.get(otpCode) == null) {
        return otpCode;
      }
    }
  }

  Future<void> handleRegisterGuestCommand(RegisterAccountCommand registerAccountCommand, ServerResponse resp) async {
    if (registerAccountCommand.phone != null && registerAccountCommand.email != null) {
      throw ServerApiException.error(ServerResponseCode.dataValidationError);
    }
    if (registerAccountCommand.phone == null) {
      throw UnimplementedError();
    }
    DateTime now = DateTime.now();
    String otpCode = '${generateUniqueOtpCode()}';
    registerAccountCommand.time = now;
    await du.logAndPut('Inserting otpRegister', _otpRegisterBox, otpCode, registerAccountCommand.toJson());
    await du._mockMessageHandler.sendMockMessage(MockMessage(
        type: MockMessageType.sms,
        phone: registerAccountCommand.phone,
        content: 'Your account registration OTP code is $otpCode',
        otpCode: otpCode,
        time: now
    ));
  }

  Future<void> handleBindGuestCommand(BindAccountCommand createAccountCommand, ServerResponse resp) async {
    final guest = createAccountCommand.guest;
    final enteredOtpCode = createAccountCommand.enteredOtpCode;
    final action = createAccountCommand.action;
    if (enteredOtpCode == null) {
      throw ServerApiException(type: ServerResponseType.error,
          code: ServerResponseCode.dataValidationError);
    }
    if (action == BindAccountCommandAction.query) {
      var json = SharedApi.fixHiveJsonType(_otpRegisterBox.get(enteredOtpCode));
      if (json == null) {
        throw ServerApiException(type: ServerResponseType.error,
            code: ServerResponseCode.designatedTargetNotExist);
      }
      var raCmd = RegisterAccountCommand.fromJson(json);
      var guest = du._guestApiHandler.getGuestByPhone(raCmd.phone!);
      resp.bindAccountResponse = BindAccountResponse(guest: guest);
    }
    else if (action == BindAccountCommandAction.update) {
      if (guest == null) {
        throw ServerApiException(type: ServerResponseType.error,
            code: ServerResponseCode.dataValidationError);
      }
      if (guest.hashedPassword == null) {
        throw ServerApiException(type: ServerResponseType.error,
            code: ServerResponseCode.dataValidationError);
      }
      var json = SharedApi.fixHiveJsonType(_otpRegisterBox.get(enteredOtpCode));
      if (json == null) {
        throw ServerApiException(type: ServerResponseType.error,
            code: ServerResponseCode.designatedTargetNotExist);
      }
      var raCmd = RegisterAccountCommand.fromJson(json);
      if (raCmd.phone != guest.phone) {
        throw ServerApiException(type: ServerResponseType.error,
            code: ServerResponseCode.illegalOperationForCurrentState);
      }
      DateTime now = DateTime.now();
      if (now.difference(raCmd.time!) > Duration(minutes: 10)) {
        throw ServerApiException(type: ServerResponseType.error,
            code: ServerResponseCode.securityTimeCheckError);
      }
      await du._guestApiHandler.updateGuest(guest, keepPassword: true);
      await _otpRegisterBox.delete(enteredOtpCode);
    }
  }
}

class PasswordReassignHandler extends ApiHandler {
  static late Box _pwdReassignBox;
  static late Box _idxAuthKey;
  static late Box _idxOtpCode;

  static Future<void> staticApiHandlerInit() async {
    _pwdReassignBox = await Hive.openBox('gen_pwdReassign');
    _idxAuthKey = await Hive.openBox('idx_authKey');
    _idxOtpCode = await Hive.openBox('idx_otpCode');
    DbUtil.openedBoxes.addAll([_pwdReassignBox, _idxAuthKey, _idxOtpCode]);
  }

  PasswordReassignmentRec? getPwdReassignByKey(String key) {
    var json = SharedApi.fixHiveJsonType(_pwdReassignBox.get(key));
    if (json != null) {
      return PasswordReassignmentRec.fromJson(json);
    }
    return null;
  }

  Future<void> deleteRecord(PasswordReassignmentRec pwdReassign) async {
    var key = pwdReassign.getKey();
    if (pwdReassign.authKey != null) {
      await _idxAuthKey.delete(pwdReassign.authKey);
    }
    else if (pwdReassign.otpCode != null) {
      await _idxOtpCode.delete(pwdReassign.otpCode);
    }
    await _pwdReassignBox.delete(key);
  }

  Future<void> handleResetPasswordCommand(ResetPasswordCommand cmd, ServerResponse resp, UserContext context, {issuedByAdmin = false}) async {
    final pwdReassign = cmd.passwordReassignment;
    final assignPasswordByAdmin = cmd.assignPasswordByAdmin;
    if (pwdReassign != null) {
      await resetPasswordPhase1(pwdReassign, context);
    }
    else if (cmd.enteredAuthKey != null && cmd.enteredOtpCode == null) {
      await resetPasswordByAuthKey(cmd.enteredAuthKey!, resp);
    }
    else if (cmd.enteredAuthKey == null && cmd.enteredOtpCode != null) {
      await resetPasswordByOtpCode(cmd.enteredOtpCode!, resp);
    }
    else if (assignPasswordByAdmin != null) {
      if (!context.loggedIn!.fAdmin) {
        throw ServerApiException.error(ServerResponseCode.insufficientPrivilegeError);
      }
      var userEmail = assignPasswordByAdmin.userEmail;
      if (userEmail != null) {
        var user  = du._userApiHandler.getUserByEmail(userEmail);
        if (user!=null) {
          user.hashedPassword = SharedApi.encryptedDigest(assignPasswordByAdmin.passwordPlain);
          await du._userApiHandler.updateUser(user, keepPassword: true);
        }
        else {
          throw ServerApiException.error(ServerResponseCode.designatedTargetNotExist);
        }
      }
      else {
        throw UnimplementedError();
      }
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<void> resetPasswordPhase1(PasswordReassignmentRec pwdReassign, UserContext context) async {
    var key = pwdReassign.getKey();
    var old = getPwdReassignByKey(key);
    if (old != null) {
      await deleteRecord(old);
    }
    DateTime now = DateTime.now();
    pwdReassign.time = now;
    if (pwdReassign.resetPasswordType == ResetPasswordType.email) {
      if (pwdReassign.email == null || pwdReassign.phone != null) {
        throw ServerApiException(type: ServerResponseType.error,
            code: ServerResponseCode.dataValidationError);
      }
      pwdReassign.authKey = du.generateRandomString();
      await _idxAuthKey.put(pwdReassign.authKey, key);
      await du._mockMessageHandler.sendMockMessage(
          MockMessage(
              type: MockMessageType.email,
              email: pwdReassign.email,
              subject: 'Reset password',
              content: 'You have requested a password reset, Please use this link to do so: http://example.com/resetPassword?authKey=${pwdReassign
                  .authKey}',
              authKey: pwdReassign.authKey,
              time: now));
    }
    else if (pwdReassign.resetPasswordType == ResetPasswordType.phone) {
      if (!context.loggedIn!.fAdmin) {
        throw ServerApiException(
            type: ServerResponseType.error,
            code: ServerResponseCode.insufficientPrivilegeError
        );
      }
      if (pwdReassign.phone == null || pwdReassign.email != null) {
        throw ServerApiException(type: ServerResponseType.error,
            code: ServerResponseCode.dataValidationError);
      }
      pwdReassign.otpCode = '${du.generateOtpCode()}';
      await _idxOtpCode.put(pwdReassign.otpCode, key);
      await du._mockMessageHandler.sendMockMessage(
          MockMessage(
              type: MockMessageType.sms,
              phone: pwdReassign.phone,
              content: 'Your password reset OTP code is ${pwdReassign.otpCode}',
              otpCode: pwdReassign.otpCode,
              time: now));
    }
    else {
      throw UnimplementedError();
    }
    await _pwdReassignBox.put(key, pwdReassign.toJson());
  }

  @override
  Future<bool> handleApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    final resetPasswordCommand = cmd.resetPasswordCommand;
    if (resetPasswordCommand != null) {
      await handleResetPasswordCommand(resetPasswordCommand, resp, context, issuedByAdmin: true);
    }
    else {
      return false;
    }
    return true;
  }

  Future<void> resetPasswordByAuthKey(String enteredAuthKey, ServerResponse resp) async {
    String? key = _idxAuthKey.get(enteredAuthKey);
    if (key == null) {
      throw ServerApiException.error(ServerResponseCode.resetPasswordFailed);
    }
    var pwdReassign = getPwdReassignByKey(key);
    if (pwdReassign == null || pwdReassign.email == null) {
      throw ServerApiException.error(ServerResponseCode.resetPasswordFailed);
    }
    if (pwdReassign.identityType == IdentityType.user) {
      var user = du._userApiHandler.getUserByEmail(pwdReassign.email!);
      if (user == null) {
        throw ServerApiException.error(ServerResponseCode.resetPasswordFailed);
      }
      var generatedPassword = du.generateRandomString(16);
      user.hashedPassword = SharedApi.encryptedDigest(generatedPassword);
      await du._userApiHandler.updateUser(user, keepPassword: true);
      resp.resetPasswordResponse = ResetPasswordResponse(generatedPassword: generatedPassword);
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<void> resetPasswordByOtpCode(String otpCode, ServerResponse resp) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> handlePreLoginApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    final resetPasswordCommand = cmd.resetPasswordCommand;
    if (resetPasswordCommand != null) {
      await handleResetPasswordCommand(resetPasswordCommand, resp, context);
    }
    else {
      return false;
    }
    return true;
  }
}


