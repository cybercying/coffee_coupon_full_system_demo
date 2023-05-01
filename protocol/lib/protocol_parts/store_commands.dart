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
class QueryStoreCommand {
  int? storeId;
  GenStore? storeQueryCriteria;
  bool? queryUserInfo;
  QueryStoreCommand({this.storeQueryCriteria, this.storeId, this.queryUserInfo});
  factory QueryStoreCommand.fromJson(Map<String, dynamic> json) =>
      _$QueryStoreCommandFromJson(json);
  Map<String, dynamic> toJson() => _$QueryStoreCommandToJson(this);
}

@JsonSerializable()
class QueryStoreResponse {
  List<GenStore> result;
  List<GenUser> linkedUsers;
  QueryStoreResponse({this.result = const[], this.linkedUsers = const[]});
  factory QueryStoreResponse.fromJson(Map<String, dynamic> json) =>
      _$QueryStoreResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QueryStoreResponseToJson(this);
}

@JsonSerializable()
class UpdateStoreCommand {
  int? storeIdToDelete;
  GenStore? store;
  UpdateStoreCommand({this.storeIdToDelete, this.store});
  factory UpdateStoreCommand.fromJson(Map<String, dynamic> json) =>
      _$UpdateStoreCommandFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateStoreCommandToJson(this);
}

@JsonSerializable()
class AddUserToStoreCommand {
  String email;
  int storeId;
  UserRoleAtStore role;
  AddUserToStoreCommand({
    required this.email,
    required this.storeId,
    required this.role,
  });
  factory AddUserToStoreCommand.fromJson(Map<String, dynamic> json) =>
      _$AddUserToStoreCommandFromJson(json);
  Map<String, dynamic> toJson() => _$AddUserToStoreCommandToJson(this);
}

@JsonSerializable()
class StoreUser {
  int? storeId;
  int uid;
  UserRoleAtStore role;
  StoreUser({this.storeId, required this.uid, required this.role});
  factory StoreUser.fromJson(Map<String, dynamic> json) =>
      _$StoreUserFromJson(json);
  Map<String, dynamic> toJson() => _$StoreUserToJson(this);
}

@JsonSerializable()
class GenStore {
  int? storeId;
  String name;
  String address;
  String phone;
  StoreStatus status;
  List<StoreUser> users;
  bool? usersChanged;
  String? imageUrl;
  GenStore({
    this.storeId,
    required this.name,
    required this.address,
    required this.phone,
    this.status = StoreStatus.normal,
    this.users = const [],
    this.usersChanged,
    this.imageUrl
  });
  GenStore copyWith() {
    return GenStore.fromJson(toJson());
  }
  factory GenStore.empty() {
    return GenStore(name: '', address: '', phone: '');
  }
  factory GenStore.fromJson(Map<String, dynamic> json) =>
      _$GenStoreFromJson(json);
  Map<String, dynamic> toJson() => _$GenStoreToJson(this);

  GenStore summary() {
    return GenStore(storeId: storeId, name: name, address: address, phone: phone);
  }
}

