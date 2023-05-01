/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
part of '../db_util.dart';

class GuestApiHandler extends ApiHandler {
  static late Box _guestBox;
  static late Box _idxPhoneGuestBox;
  static late Box _guestSuppInfoBox;

  static Future<void> staticApiHandlerInit() async {
    _guestBox = await Hive.openBox('gen_guest');
    _idxPhoneGuestBox = await Hive.openBox('idx_phoneGuest');
    _guestSuppInfoBox = await Hive.openBox('gen_guestSuppInfo');
    DbUtil.openedBoxes.addAll([_guestBox, _idxPhoneGuestBox, _guestSuppInfoBox]);
  }

  GenGuest? getGuestById(int guestId) {
    var json = SharedApi.fixHiveJsonType(_guestBox.get(guestId));
    if (json != null) {
      return GenGuest.fromJson(json);
    }
    return null;
  }

  Future<void> updateGuest(GenGuest guest, {keepPassword = false, keepLastLoggedIn = false, selfUpdate = false}) async {
    guest.guestId ??= du.generateId(_guestBox);
    GenGuest? old = getGuestById(guest.guestId!);
    DateTime now = DateTime.now();
    if (old!=null) {
      if (keepPassword == false) {
        guest.hashedPassword = old.hashedPassword;
      }
      if (keepLastLoggedIn == false) {
        guest.lastLoggedIn = old.lastLoggedIn;
      }
      if (selfUpdate && old.phone != guest.phone) {
        throw ServerApiException.error(ServerResponseCode.insufficientPrivilegeError);
      }
      guest.created = old.created;
    }
    else {
      guest.created = now;
    }
    guest.lastUpdated = now;
    await du.logAndPut('Updating guest', _guestBox, guest.guestId, guest.toJson());
    if (old != null && old.phone != guest.phone) {
      await du.logAndDelete('Deleting phone index', _idxPhoneGuestBox, old.phone);
    }
    if (old == null || old.phone != guest.phone) {
      await du.logAndPut(
          'Updating phone index', _idxPhoneGuestBox, guest.phone, guest.guestId);
    }
  }

  GenGuest? getGuestByPhone(String phone) {
    int? guestId = _idxPhoneGuestBox.get(phone);
    return guestId != null ? getGuestById(guestId) : null;
  }

  Future<void> handleUpdateGuestCommand(UpdateGuestCommand updateGuestCommand, ServerResponse resp) async {
    var guest = updateGuestCommand.guest;
    if (guest != null) {
      await updateGuest(guest);
      resp.updateRecordResponse = UpdateRecordResponse(newId: guest.guestId);
    }
    else {
      var guestIdToDelete = updateGuestCommand.guestIdToDelete;
      if (guestIdToDelete != null) {
        throw UnimplementedError();
      }
    }
  }

