/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
part of '../db_util.dart';

class StoreApiHandler extends ApiHandler {
  static late Box _storeBox;

  static Future<void> staticApiHandlerInit() async {
    _storeBox = await Hive.openBox('gen_store');
    DbUtil.openedBoxes.addAll([_storeBox]);
  }

  Future<void> updateStore(GenStore store) async {
    if (store.storeId == null) {
      store.storeId = du.generateId(_storeBox);
      store.usersChanged = true;
    }
    for(var su in store.users) {
      su.storeId ??= store.storeId;
    }
    GenStore? old = getStoreById(store.storeId!);
    if (store.usersChanged ?? false) {
      if (old!=null) {
        for(var su in old.users) {
          du._userApiHandler.markUserChanged(su.uid);
        }
      }
      for(var su in store.users) {
        du._userApiHandler.markUserChanged(su.uid);
      }
      if (old != null) {
        for (var su in old.users) {
          if (!isUidInList(su.uid, store.users)) {
            var userById = du._userApiHandler.getUserById(su.uid);
            if (userById != null) {
              var e = userById.stores.indexWhere((element) =>
              element.storeId == su.storeId && element.role == su.role);
              if (e != -1) {
                userById.stores.removeAt(e);
                await du._userApiHandler.updateUser(userById, keepStores: true);
              }
            }
          }
        }
      }
      for(var su in store.users) {
        var userById = du._userApiHandler.getUserById(su.uid);
        if (userById != null) {
          var e = userById.stores.indexWhere((element) =>
          element.storeId == su.storeId && element.role == su.role);
          if (e == -1) { // if not already existing, add it to the list
            userById.stores.add(su);
            await du._userApiHandler.updateUser(userById, keepStores: true);
          }
        }
      }
    }
    else if (old != null) {
      store.users = old.users;
    }
    store.usersChanged = null;
    await du.logAndPut(
        'Updating store', _storeBox, store.storeId!, store.toJson());
  }

  Future<void> deleteStore(int storeIdToDelete) async {
    GenStore? old = getStoreById(storeIdToDelete);
    if (old != null) {
      for (var su in old.users) {
        var userById = du._userApiHandler.getUserById(su.uid);
        if (userById != null) {
          var e = userById.stores.indexWhere((element) =>
            element.storeId == su.storeId && element.role == su.role);
          if (e != -1) {
            userById.stores.removeAt(e);
            await du._userApiHandler.updateUser(userById, keepStores: true);
          }
        }
      }
    }
    await du.logAndDelete(
        'Deleting store', _storeBox, storeIdToDelete);
  }

  bool isUidInList(int uid, List<StoreUser> list) {
    for(var su in list) {
      if (su.uid == uid) {
        return true;
      }
    }
    return false;
  }

  GenStore? getStoreById(int id) {
    var json = SharedApi.fixHiveJsonType(_storeBox.get(id));
    if (json != null) {
      return GenStore.fromJson(json);
    }
    return null;
  }

  bool fitsQueryCriteria(GenStore store, GenStore? storeQueryCriteria) {
    if (storeQueryCriteria == null) {
      return true;
    }
    if (storeQueryCriteria.name.isNotEmpty) {
      if (!store.name.contains(storeQueryCriteria.name)) {
        return false;
      }
    }
    if (storeQueryCriteria.address.isNotEmpty) {
      if (!store.address.contains(storeQueryCriteria.address)) {
        return false;
      }
    }
    if (storeQueryCriteria.phone.isNotEmpty) {
      if (!store.phone.contains(storeQueryCriteria.phone)) {
        return false;
      }
    }
    return true;
  }

  Future<void> removeUserFromStore(int userIdToRemoveFromStore, int managingStoreId) async {
    GenStore? store = getStoreById(managingStoreId);
    if (store == null) {
      throw ServerApiException.error(ServerResponseCode.designatedTargetNotExist);
    }
    bool changed = false;
    store.users.removeWhere((su) {
      if (su.uid == userIdToRemoveFromStore) {
        changed = true;
        return true;
      }
      return false;
    });
    if (changed) {
      store.usersChanged = true;
      await updateStore(store);
    }
  }

