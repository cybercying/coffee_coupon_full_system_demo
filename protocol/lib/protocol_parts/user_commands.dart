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
class LoginCommand {
  String email;
  String actuatedHashedPassword;
  DateTime time;
  LoginCommand({required this.email, required this.actuatedHashedPassword, required this.time});
  factory LoginCommand.fromJson(Map<String, dynamic> json) =>
      _$LoginCommandFromJson(json);
  Map<String, dynamic> toJson() => _$LoginCommandToJson(this);
}

@JsonSerializable()
class LoginResponse {
  int uid;
  ChannelContext channel;
  GenUser? loggedInUser;
  LoginResponse(this.uid, this.channel);
  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class QueryUserCommand {
  int? uid;
  GenUser? userQueryCriteria;
  int? managingStoreId;
  bool? queryStoreInfo;
  QueryUserCommand({this.userQueryCriteria, this.uid, this.managingStoreId, this.queryStoreInfo});
  factory QueryUserCommand.fromJson(Map<String, dynamic> json) =>
      _$QueryUserCommandFromJson(json);
  Map<String, dynamic> toJson() => _$QueryUserCommandToJson(this);
}

@JsonSerializable()
class QueryUserResponse {
  List<GenUser> result;
  List<GenStore> stores;
  QueryUserResponse({this.result = const[], this.stores = const[]});
  factory QueryUserResponse.fromJson(Map<String, dynamic> json) =>
      _$QueryUserResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QueryUserResponseToJson(this);
}

@JsonSerializable()
class UpdateUserCommand {
  int? userIdToDelete;
  GenUser? user;
  bool? assignPassword;
  int? managingStoreId;
  UpdateUserCommand({this.userIdToDelete, this.user, this.assignPassword, this.managingStoreId});
  factory UpdateUserCommand.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserCommandFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserCommandToJson(this);
}

@JsonSerializable()
class ChangePasswordCommand {
  String oldPasswordHash, newPasswordHash;
  ChangePasswordCommand(this.oldPasswordHash, this.newPasswordHash);
  factory ChangePasswordCommand.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordCommandFromJson(json);
  Map<String, dynamic> toJson() => _$ChangePasswordCommandToJson(this);
}

enum UserStatus {
  normal,
  suspended,
}

@JsonSerializable()
class GenUser {
  int? uid;
  String email;
  String fullName;
  String? hashedPassword;
  DateTime? created;
  DateTime? lastUpdated;
  DateTime? lastLoggedIn;
  bool fAdmin;
  String phone;
  List<StoreUser> stores = [];
  UserStatus status;
  String? plainPassword; // only used in internal test data

  GenUser(
      {this.uid,
        required this.email,
        required this.fullName,
        required this.phone,
        this.created,
        this.lastUpdated,
        this.fAdmin = false,
        this.lastLoggedIn,
        this.hashedPassword,
        this.status = UserStatus.normal,
        this.plainPassword});

  GenUser copyWith() {
    return GenUser.fromJson(toJson());
  }

  GenUser summary() {
    return GenUser(uid: uid, fullName: fullName, email: email, phone: phone);
  }

  factory GenUser.empty() {
    return GenUser(email: '', fullName: '', phone: '');
  }

  factory GenUser.fromJson(Map<String, dynamic> json) =>
      _$GenUserFromJson(json);
  Map<String, dynamic> toJson() => _$GenUserToJson(this);
}

enum StoreStatus {
  normal,
  suspended,
}

enum UserRoleAtStore {
  manager,
  staff,
}

