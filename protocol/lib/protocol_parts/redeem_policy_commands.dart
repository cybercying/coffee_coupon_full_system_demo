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
class QueryRedeemPolicyCommand {
  int? policyId;
  GenRedeemPolicy? redeemPolicyQueryCriteria;
  QueryRedeemPolicyCommand({this.redeemPolicyQueryCriteria, this.policyId});
  factory QueryRedeemPolicyCommand.fromJson(Map<String, dynamic> json) =>
      _$QueryRedeemPolicyCommandFromJson(json);
  Map<String, dynamic> toJson() => _$QueryRedeemPolicyCommandToJson(this);
}

@JsonSerializable()
class QueryRedeemPolicyResponse {
  List<GenRedeemPolicy> result;
  QueryRedeemPolicyResponse({this.result=const[]});
  factory QueryRedeemPolicyResponse.fromJson(Map<String, dynamic> json) =>
      _$QueryRedeemPolicyResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QueryRedeemPolicyResponseToJson(this);
}

@JsonSerializable()
class UpdateRedeemPolicyCommand {
  int? policyIdToDelete;
  GenRedeemPolicy? redeemPolicy;
  bool? assignPassword;
  UpdateRedeemPolicyCommand({this.policyIdToDelete, this.redeemPolicy, this.assignPassword});
  factory UpdateRedeemPolicyCommand.fromJson(Map<String, dynamic> json) =>
      _$UpdateRedeemPolicyCommandFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateRedeemPolicyCommandToJson(this);
}

@JsonSerializable()
class GenerateCodeCommand {
  int? generateForRedeemPolicyId;
  GenerateCodeCommand({this.generateForRedeemPolicyId});
  factory GenerateCodeCommand.fromJson(Map<String, dynamic> json) =>
      _$GenerateCodeCommandFromJson(json);
  Map<String, dynamic> toJson() => _$GenerateCodeCommandToJson(this);
}

@JsonSerializable()
class GenerateCodeResponse {
  String code;
  GenerateCodeResponse({required this.code});
  factory GenerateCodeResponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateCodeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$GenerateCodeResponseToJson(this);
}

@JsonSerializable()
class RedeemForCodeCommand {
  String code;
  int managingStoreId;
  RedeemForCodeCommand({required this.code, required this.managingStoreId});
  factory RedeemForCodeCommand.fromJson(Map<String, dynamic> json) =>
      _$RedeemForCodeCommandFromJson(json);
  Map<String, dynamic> toJson() => _$RedeemForCodeCommandToJson(this);
}

@JsonSerializable()
class GenRedeemCode {
  String code;
  int guestId;
  int policyId;
  GenRedeemCode({required this.code, required this.guestId, required this.policyId});
  factory GenRedeemCode.fromJson(Map<String, dynamic> json) =>
      _$GenRedeemCodeFromJson(json);
  Map<String, dynamic> toJson() => _$GenRedeemCodeToJson(this);
}

enum RedeemPolicyStatus {
  normal,
  suspended,
}

enum PolicyStoreLimitType {
  notLimited,
  onlyApplicableToListed,
  applicableExceptForListed,
}

@JsonSerializable()
class GenRedeemPolicy {
  int? policyId;
  DateTime? created;
  DateTime? lastUpdated;
  int? createdByUid;
  DateTime? startTime;
  DateTime? endTime;
  String title;
  String description;
  int? perGuestQuota;
  int pointsRequired;
  String? imageUrl;
  RedeemPolicyStatus status;
  PolicyStoreLimitType storeLimitType;
  List<int> storeIds;

  GenRedeemPolicy({
    this.policyId,
    this.created,
    this.createdByUid,
    this.startTime,
    this.endTime,
    required this.title,
    required this.description,
    this.perGuestQuota,
    required this.pointsRequired,
    this.imageUrl,
    this.status = RedeemPolicyStatus.normal,
    this.storeLimitType = PolicyStoreLimitType.notLimited,
    this.storeIds = const []
  });

  factory GenRedeemPolicy.fromJson(Map<String, dynamic> json) =>
      _$GenRedeemPolicyFromJson(json);
  Map<String, dynamic> toJson() => _$GenRedeemPolicyToJson(this);

  factory GenRedeemPolicy.empty() {
    return GenRedeemPolicy(title: '', description: '', pointsRequired: 0);
  }

  GenRedeemPolicy? summary() {
    return GenRedeemPolicy(title: title, description: description, pointsRequired: pointsRequired);
  }
}
