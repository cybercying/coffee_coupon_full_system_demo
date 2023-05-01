/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
part of '../db_util.dart';

class TransactionApiHandler extends ApiHandler {
  static late Box _tranBox;
  static late Box _idxGuestTran;

  static Future<void> staticApiHandlerInit() async {
    _tranBox = await Hive.openBox('gen_tran');
    _idxGuestTran = await Hive.openBox('idx_guest_tran');
    DbUtil.openedBoxes.addAll([_tranBox, _idxGuestTran]);
  }

  Future<void> updateTransaction(GenTransaction tran) async {
    tran.xid ??= du.generateId(_tranBox);
    tran.linkedInfo = null;
    GenTransaction? old = getTransactionById(tran.xid!);
    await du.logAndPut('Updating tran', _tranBox, tran.xid, tran.toJson());
    if (old != null && old.guestId != tran.guestId && old.guestId != null) {
      List<int> xidList = _idxGuestTran.get(old.guestId) ?? [];
      xidList.remove(tran.xid);
      await du.logAndUpdateList('Updating idxGuestTran', _idxGuestTran, old.guestId, xidList);
    }
    if (tran.guestId != null && (old == null || old.guestId != tran.guestId)) {
      List<int> xidList = _idxGuestTran.get(tran.guestId) ?? [];
      xidList.add(tran.xid!);
      await du.logAndUpdateList('Updating idxGuestTran', _idxGuestTran, tran.guestId, xidList);
    }
  }

  Future<void> deleteTransaction(int xidToDelete) async {
    GenTransaction? old = getTransactionById(xidToDelete);
    if (old != null && old.guestId != null) {
      List<int> xidList = _idxGuestTran.get(old.guestId) ?? [];
      xidList.remove(xidToDelete);
      await du.logAndUpdateList('Updating idxGuestTran', _idxGuestTran, old.guestId, xidList);
    }
    du.logAndDelete('Deleting tran', _tranBox, xidToDelete);
  }

  GenTransaction? getTransactionById(int xid, {queryLinkedInfo = false}) {
    var json = SharedApi.fixHiveJsonType(_tranBox.get(xid));
    if (json != null) {
      var xtran = GenTransaction.fromJson(json);
      if (queryLinkedInfo) {
        xtran.linkedInfo = getLinkedInfo(xtran);
      }
      return xtran;
    }
    return null;
  }

  XtranLinkedInfo getLinkedInfo(GenTransaction xtran) {
    var linkedInfo = XtranLinkedInfo();
    if (xtran.storeId != null) {
      linkedInfo.store = du._storeApiHandler.getStoreById(xtran.storeId!)?.summary();
    }
    if (xtran.uid != null) {
      linkedInfo.user = du._userApiHandler.getUserById(xtran.uid!)?.summary();
    }
    if (xtran.guestId != null) {
      linkedInfo.guest = du._guestApiHandler.getGuestById(xtran.guestId!)?.summary();
    }
    if (xtran.policyId != null) {
      linkedInfo.redeemPolicy = du._redeemPolicyApiHandler.getRedeemPolicyById(xtran.policyId!)?.summary();
    }
    return linkedInfo;
  }

  List<GenTransaction> getTransactionListByGuestId(int guestId, {queryLinkInfo = false}) {
    List<GenTransaction> result = [];
    List<int>? xidList = _idxGuestTran.get(guestId);
    if (xidList != null) {
      for(var xid in xidList) {
        var tran = getTransactionById(xid, queryLinkedInfo: queryLinkInfo);
        if (tran!=null) {
          result.add(tran);
        }
      }
    }
    return result;
  }

  Future<void> handleUpdateTransactionCommand(UpdateTransactionCommand updateTransactionCommand, LoggedInUser loggedIn, ServerResponse resp) async {
    var xtran = updateTransactionCommand.xtran;
    var xidToDelete = updateTransactionCommand.xidToDelete;
    if (xtran != null) {
      if (xtran.storeId == -1) {
        throw ServerApiException.error(ServerResponseCode.mustSpecifyValidStore);
      }
      xtran.uid ??= loggedIn.uid;
      await updateTransaction(xtran);
      resp.updateRecordResponse = UpdateRecordResponse(newId: xtran.xid);
    }
    else if (xidToDelete != null) {
      await deleteTransaction(xidToDelete);
    }
    else {
      throw UnimplementedError();
    }
  }

  bool fitsQueryCriteria(GenTransaction xtran, GenTransaction? xtranQueryCriteria) {
    if (xtranQueryCriteria == null) {
      return true;
    }
    if (xtranQueryCriteria.description?.isNotEmpty ?? false) {
      if (!(xtran.description?.contains(xtranQueryCriteria.description!) ?? false)) {
        return false;
      }
    }
    return true;
  }

  Future<void> handleQueryTransactionCommand(QueryTransactionCommand queryTransactionCommand, ServerResponse resp, UserContext context) async {
    var guestId = queryTransactionCommand.guestId;
    var xid = queryTransactionCommand.xid;
    var queryLinkedInfo = queryTransactionCommand.queryLinkedInfo;
    if (guestId != null) {
      resp.queryTransactionResponse = QueryTransactionResponse(result: getTransactionListByGuestId(guestId));
    }
    else if (xid != null) {
      var xtran = getTransactionById(xid, queryLinkedInfo: queryLinkedInfo);
      if (xtran != null) {
        resp.queryTransactionResponse = QueryTransactionResponse(result: [xtran]);
      }
    }
    else {
      var user = du._userApiHandler.getUserById(context.loggedIn!.uid)!;
      var xtranQueryCriteria = queryTransactionCommand.xtranQueryCriteria;
      var fAdmin = context.loggedIn!.fAdmin;
      var managingStoreId = queryTransactionCommand.managingStoreId;
      List<GenTransaction> list = [];
      log('tranbox: ${_tranBox.values.length}');
      for(var json in _tranBox.values) {
        var xtran = GenTransaction.fromJson(SharedApi.fixHiveJsonType(json));
        if (fAdmin || user.stores.where((su) => su.storeId == xtran.storeId).isNotEmpty) {
          if (fitsQueryCriteria(xtran, xtranQueryCriteria)) {
            if (queryLinkedInfo ?? false) {
              xtran.linkedInfo = getLinkedInfo(xtran);
            }
            list.add(xtran);
          }
        }
      }
      if (managingStoreId != null) {
        list = list.where((xtran) => xtran.storeId == managingStoreId).toList();
      }
      list.sort((b,a)=>a.time.compareTo(b.time));
      resp.queryTransactionResponse = QueryTransactionResponse(result: list);
    }
  }

  @override
  Future<bool> handleApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    var loggedIn = context.loggedIn!;
    final updateTransactionCommand = cmd.updateTransactionCommand;
    final queryTransactionCommand = cmd.queryTransactionCommand;
    if (updateTransactionCommand != null) {
      await handleUpdateTransactionCommand(
          updateTransactionCommand, loggedIn, resp);
    }
    else if (queryTransactionCommand != null) {
      await handleQueryTransactionCommand(
          queryTransactionCommand, resp, context);
    }
    else {
      return false;
    }
    return true;
  }
}



