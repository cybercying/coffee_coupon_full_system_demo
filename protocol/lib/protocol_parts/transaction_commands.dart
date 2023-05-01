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
class QueryTransactionCommand {
  int? xid;
  int? guestId;
  GenTransaction? xtranQueryCriteria;
  int? managingStoreId;
  bool? queryLinkedInfo;
  QueryTransactionCommand({this.xid, this.guestId, this.xtranQueryCriteria, this.managingStoreId, this.queryLinkedInfo});
  factory QueryTransactionCommand.fromJson(Map<String, dynamic> json) =>
      _$QueryTransactionCommandFromJson(json);
  Map<String, dynamic> toJson() => _$QueryTransactionCommandToJson(this);
}

@JsonSerializable()
class QueryTransactionResponse {
  List<GenTransaction> result;
  QueryTransactionResponse({this.result = const[]});
  factory QueryTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$QueryTransactionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QueryTransactionResponseToJson(this);
}

@JsonSerializable()
class UpdateTransactionCommand {
  int? xidToDelete;
  GenTransaction? xtran;
  int? managingStoreId;
  UpdateTransactionCommand({this.xidToDelete, this.xtran, this.managingStoreId});
  factory UpdateTransactionCommand.fromJson(Map<String, dynamic> json) =>
      _$UpdateTransactionCommandFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateTransactionCommandToJson(this);
}

enum TransactionType {
  orderCompleted,
  storeGift,
  pointsRedeem,
}

@JsonSerializable()
class OrderDetails {
  DateTime orderTime;
  String orderContent;
  double amount;
  int storeId;

  OrderDetails({
    required this.orderTime,
    required this.orderContent,
    required this.amount,
    required this.storeId});
  factory OrderDetails.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDetailsToJson(this);
}

@JsonSerializable()
class XtranLinkedInfo {
  GenUser? user;
  GenStore? store;
  GenGuest? guest;
  GenRedeemPolicy? redeemPolicy;
  XtranLinkedInfo({
    this.user,
    this.store,
    this.guest,
    this.redeemPolicy,
  });
  factory XtranLinkedInfo.fromJson(Map<String, dynamic> json) =>
      _$XtranLinkedInfoFromJson(json);
  Map<String, dynamic> toJson() => _$XtranLinkedInfoToJson(this);
}

@JsonSerializable()
class GenTransaction {
  int? xid; // transaction id
  int? uid;
  int? guestId;
  int? storeId;
  DateTime time;
  String? description;
  TransactionType type;
  int points;
  int? policyId; // redeem policy associated with this transaction
  OrderDetails? orderDetails;
  XtranLinkedInfo? linkedInfo;

  GenTransaction({
    this.uid,
    this.guestId,
    this.storeId,
    this.description,
    required this.type,
    required this.points,
    required this.time,
    this.policyId});
  factory GenTransaction.fromJson(Map<String, dynamic> json) =>
      _$GenTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$GenTransactionToJson(this);

  factory GenTransaction.empty({String? description, int? storeId}) {
    return GenTransaction(type: TransactionType.orderCompleted, points: 0, time: DateTime.now(), description: description, storeId: storeId);
  }
}

