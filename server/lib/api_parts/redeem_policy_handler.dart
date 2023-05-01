/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
part of '../db_util.dart';

class RedeemPolicyApiHandler extends ApiHandler {
  static late Box _redeemPolicyBox;
  static late Box _redeemCodeBox;

  static Future<void> staticApiHandlerInit() async {
    _redeemPolicyBox = await Hive.openBox('gen_redeemPolicy');
    _redeemCodeBox = await Hive.openBox('gen_redeemCode');
    DbUtil.openedBoxes.addAll([_redeemPolicyBox, _redeemCodeBox]);
  }

  GenRedeemPolicy? getRedeemPolicyById(int policyId) {
    var json = SharedApi.fixHiveJsonType(_redeemPolicyBox.get(policyId));
    if (json != null) {
      return GenRedeemPolicy.fromJson(json);
    }
    return null;
  }

  Future<void> updateRedeemPolicy(GenRedeemPolicy redeemPolicy) async {
    redeemPolicy.policyId ??= du.generateId(_redeemPolicyBox);
    GenRedeemPolicy? old = getRedeemPolicyById(redeemPolicy.policyId!);
    DateTime now = DateTime.now();
    if (old!=null) {
      redeemPolicy.created = old.created;
    }
    else {
      redeemPolicy.created = now;
    }
    redeemPolicy.lastUpdated = now;
    await du.logAndPut('Updating RedeemPolicy', _redeemPolicyBox, redeemPolicy.policyId, redeemPolicy.toJson());
  }

  Future<void> deleteRedeemPolicy(int policyIdToDelete) async {
    GenRedeemPolicy? old = getRedeemPolicyById(policyIdToDelete);
    if (old != null) {
      await du.logAndDelete('Deleting RedeemPolicy', _redeemPolicyBox, policyIdToDelete);
    }

  }

  Future<void> handleUpdateRedeemPolicyCommand(UpdateRedeemPolicyCommand updateRedeemPolicyCommand, ServerResponse resp, UserContext context) async {
    if (!context.loggedIn!.fAdmin) {
      throw ServerApiException.error(ServerResponseCode.insufficientPrivilegeError);
    }
    var redeemPolicy = updateRedeemPolicyCommand.redeemPolicy;
    if (redeemPolicy != null) {
      await updateRedeemPolicy(redeemPolicy);
      resp.updateRecordResponse = UpdateRecordResponse(newId: redeemPolicy.policyId);
    }
    else {
      var policyIdToDelete = updateRedeemPolicyCommand.policyIdToDelete;
      if (policyIdToDelete != null) {
        await deleteRedeemPolicy(policyIdToDelete);
      }
    }
  }

  bool fitsQueryCriteria(GenRedeemPolicy redeemPolicy, GenRedeemPolicy? redeemPolicyQueryCriteria) {
    if (redeemPolicyQueryCriteria == null) {
      return true;
    }
    if (redeemPolicyQueryCriteria.title.isNotEmpty) {
      if (!redeemPolicy.title.contains(redeemPolicyQueryCriteria.title)) {
        return false;
      }
    }
    if (redeemPolicyQueryCriteria.description.isNotEmpty) {
      if (!redeemPolicy.description.contains(redeemPolicyQueryCriteria.description)) {
        return false;
      }
    }
    return true;
  }

  Future<void> handleQueryRedeemPolicyCommand(QueryRedeemPolicyCommand queryRedeemPolicyCommand, ServerResponse resp) async {
    var policyId = queryRedeemPolicyCommand.policyId;
    var redeemPolicyQueryCriteria = queryRedeemPolicyCommand.redeemPolicyQueryCriteria;
    if (policyId!=null) {
      var redeemPolicy = getRedeemPolicyById(policyId);
      if (redeemPolicy != null) {
        resp.queryRedeemPolicyResponse = QueryRedeemPolicyResponse(result: [redeemPolicy]);
      }
    }
    else {
      var list = [for(var json in _redeemPolicyBox.values)
        GenRedeemPolicy.fromJson(SharedApi.fixHiveJsonType(json))
      ];
      if (redeemPolicyQueryCriteria != null) {
        list = list.where((redeemPolicy) => fitsQueryCriteria(redeemPolicy, redeemPolicyQueryCriteria))
            .toList();
      }
      list.sort((a,b)=>a.created!.compareTo(b.created!));
      resp.queryRedeemPolicyResponse = QueryRedeemPolicyResponse(result: list);
    }
  }

