/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
part of '../protocol.dart';

enum MockMessageQueryType {
  server,
  phone,
  email,
}

@JsonSerializable()
class MockMessageQuery {
  MockMessageQueryType queryType;
  String? email;
  String? phone;

  MockMessageQuery({
    required this.queryType,
    this.email,
    this.phone,
  });

  factory MockMessageQuery.fromJson(Map<String, dynamic> json) =>
      _$MockMessageQueryFromJson(json);
  Map<String, dynamic> toJson() => _$MockMessageQueryToJson(this);
}

@JsonSerializable()
class QueryMockMessageCommand {
  List<MockMessageQuery> queryList = [];
  QueryMockMessageCommand({
    required this.queryList,
  });

  factory QueryMockMessageCommand.fromJson(Map<String, dynamic> json) =>
      _$QueryMockMessageCommandFromJson(json);
  Map<String, dynamic> toJson() => _$QueryMockMessageCommandToJson(this);
}

enum NotificationType {
  mockMessageForEmail,
  mockMessageForPhone,
}

@JsonSerializable()
class NotificationSpec {
  NotificationType type;
  String? email;
  String? phone;
  int id;
  NotificationSpec({
    required this.id,
    required this.type,
    this.email,
    this.phone,
  });
  factory NotificationSpec.fromJson(Map<String, dynamic> json) =>
      _$NotificationSpecFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationSpecToJson(this);
}

@JsonSerializable()
class WaitForNotificationCommand {
  List<NotificationSpec> waitList;
  int waitSeconds;
  WaitForNotificationCommand({
    required this.waitList,
    required this.waitSeconds,
  });
  factory WaitForNotificationCommand.fromJson(Map<String, dynamic> json) =>
      _$WaitForNotificationCommandFromJson(json);
  Map<String, dynamic> toJson() => _$WaitForNotificationCommandToJson(this);
}

@JsonSerializable()
class WaitForNotificationResponse {
  List<int> eventfulIds;
  WaitForNotificationResponse({
    required this.eventfulIds
  });
  factory WaitForNotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$WaitForNotificationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$WaitForNotificationResponseToJson(this);
}

@JsonSerializable()
class QueryMockMessageResponse {
  List<MockMessage> result;

  QueryMockMessageResponse({
    required this.result
  });

  factory QueryMockMessageResponse.fromJson(Map<String, dynamic> json) =>
      _$QueryMockMessageResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QueryMockMessageResponseToJson(this);
}

@JsonSerializable()
class UpdateMockMessageCommand {
  int? idToDelete;
  UpdateMockMessageCommand({this.idToDelete});

  factory UpdateMockMessageCommand.fromJson(Map<String, dynamic> json) =>
      _$UpdateMockMessageCommandFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateMockMessageCommandToJson(this);
}

enum MockMessageType {
  email,
  sms,
}

@JsonSerializable()
class MockMessage {
  MockMessageType type;
  int? id;
  String? email;
  String? subject;
  String? phone;
  DateTime time;
  String? content;
  String? authKey;
  String? otpCode;
  bool? read;

  MockMessage({
    required this.type,
    this.email,
    this.subject,
    this.phone,
    this.content,
    this.authKey,
    this.otpCode,
    required this.time
  });
  factory MockMessage.fromJson(Map<String, dynamic> json) =>
      _$MockMessageFromJson(json);
  Map<String, dynamic> toJson() => _$MockMessageToJson(this);
}