  @override
  Future<bool> handlePreLoginApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    final guestLoginCommand = cmd.guestLoginCommand;
    if (guestLoginCommand != null) {
      await handleGuestLogin(cmd, resp, context);
    }
    else {
      return false;
    }
    return true;
  }

  @override
  Future<bool> handleApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    final updateGuestCommand = cmd.updateGuestCommand;
    final queryGuestCommand = cmd.queryGuestCommand;
    if (updateGuestCommand != null) {
      await handleUpdateGuestCommand(updateGuestCommand, resp);
    }
    else if (queryGuestCommand != null) {
      await handleQueryGuestCommand(queryGuestCommand, resp, context);
    }
    else {
      return false;
    }
    return true;
  }

  Future<void> handleGuestLogin(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    final guestLoginCommand = cmd.guestLoginCommand!;
    DateTime now = DateTime.now();
    Duration diff = now.difference(guestLoginCommand.time);
    if (diff.abs().inHours < 8) {
      // security check
      GenGuest? guest = getGuestByPhone(guestLoginCommand.phone);
      if (guest != null && guest.status == GuestStatus.normal) {
        String actuatedHashedPassword = SharedApi.actuatedHashedPassword(
            guest.phone, guest.hashedPassword!, guestLoginCommand.time);
        if (actuatedHashedPassword == guestLoginCommand.actuatedHashedPassword) {
          var channel = ChannelContext(du.generateRandomString());
          var guestLoginResponse = GuestLoginResponse(
              guestId: guest.guestId!,
              channel: channel,
              loggedInGuest: guest
          );
          resp.guestLoginResponse = guestLoginResponse;
          resp.type = ServerResponseType.ok;
          context.state = UserContextState.existing;
          context.loggedInGuest =
              LoggedInGuest(guestId: guest.guestId!, phone: guest.phone);
          du.info('logged in guest: ${context.state}');
          du._contextMap[channel.cid] = context;
          guest.lastLoggedIn = now;
          await updateGuest(guest, keepLastLoggedIn: true);
          //resp.guestLoginResponse
          guestLoginResponse.loggedInGuest = GenGuest(
            guestId: guest.guestId,
            phone: guest.phone,
            email: guest.email,
            fullName: guest.fullName,
            birthday: guest.birthday,
            gender: guest.gender,
          );
        } else {
          throw ServerApiException(type:ServerResponseType.notAuthenticated, code: ServerResponseCode.incorrectPassword);
        }
      }
      else {
        throw ServerApiException(type:ServerResponseType.notAuthenticated, code: ServerResponseCode.securityStatusError);
      }
    } else {
      throw ServerApiException(type:ServerResponseType.notAuthenticated, code: ServerResponseCode.securityTimeCheckError);
    }
  }

  @override
  Future<bool> handleGuestApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    var updateGuestSuppInfoCommand = cmd.updateGuestSuppInfoCommand;
    var queryGuestSuppInfoCommand = cmd.queryGuestSuppInfoCommand;
    var queryGuestInfoCommand = cmd.queryGuestInfoCommand;
    var updateGuestCommand = cmd.updateGuestCommand;
    var queryTransactionCommand = cmd.queryTransactionCommand;
    if (updateGuestSuppInfoCommand != null) {
      await handleUpdateGuestSuppInfoCommand(updateGuestSuppInfoCommand, resp, context);
    }
    else if (queryGuestSuppInfoCommand != null) {
      await handleQueryGuestSuppInfoCommand(queryGuestSuppInfoCommand, resp, context);
    }
    else if (queryGuestInfoCommand != null) {
      await handleQueryGuestInfoCommand(queryGuestInfoCommand, resp, context);
    }
    else if (updateGuestCommand != null) {
      await handleSelfUpdateGuestCommand(updateGuestCommand, resp, context);
    }
    else if (queryTransactionCommand != null) {
      await handleSelfQueryTransactionCommand(queryTransactionCommand, resp, context);
    }
    else {
      return false;
    }
    return true;
  }

  Future<void> handleUpdateGuestSuppInfoCommand(UpdateGuestSuppInfoCommand updateGuestSuppInfoCommand, ServerResponse resp, UserContext context) async {
    var guestSuppInfo = updateGuestSuppInfoCommand.guestSuppInfo;
    if (guestSuppInfo.guestId != context.loggedInGuest!.guestId) {
      throw ServerApiException.error(ServerResponseCode.securityStatusError);
    }
    await du.logAndPut('Updating guestSuppInfo', _guestSuppInfoBox, guestSuppInfo.guestId, guestSuppInfo.toJson());
  }

  Future<void> handleQueryGuestSuppInfoCommand(QueryGuestSuppInfoCommand queryGuestSuppInfoCommand, ServerResponse resp, UserContext context) async {
    var guestId = context.loggedInGuest!.guestId;
    var json = SharedApi.fixHiveJsonType(_guestSuppInfoBox.get(guestId));
    resp.queryGuestSuppInfoResponse = QueryGuestSuppInfoResponse(
        guestSuppInfo: json == null ? null: GuestSuppInfo.fromJson(json)
    );
  }

  bool fitsQueryCriteria(GenGuest guest, GenGuest? guestQueryCriteria) {
    if (guestQueryCriteria == null) {
      return true;
    }
    if (guestQueryCriteria.fullName.isNotEmpty) {
      if (!guest.fullName.contains(guestQueryCriteria.fullName)) {
        return false;
      }
    }
    if (guestQueryCriteria.phone.isNotEmpty) {
      if (!guest.phone.contains(guestQueryCriteria.phone)) {
        return false;
      }
    }
    if (guest.email != null && guestQueryCriteria.email != null && guestQueryCriteria.email!.isNotEmpty) {
      if (!guest.email!.contains(guestQueryCriteria.email!)) {
        return false;
      }
    }
    return true;
  }

  Future<void> handleQueryGuestCommand(QueryGuestCommand queryGuestCommand, ServerResponse resp, UserContext context) async {
    var guestId = queryGuestCommand.guestId;
    if (guestId != null) {
      // this section is not tested yet
      var result = <GenGuest>[];
      var guest = getGuestById(guestId);
      if (guest != null) {
        result.add(guest);
      }
      resp.queryGuestResponse = QueryGuestResponse(result: result);
    }
    else {
      var guestQueryCriteria = queryGuestCommand.guestQueryCriteria;
      //var managingStoreId = queryGuestCommand.managingStoreId;
      List<GenGuest> list = [];
      list = [for(var json in _guestBox.values)
        GenGuest.fromJson(SharedApi.fixHiveJsonType(json))
      ];
      if (guestQueryCriteria != null) {
        list = list.where((guest) => fitsQueryCriteria(guest, guestQueryCriteria))
            .toList();
      }
      list.sort((a,b)=>a.created!.compareTo(b.created!));
      resp.queryGuestResponse = QueryGuestResponse(result: list);
    }
  }

  Future<void> handleQueryGuestInfoCommand(QueryGuestInfoCommand queryGuestInfoCommand, ServerResponse resp, UserContext context) async {
    var q = QueryGuestInfoResponse();
    var guest = getGuestById(context.loggedInGuest!.guestId);
    if (guest != null) {
      guest.hashedPassword = null;
      var list = du._transactionApiHandler.getTransactionListByGuestId(guest.guestId!);
      int points = 0;
      for(var xtran in list) {
        points += xtran.points;
      }
      q.pointsRemaining = points;
    }
    q.guest = guest;
    resp.queryGuestInfoResponse = q;
  }

  Future<void> handleSelfUpdateGuestCommand(UpdateGuestCommand updateGuestCommand, ServerResponse resp, UserContext context) async {
    var guest = updateGuestCommand.guest;
    if (guest != null) {
      if (guest.guestId != context.loggedInGuest!.guestId) {
        throw ServerApiException.error(ServerResponseCode.insufficientPrivilegeError);
      }
      await updateGuest(guest, selfUpdate: true);
      resp.updateRecordResponse = UpdateRecordResponse(newId: guest.guestId);
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<void> handleSelfQueryTransactionCommand(QueryTransactionCommand queryTransactionCommand, ServerResponse resp, UserContext context) async {
    var list = du._transactionApiHandler.getTransactionListByGuestId(context.loggedInGuest!.guestId, queryLinkInfo: true);
    list.sort((b,a)=>a.time.compareTo(b.time));
    resp.queryTransactionResponse = QueryTransactionResponse(
        result: list
    );
  }
}

