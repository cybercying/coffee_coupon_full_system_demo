/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
part of '../db_util.dart';

class UserApiHandler extends ApiHandler {
  static late Box _userBox;
  static late Box _idxEmailUserBox;

  static Future<void> staticApiHandlerInit() async {
    _userBox = await Hive.openBox('gen_user');
    _idxEmailUserBox = await Hive.openBox('idx_email_user');
    DbUtil.openedBoxes.addAll([_userBox, _idxEmailUserBox]);
  }

  final Map<int, List<UserChangeListener>> _userChangeListeners = {};
  Set<int> _usersChanged = {};
  Timer? _usersChangedTimer;

  GenUser? getUserByEmail(String email) {
    int? uid = _idxEmailUserBox.get(email);
    return uid != null ? getUserById(uid) : null;
  }

  GenUser? getUserById(int id) {
    var json = SharedApi.fixHiveJsonType(_userBox.get(id));
    if (json != null) {
      return GenUser.fromJson(json);
    }
    return null;
  }

  Future<void> updateUser(GenUser user, {bool keepPassword = false, bool keepStores = false, bool keepLastLoggedIn = false}) async {
    user.uid ??= du.generateId(_userBox);
    user.email = user.email.toLowerCase().trim();
    GenUser? old = getUserById(user.uid!);
    var now = DateTime.now();
    if (user.fullName.isEmpty || user.phone.isEmpty || user.email.isEmpty) {
      throw ServerApiException.error(ServerResponseCode.dataValidationError);
    }
    if (old != null) {
      user.created = old.created;
      if (!keepLastLoggedIn) {
        user.lastLoggedIn = old.lastLoggedIn;
      }
      if (!keepStores) {
        user.stores = old.stores;
      }
      if (!keepPassword) {
        user.hashedPassword = old.hashedPassword; // password must be changed by another command
      }
    }
    else {
      if (getUserByEmail(user.email) != null) { // record with same Email found, error!
        throw ServerApiException.error(ServerResponseCode.duplicatedEmailNotAllowed);
      }
      user.created = now;
    }
    if (!keepLastLoggedIn) {
      user.lastUpdated = now;
    }
    user.plainPassword = null;
    await du.logAndPut('updateUser', _userBox, user.uid, user.toJson());
    if (old != null && old.email != user.email) {
      await du.logAndDelete('Deleting email index', _idxEmailUserBox, old.email);
    }
    if (old == null || old.email != user.email) {
      await du.logAndPut(
          'Updating email index', _idxEmailUserBox, user.email, user.uid);
    }
    if (user.uid != null) {
      markUserChanged(user.uid!);
    }
  }

  void markUserChanged(int uid) {
    _usersChanged.add(uid);
    _usersChangedTimer ??= Timer(const Duration(milliseconds: 10), fulfillUserChanged);
  }

  void fulfillUserChanged() {
    _usersChangedTimer?.cancel();
    _usersChangedTimer = null;
    var usersChanged = _usersChanged;
    _usersChanged = {}; // This trick allows _usersChanged to be changed during dispatching notification
    for(var uid in usersChanged) {
      var listeners = _userChangeListeners[uid];
      if (listeners != null) {
        GenUser? userToNotify = getUserById(uid);
        for(var listener in listeners) {
          listener.onUserChanged(userToNotify);
        }
      }
    }
  }

  Future<void> deleteUser(int userIdToDelete) async {
    GenUser? old = getUserById(userIdToDelete);
    if (old == null) {
      throw ServerApiException.error(ServerResponseCode.designatedTargetNotExist);
    }
    else {
      for(var storeUser in old.stores) {
        if (storeUser.storeId != null) {
          var store = du._storeApiHandler.getStoreById(storeUser.storeId!);
          if (store != null) {
            int oldLength = store.users.length;
            store.users.removeWhere((element) {
              markUserChanged(element.uid);
              return element.uid == userIdToDelete;
            });
            if (oldLength != store.users.length) {
              await du._storeApiHandler.updateStore(store);
            }
          }
        }
      }
      await du.logAndDelete('Deleting user', _userBox, userIdToDelete);
      await du.logAndDelete('Deleting email index', _idxEmailUserBox, old.email);
    }
  }

