/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
part of '../protocol.dart';

enum IdentityType {
  user,
  guest,
}

enum ResetPasswordType {
  email,
  phone,
}

@JsonSerializable()
class PasswordReassignmentRec {
  IdentityType identityType;
  ResetPasswordType resetPasswordType;
  String? email;
  String? phone;
  String? authKey;
  String? otpCode;
  DateTime? time;
  PasswordReassignmentRec({
    required this.identityType,
    required this.resetPasswordType,
    this.email,
    this.phone});
  factory PasswordReassignmentRec.fromJson(Map<String, dynamic> json) =>
      _$PasswordReassignmentRecFromJson(json);

  Map<String, dynamic> toJson() => _$PasswordReassignmentRecToJson(this);

  String getKey() {
    var key = 't:${identityType.name}';
    if (email != null) {
      key += '|e:$email';
    }
    if (phone != null) {
      key += '|p:$email';
    }
    return key;
  }
}

@JsonSerializable()
class ResetPasswordResponse {
  String? generatedPassword;
  ResetPasswordResponse({
    this.generatedPassword
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordResponseToJson(this);
}

@JsonSerializable()
class AssignPasswordByAdmin {
  String passwordPlain;
  String? userEmail;
  AssignPasswordByAdmin({
    this.userEmail,
    required this.passwordPlain,
  });
  factory AssignPasswordByAdmin.fromJson(Map<String, dynamic> json) =>
      _$AssignPasswordByAdminFromJson(json);
  Map<String, dynamic> toJson() => _$AssignPasswordByAdminToJson(this);
}

@JsonSerializable()
class ResetPasswordCommand {
  PasswordReassignmentRec? passwordReassignment;
  String? enteredOtpCode;
  String? enteredAuthKey;
  AssignPasswordByAdmin? assignPasswordByAdmin;
  ResetPasswordCommand({
    this.passwordReassignment,
    this.enteredAuthKey,
    this.enteredOtpCode,
    this.assignPasswordByAdmin,
  });
  factory ResetPasswordCommand.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordCommandFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordCommandToJson(this);
}

@JsonSerializable()
class RegisterAccountCommand {
  IdentityType type;
  String? phone;
  String? email;
  DateTime? time;
  RegisterAccountCommand({
    required this.type,
    this.phone,
    this.email,
    this.time,
  });
  factory RegisterAccountCommand.fromJson(Map<String, dynamic> json) =>
      _$RegisterAccountCommandFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterAccountCommandToJson(this);
}

enum BindAccountCommandAction {
  query,
  update,
}

@JsonSerializable()
class BindAccountCommand {
  String? enteredOtpCode;
  BindAccountCommandAction action;
  GenGuest? guest;
  BindAccountCommand({
    required this.action,
    this.enteredOtpCode,
    this.guest
  });
  factory BindAccountCommand.fromJson(Map<String, dynamic> json) =>
      _$BindAccountCommandFromJson(json);
  Map<String, dynamic> toJson() => _$BindAccountCommandToJson(this);
}

@JsonSerializable()
class BindAccountResponse {
  GenGuest? guest;
  BindAccountResponse({this.guest});
  factory BindAccountResponse.fromJson(Map<String, dynamic> json) =>
      _$BindAccountResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BindAccountResponseToJson(this);
}