  void handleQueryStoreCommand(QueryStoreCommand queryStoreCommand, ServerResponse resp, UserContext context, {guestQuery = false}) {
    var storeId = queryStoreCommand.storeId;
    if (storeId!=null) {
      List<GenStore> result = [];
      List<GenUser> linkedUsers = [];
      var storeById = getStoreById(storeId);
      if (storeById != null) {
        result.add(storeById);
        if (queryStoreCommand.queryUserInfo ?? false) {
          for(var su in storeById.users) {
            var user = du._userApiHandler.getUserById(su.uid)?.summary();
            if (user!=null) {
              linkedUsers.add(user);
            }
          }
        }
      }
      resp.queryStoreResponse = QueryStoreResponse(result: result, linkedUsers: linkedUsers);
    }
    else {
      var storeQueryCriteria = queryStoreCommand.storeQueryCriteria;
      List<GenStore> list = [for(var json in _storeBox.values)
        GenStore.fromJson(SharedApi.fixHiveJsonType(json))
      ];
      if (guestQuery) { // if it's guest query, remove some potentially sensitive info
        for(var store in list) {
          store.users = [];
        }
      }
      if (storeQueryCriteria != null) {
        list = list.where((store) => fitsQueryCriteria(store, storeQueryCriteria))
            .toList();
      }
      list.sort((a,b)=>a.name.compareTo(b.name));
      resp.queryStoreResponse = QueryStoreResponse(result: list);
    }
  }

  Future<void> handleUpdateStoreCommand(UpdateStoreCommand updateStoreCommand, ServerResponse resp, UserContext context) async {
    var store = updateStoreCommand.store;
    var storeIdToDelete = updateStoreCommand.storeIdToDelete;

    if (!context.loggedIn!.fAdmin) {
      bool insufficientPrivilegeError = true;
      int? storeId = store?.storeId ?? storeIdToDelete;
      if (storeId != null) {
        var uid = context.loggedIn!.uid;
        var user = du._userApiHandler.getUserById(uid);
        if (user != null) {
          if (user.stores.where((su) => su.uid == uid && su.storeId == storeId && su.role == UserRoleAtStore.manager).isNotEmpty) {
            insufficientPrivilegeError = false;
          }
        }
      }
      if (insufficientPrivilegeError) {
        throw ServerApiException.error(ServerResponseCode.insufficientPrivilegeError);
      }
    }

    if (store != null) {
      await updateStore(store);
      resp.updateRecordResponse = UpdateRecordResponse(newId: store.storeId);
      resp.type = ServerResponseType.ok;
    }
    else {
      var storeIdToDelete = updateStoreCommand.storeIdToDelete;
      if (storeIdToDelete != null) {
        await deleteStore(storeIdToDelete);
      }
    }
  }

  @override
  Future<bool> handleApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    final updateStoreCommand = cmd.updateStoreCommand;
    final queryStoreCommand = cmd.queryStoreCommand;
    final addUserToStoreCommand = cmd.addUserToStoreCommand;
    if (updateStoreCommand != null) {
      await handleUpdateStoreCommand(
          updateStoreCommand, resp, context);
    }
    else if (queryStoreCommand != null) {
      handleQueryStoreCommand(queryStoreCommand, resp, context);
    }
    else if (addUserToStoreCommand != null) {
      var store = getStoreById(addUserToStoreCommand.storeId);
      var user = du._userApiHandler.getUserByEmail(addUserToStoreCommand.email);
      if (store == null || user == null) {
        throw ServerApiException.error(ServerResponseCode.designatedTargetNotExist);
      }
      if (store.users.where((su) => su.uid == context.loggedIn!.uid && su.role == UserRoleAtStore.manager).isEmpty) {
        throw ServerApiException.error(ServerResponseCode.insufficientPrivilegeError);
      }
      if (store.users.where((su) => su.uid == user.uid && su.role == addUserToStoreCommand.role).isEmpty) {
        // add only when there isn't already the same record there
        store
          ..users.add(StoreUser(
              uid: user.uid!,
              role: addUserToStoreCommand.role,
              storeId: store.storeId))
          ..usersChanged = true;
        await updateStore(store);
      }
    }
    else {
      return false;
    }
    return true;
  }

  @override
  Future<bool> handleGuestApiRequest(ServerCommand cmd, ServerResponse resp, UserContext context) async {
    final queryStoreCommand = cmd.queryStoreCommand;
    if (queryStoreCommand != null) {
      handleQueryStoreCommand(queryStoreCommand, resp, context, guestQuery: true);
    }
    else {
      return false;
    }
    return true;
  }
}