  Future<void> handleUpdateUserCommand(UpdateUserCommand updateUserCommand, ServerResponse resp, UserContext context) async {
    var user = updateUserCommand.user;
    if (!context.loggedIn!.fAdmin) {
      bool insufficientPrivilegeError = true;
      var userIdToDelete = updateUserCommand.userIdToDelete;
      if (user != null) {
        if (user.uid != null) {
          if (context.loggedIn!.getCachedAccessibleUids().contains(user.uid)) {
            insufficientPrivilegeError = false;
          }
        }
        else if (updateUserCommand.managingStoreId != null) { // insert record
          var store = du._storeApiHandler.getStoreById(updateUserCommand.managingStoreId!);
          if (store!=null && store.users.where((su) => su.uid == context.loggedIn!.uid && su.role == UserRoleAtStore.manager).isNotEmpty) {
            insufficientPrivilegeError = false;
          }
        }
      }
      else if (userIdToDelete != null) {
        if (context.loggedIn!.getCachedAccessibleUids().contains(userIdToDelete)) {
          insufficientPrivilegeError = false;
        }
      }
      if (insufficientPrivilegeError) {
        throw ServerApiException.error(ServerResponseCode.insufficientPrivilegeError);
      }
    }
    if (user != null) {
      if (user.uid == null && updateUserCommand.managingStoreId != null) {
        var store = du._storeApiHandler.getStoreById(updateUserCommand.managingStoreId!);
        if (store!=null) {
          await updateUser(user, keepPassword: updateUserCommand.assignPassword ?? false);
          store.users.add(StoreUser(uid: user.uid!, role: UserRoleAtStore.staff, storeId: store.storeId));
          store.usersChanged = true;
          await du._storeApiHandler.updateStore(store);
          fulfillUserChanged();
        }
        else {
          throw ServerApiException.error(ServerResponseCode.designatedTargetNotExist);
        }
      }
      else {
        await updateUser(user, keepPassword: updateUserCommand.assignPassword ?? false);
      }
      resp.updateRecordResponse = UpdateRecordResponse(newId: user.uid);
    }
    else {
      var userIdToDelete = updateUserCommand.userIdToDelete;
      var managingStoreId = updateUserCommand.managingStoreId;
      if (userIdToDelete != null) {
        if (userIdToDelete == context.loggedIn!.uid) {
          throw ServerApiException.error(ServerResponseCode.cannotDeleteObjectInUse);
        }
        if (managingStoreId == null) {
          await deleteUser(userIdToDelete);
        }
        else {
          await du._storeApiHandler.removeUserFromStore(userIdToDelete, managingStoreId);
        }
      }
    }
  }

  Set<int> getAccessibleUids(int uid) {
    var user = getUserById(uid);
    var stores = user!.stores;
    Set<int> accessibleUids = {};
    for(var su in stores) {
      if (su.role == UserRoleAtStore.manager) {
        var store = du._storeApiHandler.getStoreById(su.storeId!)!;
        for(var su2 in store.users) {
          accessibleUids.add(su2.uid);
        }
      }
    }
    return accessibleUids;
  }

  bool fitsQueryCriteria(GenUser user, GenUser? userQueryCriteria) {
    if (userQueryCriteria == null) {
      return true;
    }
    if (userQueryCriteria.fullName.isNotEmpty) {
      if (!user.fullName.contains(userQueryCriteria.fullName)) {
        return false;
      }
    }
    if (userQueryCriteria.phone.isNotEmpty) {
      if (!user.phone.contains(userQueryCriteria.phone)) {
        return false;
      }
    }
    if (userQueryCriteria.email.isNotEmpty) {
      if (!user.email.contains(userQueryCriteria.email)) {
        return false;
      }
    }
    return true;
  }