  @override
  Future<bool> handleApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    final updateRedeemPolicyCommand = cmd.updateRedeemPolicyCommand;
    final queryRedeemPolicyCommand = cmd.queryRedeemPolicyCommand;
    final redeemForCodeCommand = cmd.redeemForCodeCommand;
    if (updateRedeemPolicyCommand != null) {
      await handleUpdateRedeemPolicyCommand(updateRedeemPolicyCommand, resp, context);
    }
    else if (queryRedeemPolicyCommand != null) {
      await handleQueryRedeemPolicyCommand(queryRedeemPolicyCommand, resp);
    }
    else if (redeemForCodeCommand != null) {
      await handleRedeemForCodeCommand(redeemForCodeCommand, resp, context);
    }
    else {
      return false;
    }
    return true;
  }

  @override
  Future<bool> handleGuestApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    final queryRedeemPolicyCommand = cmd.queryRedeemPolicyCommand;
    final generateCodeCommand = cmd.generateCodeCommand;
    if (queryRedeemPolicyCommand != null) {
      await handleQueryRedeemPolicyCommand(queryRedeemPolicyCommand, resp);
    }
    else if (generateCodeCommand != null) {
      await handleGuestGenerateCodeCommand(generateCodeCommand, resp, context);
    }
    else {
      return false;
    }
    return true;
  }

  Future<void> handleGuestGenerateCodeCommand(GenerateCodeCommand generateCodeCommand, ServerResponse resp, UserContext context) async {
    var policyId = generateCodeCommand.generateForRedeemPolicyId;
    if (policyId == null) {
      throw ServerApiException.error(ServerResponseCode.designatedTargetNotExist);
    }
    var redeemPolicy = getRedeemPolicyById(policyId);
    if (redeemPolicy == null) {
      throw ServerApiException.error(ServerResponseCode.designatedTargetNotExist);
    }
    var code = du.generateRandomString(20);
    var gr = GenRedeemCode(
        code: code,
        guestId: context.loggedInGuest!.guestId,
        policyId: policyId
    );
    await du.logAndPut('Updating redeemCode', _redeemCodeBox, code, gr.toJson());
    resp.generateCodeResponse = GenerateCodeResponse(code: code);
  }

  Future<void> handleRedeemForCodeCommand(RedeemForCodeCommand redeemForCodeCommand, ServerResponse resp, UserContext context) async {
    var code = redeemForCodeCommand.code;
    var json = _redeemCodeBox.get(code);
    if (json == null) {
      throw ServerApiException.error(ServerResponseCode.invalidRedeemCode);
    }
    var gr = GenRedeemCode.fromJson(json);
    await performRedeem(gr.policyId, gr.guestId, context.loggedIn!.uid, redeemForCodeCommand.managingStoreId);
  }

  Future<void> performRedeem(int policyId, int guestId, int uid, int storeId) async {
    var policy = getRedeemPolicyById(policyId);
    var guest = du._guestApiHandler.getGuestById(guestId);
    if (policy == null || guest == null) {
      throw ServerApiException.error(ServerResponseCode.designatedTargetNotExist);
    }
    var list = du._transactionApiHandler.getTransactionListByGuestId(guestId);
    int points = 0;
    for(var t in list) {
      points += t.points;
    }
    if (points < policy.pointsRequired) {
      throw ServerApiException.error(ServerResponseCode.notEnoughPoints);
    }
    DateTime now = DateTime.now();
    var xtran = GenTransaction(
        type: TransactionType.pointsRedeem,
        points: -policy.pointsRequired,
        policyId: policy.policyId,
        storeId: storeId,
        time: now,
        guestId: guestId,
        uid: uid
    );
    du._transactionApiHandler.updateTransaction(xtran);
  }
}

