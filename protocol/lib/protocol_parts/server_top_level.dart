/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
part of '../protocol.dart';

@JsonSerializable()
class ServerCommand {
  ChannelContext? channel;
  AdminCommand? adminCommand;
  GetPropCommand? getPropCommand;
  UpdatePropCommand? updatePropCommand;
  LoginCommand? loginCommand;
  ChangePasswordCommand? changePasswordCommand;
  UpdateStoreCommand? updateStoreCommand;
  QueryStoreCommand? queryStoreCommand;
  UpdateUserCommand? updateUserCommand;
  QueryUserCommand? queryUserCommand;
  UpdateGuestCommand? updateGuestCommand;
  QueryGuestCommand? queryGuestCommand;
  UpdateTransactionCommand? updateTransactionCommand;
  QueryTransactionCommand? queryTransactionCommand;
  ResetPasswordCommand? resetPasswordCommand;
  QueryMockMessageCommand? queryMockMessageCommand;
  WaitForNotificationCommand? waitForNotificationCommand;
  RegisterAccountCommand? registerAccountCommand;
  BindAccountCommand? bindAccountCommand;
  GuestLoginCommand? guestLoginCommand;
  UpdateRedeemPolicyCommand? updateRedeemPolicyCommand;
  QueryRedeemPolicyCommand? queryRedeemPolicyCommand;
  QueryGuestSuppInfoCommand? queryGuestSuppInfoCommand;
  UpdateGuestSuppInfoCommand? updateGuestSuppInfoCommand;
  AddUserToStoreCommand? addUserToStoreCommand;
  QueryGuestInfoCommand? queryGuestInfoCommand;
  GenerateCodeCommand? generateCodeCommand;
  RedeemForCodeCommand? redeemForCodeCommand;
  UpdateMockMessageCommand? updateMockMessageCommand;

  ServerCommand({
    this.queryUserCommand,
    this.updateUserCommand,
    this.resetPasswordCommand,
    this.queryMockMessageCommand,
    this.waitForNotificationCommand,
    this.updateStoreCommand,
    this.updateGuestCommand,
    this.registerAccountCommand,
    this.bindAccountCommand,
    this.guestLoginCommand,
    this.updateRedeemPolicyCommand,
    this.queryRedeemPolicyCommand,
    this.queryGuestSuppInfoCommand,
    this.updateGuestSuppInfoCommand,
    this.queryStoreCommand,
    this.queryTransactionCommand,
    this.addUserToStoreCommand,
    this.updateTransactionCommand,
    this.queryGuestCommand,
    this.queryGuestInfoCommand,
    this.generateCodeCommand,
    this.redeemForCodeCommand,
    this.updateMockMessageCommand,
    this.changePasswordCommand,
  });

  factory ServerCommand.fromJson(Map<String, dynamic> json) =>
      _$ServerCommandFromJson(json);
  Map<String, dynamic> toJson() => _$ServerCommandToJson(this);
}

@JsonSerializable()
class ServerResponse {
  ServerResponseType type;
  ServerResponseCode? code;
  GetPropResult? getPropResult;
  LoginResponse? loginResponse;
  UpdateRecordResponse? updateRecordResponse;
  QueryStoreResponse? queryStoreResponse;
  QueryUserResponse? queryUserResponse;
  QueryGuestResponse? queryGuestResponse;
  QueryTransactionResponse? queryTransactionResponse;
  QueryMockMessageResponse? queryMockMessageResponse;
  ResetPasswordResponse? resetPasswordResponse;
  WaitForNotificationResponse? waitForNotificationResponse;
  BindAccountResponse? bindAccountResponse;
  GuestLoginResponse? guestLoginResponse;
  QueryRedeemPolicyResponse? queryRedeemPolicyResponse;
  QueryGuestSuppInfoResponse? queryGuestSuppInfoResponse;
  QueryGuestInfoResponse? queryGuestInfoResponse;
  GenerateCodeResponse? generateCodeResponse;

  ServerResponse({required this.type, this.code});
  factory ServerResponse.fromJson(Map<String, dynamic> json) =>
      _$ServerResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ServerResponseToJson(this);
}

@JsonSerializable()
class CheckDatabase {
  CheckDatabase();

  factory CheckDatabase.fromJson(Map<String, dynamic> json) =>
      _$CheckDatabaseFromJson(json);
  Map<String, dynamic> toJson() => _$CheckDatabaseToJson(this);
}

@JsonSerializable()
class AdminCommand {
  CheckDatabase? checkDatabase;

  AdminCommand();

  factory AdminCommand.fromJson(Map<String, dynamic> json) =>
      _$AdminCommandFromJson(json);
  Map<String, dynamic> toJson() => _$AdminCommandToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DbPropValue {
  String name;
  DbPropOfSetup? setup;

  DbPropValue({required this.name, this.setup});

  factory DbPropValue.fromJson(Map<String, dynamic> json) =>
      _$DbPropValueFromJson(json);
  Map<String, dynamic> toJson() => _$DbPropValueToJson(this);

  static DbPropValue? fromJsonOrNull(var json) {
    DbPropValue? prop;
    if (json != null) {
      prop = DbPropValue.fromJson(json);
    }
    return prop;
  }
}

@JsonSerializable()
class DbPropOfSetup {
  String? rootUser;

  DbPropOfSetup({this.rootUser});

  factory DbPropOfSetup.fromJson(Map<String, dynamic> json) =>
      _$DbPropOfSetupFromJson(json);
  Map<String, dynamic> toJson() => _$DbPropOfSetupToJson(this);
}

@JsonSerializable()
class UpdatePropCommand {
  DbPropValue prop;
  UpdatePropCommand(this.prop);

  factory UpdatePropCommand.fromJson(Map<String, dynamic> json) =>
      _$UpdatePropCommandFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePropCommandToJson(this);
}

@JsonSerializable()
class GetPropCommand {
  String name;
  GetPropCommand(this.name);
  factory GetPropCommand.fromJson(Map<String, dynamic> json) =>
      _$GetPropCommandFromJson(json);
  Map<String, dynamic> toJson() => _$GetPropCommandToJson(this);
}

@JsonSerializable()
class GetPropResult {
  DbPropValue? prop;
  GetPropResult(this.prop);
  factory GetPropResult.fromJson(Map<String, dynamic> json) =>
      _$GetPropResultFromJson(json);
  Map<String, dynamic> toJson() => _$GetPropResultToJson(this);
}

@JsonSerializable()
class UpdateRecordResponse {
  int? newId;
  UpdateRecordResponse({this.newId});
  factory UpdateRecordResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateRecordResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateRecordResponseToJson(this);
}