  Future<void> handleQueryUserCommand(QueryUserCommand queryUserCommand, ServerResponse resp, UserContext context) async {
    var uid = queryUserCommand.uid;
    if (uid!=null) {
      List<GenUser> result = [];
      List<GenStore> storeList = [];
      var userById = getUserById(uid);
      if (userById != null) {
        if (queryUserCommand.queryStoreInfo ?? false) {
          for(var su in userById.stores) {
            if (su.storeId != null) {
              var store = du._storeApiHandler.getStoreById(su.storeId!)?.summary();
              if (store != null) {
                storeList.add(store);
              }
            }
          }
        }
        result.add(userById);
      }
      resp.queryUserResponse = QueryUserResponse(result: result, stores: storeList);
    }
    else {
      var userQueryCriteria = queryUserCommand.userQueryCriteria;
      var managingStoreId = queryUserCommand.managingStoreId;
      List<GenUser> list = [];
      if (context.loggedIn!.fAdmin) {
        list = [for(var json in _userBox.values)
          GenUser.fromJson(SharedApi.fixHiveJsonType(json))
        ];
      }
      else {
        Set<int> accessibleUids = context.loggedIn!.getCachedAccessibleUids();
        for(var accessibleUid in accessibleUids) {
          var userGot = getUserById(accessibleUid);
          if (userGot != null) {
            list.add(userGot);
          }
        }
      }
      if (userQueryCriteria != null) {
        list = list.where((user) => fitsQueryCriteria(user, userQueryCriteria))
            .toList();
      }
      if (managingStoreId != null) {
        list = list.where((user) => user.stores.where((su) => su.storeId == managingStoreId).isNotEmpty).toList();
      }
      list.sort((a,b)=>a.created!.compareTo(b.created!));
      resp.queryUserResponse = QueryUserResponse(result: list);
    }
  }

  Future<void> handleLogin(DateTime now, LoginCommand loginCommand, ServerResponse resp, UserContext context) async {
    Duration diff = now.difference(loginCommand.time);
    if (diff.abs().inHours < 8) {
      // security check
      GenUser? user = getUserByEmail(loginCommand.email);
      if (user != null && user.status == UserStatus.normal) {
        String actuatedHashedPassword = SharedApi.actuatedHashedPassword(
            user.email, user.hashedPassword!, loginCommand.time);
        if (actuatedHashedPassword == loginCommand.actuatedHashedPassword) {
          var channel = ChannelContext(du.generateRandomString());
          var loginResponse = LoginResponse(user.uid!, channel);
          resp.loginResponse = loginResponse;
          resp.type = ServerResponseType.ok;
          context.state = UserContextState.existing;
          context.loggedIn =
              LoggedInUser(
                  du: du,
                  uid: user.uid!,
                  email: user.email,
                  fAdmin: user.fAdmin
              );
          du.info('logged in: ${context.state}');
          du._contextMap[channel.cid] = context;
          user.lastLoggedIn = now;
          await updateUser(user, keepLastLoggedIn: true);
          loginResponse.loggedInUser = GenUser(
            uid: user.uid,
            email: user.email,
            fullName: user.fullName,
            phone: user.phone,
            fAdmin: user.fAdmin,
          );
          context.loggedIn!.initLoggedInUser();
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
  Future<bool> handleApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    var loggedIn = context.loggedIn!;
    final changePasswordCommand = cmd.changePasswordCommand;
    final updateUserCommand = cmd.updateUserCommand;
    final queryUserCommand = cmd.queryUserCommand;
    if (changePasswordCommand != null) {
      GenUser user = getUserById(loggedIn.uid)!;
      if (user.hashedPassword == changePasswordCommand.oldPasswordHash) {
        user.hashedPassword = changePasswordCommand.newPasswordHash;
        await updateUser(user, keepPassword: true);
      } else {
        throw ServerApiException.error(ServerResponseCode.passwordMismatch);
      }
    }
    else if (updateUserCommand != null) {
      await handleUpdateUserCommand(
          updateUserCommand, resp, context);
    }
    else if (queryUserCommand != null) {
      await handleQueryUserCommand(queryUserCommand, resp, context);
    }
    else {
      return false;
    }
    return true;
  }

  @override
  Future<bool> handlePreLoginApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    final loginCommand = cmd.loginCommand;
    final now = DateTime.now();
    if (loginCommand != null) {
      await handleLogin(now, loginCommand, resp, context);
    }
    else {
      return false;
    }
    return true;
  }

  void listenToUserChange(int uid, UserChangeListener listener, bool enabled) {
    List<UserChangeListener> listeners = _userChangeListeners[uid] ?? [];
    bool contains = listeners.contains(listener);
    if (enabled && !contains) {
      listeners.add(listener);
    }
    else if (!enabled && contains) {
      listeners.remove(listener);
    }
    if (listeners.isEmpty) {
      _userChangeListeners.remove(uid);
    }
    else {
      _userChangeListeners[uid] = listeners;
    }
  }
}

