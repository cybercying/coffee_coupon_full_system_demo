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
class GuestLoginCommand {
  String phone;
  String actuatedHashedPassword;
  DateTime time;
  GuestLoginCommand({
    required this.phone,
    required this.actuatedHashedPassword,
    required this.time,
  });
  factory GuestLoginCommand.fromJson(Map<String, dynamic> json) =>
      _$GuestLoginCommandFromJson(json);
  Map<String, dynamic> toJson() => _$GuestLoginCommandToJson(this);
}

@JsonSerializable()
class GuestLoginResponse {
  int guestId;
  ChannelContext channel;
  GenGuest loggedInGuest;
  GuestLoginResponse({
    required this.guestId,
    required this.channel,
    required this.loggedInGuest
  });
  factory GuestLoginResponse.fromJson(Map<String, dynamic> json) =>
      _$GuestLoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GuestLoginResponseToJson(this);
}

@JsonSerializable()
class QueryGuestCommand {
  int? guestId;
  GenGuest? guestQueryCriteria;
  int? managingStoreId;
  QueryGuestCommand({this.guestQueryCriteria, this.guestId, this.managingStoreId});
  factory QueryGuestCommand.fromJson(Map<String, dynamic> json) =>
      _$QueryGuestCommandFromJson(json);
  Map<String, dynamic> toJson() => _$QueryGuestCommandToJson(this);
}

@JsonSerializable()
class QueryGuestResponse {
  List<GenGuest> result;
  QueryGuestResponse({this.result = const[]});
  factory QueryGuestResponse.fromJson(Map<String, dynamic> json) =>
      _$QueryGuestResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QueryGuestResponseToJson(this);
}

@JsonSerializable()
class UpdateGuestCommand {
  int? guestIdToDelete;
  GenGuest? guest;
  bool? assignPassword;
  UpdateGuestCommand({
    this.guestIdToDelete,
    this.guest,
    this.assignPassword,
  });
  factory UpdateGuestCommand.fromJson(Map<String, dynamic> json) =>
      _$UpdateGuestCommandFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateGuestCommandToJson(this);
}

@JsonSerializable()
class QueryGuestSuppInfoCommand {
  QueryGuestSuppInfoCommand();
  factory QueryGuestSuppInfoCommand.fromJson(Map<String, dynamic> json) =>
      _$QueryGuestSuppInfoCommandFromJson(json);
  Map<String, dynamic> toJson() => _$QueryGuestSuppInfoCommandToJson(this);
}

@JsonSerializable()
class QueryGuestSuppInfoResponse {
  GuestSuppInfo? guestSuppInfo;
  QueryGuestSuppInfoResponse({this.guestSuppInfo});
  factory QueryGuestSuppInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$QueryGuestSuppInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QueryGuestSuppInfoResponseToJson(this);
}

@JsonSerializable()
class UpdateGuestSuppInfoCommand {
  GuestSuppInfo guestSuppInfo;
  UpdateGuestSuppInfoCommand({required this.guestSuppInfo});
  factory UpdateGuestSuppInfoCommand.fromJson(Map<String, dynamic> json) =>
      _$UpdateGuestSuppInfoCommandFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateGuestSuppInfoCommandToJson(this);
}

@JsonSerializable()
class QueryGuestInfoCommand {
  QueryGuestInfoCommand();
  factory QueryGuestInfoCommand.fromJson(Map<String, dynamic> json) =>
      _$QueryGuestInfoCommandFromJson(json);
  Map<String, dynamic> toJson() => _$QueryGuestInfoCommandToJson(this);
}

@JsonSerializable()
class QueryGuestInfoResponse {
  GenGuest? guest;
  int? pointsRemaining;
  QueryGuestInfoResponse({this.guest, this.pointsRemaining});
  factory QueryGuestInfoResponse.fromJson(Map<String, dynamic> json) =>
      _$QueryGuestInfoResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QueryGuestInfoResponseToJson(this);
}

enum GuestStatus {
  normal,
  suspended,
}

enum Gender {
  male,
  female,
  unspecified,
}

@JsonSerializable()
class GuestSuppInfo {
  int guestId;
  List<int> favoritePolicyIds;
  GuestSuppInfo({required this.guestId, this.favoritePolicyIds = const[]});
  factory GuestSuppInfo.fromJson(Map<String, dynamic> json) =>
      _$GuestSuppInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GuestSuppInfoToJson(this);
}

@JsonSerializable()
class GenGuest {
  int? guestId;
  String fullName;
  String phone;
  Gender gender;
  DateTime? birthday;
  String? email;
  GuestStatus status;
  DateTime? created;
  DateTime? lastUpdated;
  DateTime? lastLoggedIn;
  String? hashedPassword;
  String? plainPassword; // only used in internal test data

  GenGuest({
    this.guestId,
    required this.fullName,
    required this.phone,
    this.birthday,
    required this.gender,
    this.email,
    this.status = GuestStatus.normal,
    this.hashedPassword,
    this.plainPassword
  });
  factory GenGuest.fromJson(Map<String, dynamic> json) =>
      _$GenGuestFromJson(json);
  Map<String, dynamic> toJson() => _$GenGuestToJson(this);

  factory GenGuest.empty() {
    return GenGuest(fullName: '', phone: '', gender: Gender.male);
  }

  GenGuest summary() {
    return GenGuest(guestId: guestId, fullName: fullName, email: email, phone: phone, gender: gender, birthday: birthday);
  }
}
