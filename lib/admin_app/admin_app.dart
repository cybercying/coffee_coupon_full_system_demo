/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:async';
import 'dart:developer';

import '../guest_app/barcode_ui.dart' show decodeBarcodeImage;

import '../app_settings.dart';
import 'package:get/get.dart';
import 'package:protocol/client_state.dart';
import 'package:protocol/protocol.dart';
import 'package:hive/hive.dart';

import '../ui_shared.dart';

class QueryScreenState<T> {
  var result = RxList<T>();
  var timeElapsed = RxDouble(0);
  var numberOfRecords = RxInt(-1);
  T queryCriteria;
  var expanded = false.obs;

  QueryScreenState({required this.queryCriteria});

  void clean({required T queryCriteria}) {
    result.value = [];
    this.queryCriteria = queryCriteria;
    expanded.value = false;
    numberOfRecords.value = -1;
  }
}

class AdminApp extends GetxController {
  var email = '';
  var password = '';
  var currentScreen = AdminAppScreen.loginScreen.obs;
  final mockMessageQueryResult = RxList<MockMessage>();
  var clientBox = Hive.box('client');
  var loggedInFullName = ''.obs;
  var loggedInEmail = ''.obs;
  AdminAppSavedState saved = AdminAppSavedState();
  late ServerConnection conn;
  GenUser? selectedUser;
  LoginResponse? loginResponse;
  final userQuery = QueryScreenState<GenUser>(queryCriteria: GenUser.empty());
  final storeQuery = QueryScreenState<GenStore>(queryCriteria: GenStore.empty());
  GenStore? selectedStore;
  final redeemPolicyQuery = QueryScreenState<GenRedeemPolicy>(queryCriteria: GenRedeemPolicy.empty());
  GenRedeemPolicy? selectedRedeemPolicy;
  final managingStore = Rx<GenStore?>(null);
  final managingStoreExpanded = false.obs;
  List<GenStore> selectedUserStores = [];
  List<GenUser> selectedStoreUsers = [];
  final xtranQuery = QueryScreenState<GenTransaction>(queryCriteria: GenTransaction.empty());
  GenTransaction? selectedXtran;

  bool get isCurrentlyLoggedIn {
    return loginResponse != null;
  }

  Future<bool> login() async {
    log('logging in...email:$email, password:$password');
    DateTime now = DateTime.now();
    try {
      loginResponse = await conn.login(
          LoginCommand(
              email: email,
              actuatedHashedPassword: SharedApi.actuatedHashedPassword(
                  email, SharedApi.encryptedDigest(password), now),
              time: now
          )
      );
      log('loginResponse: ${loginResponse?.toJson()}');
    }
    catch(e) {
      log('error login: $e');
      return false;
    }
    saved.savedEmail = email;
    saved.savedHashedPassword = SharedApi.encryptedDigest(password);
    saved.loggedIn = true;
    saved.screen = AdminAppScreen.storeListScreen;
    saveState();
    await performAfterLogin();
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    currentScreen.listen((value) async {
      if (loginResponse != null) {
        switch (value) {
          case AdminAppScreen.userListScreen:
            if (userQuery.numberOfRecords.value == -1) {
              await queryUserList();
            }
            break;
          case AdminAppScreen.storeListScreen:
            if (storeQuery.numberOfRecords.value == -1) {
              await queryStoreList();
            }
            break;
          case AdminAppScreen.redeemPolicyListScreen:
            if (redeemPolicyQuery.numberOfRecords.value == -1) {
              await queryRedeemPolicyList();
            }
            break;
          case AdminAppScreen.xtranListScreen:
            if (xtranQuery.numberOfRecords.value == -1) {
              await queryXtranList();
            }
            break;
          case AdminAppScreen.loginScreen:
            break;
        }
      }
    });
    managingStore.listen((value) async {
      userQuery.clean(queryCriteria: GenUser.empty());
      xtranQuery.clean(queryCriteria: GenTransaction.empty(storeId: -1));
      if (isCurrentlyLoggedIn) {
        if (currentScreen.value == AdminAppScreen.userListScreen) {
          await queryUserList();
        }
        else if (currentScreen.value == AdminAppScreen.xtranListScreen) {
          await queryXtranList();
        }
      }
    });
  }

  @override
  void onClose() {
    currentScreen.close();
  }

  Future<void> performAfterLogin() async {
    loggedInFullName.value = loginResponse?.loggedInUser?.fullName ?? '';
    loggedInEmail.value = loginResponse?.loggedInUser?.email ?? '';
    currentScreen.value = saved.screen ?? AdminAppScreen.storeListScreen;
    if (saved.managingStoreId != null) {
      var resp = await sendServerCommand(ServerCommand(
        queryStoreCommand: QueryStoreCommand(
          storeId: saved.managingStoreId
        )
      ));
      if (resp.queryStoreResponse!.result.isNotEmpty) {
        managingStore.value = resp.queryStoreResponse!.result[0];
      }
    }
  }

  Future<ServerResponse> sendServerCommand(ServerCommand cmd) async {
    try {
      UiTransientState.instance.setSystemBusy(true);
      // await Future.delayed(const Duration(seconds: 3));
      return await conn.sendServerCommand(cmd);
    }
    on ServerException catch(e) {
      UiTransientState.instance.setSystemBusy(false);
      if (e.type == ServerResponseType.notAuthenticated) {
        if (await confirmDialog(content: "adminApp.disconnectPrompt".tr)) {
          DateTime now = DateTime.now();
          try {
            loginResponse = await conn.login(
                LoginCommand(
                    email: saved.savedEmail!,
                    actuatedHashedPassword: SharedApi.actuatedHashedPassword(
                        saved.savedEmail!, saved.savedHashedPassword!, now),
                    time: now
                )
            );
            return await conn.sendServerCommand(cmd);
          }
          on ServerException catch(e) {
            if (e.type == ServerResponseType.notAuthenticated) {
              if (await confirmDialog(content: "adminApp.logoutPrompt".tr)) {
                logout();
              }
            }
          }
        }
      }
      rethrow;
    }
    finally {
      UiTransientState.instance.setSystemBusy(false);
    }
  }

  Future<void> queryUserList() async {
    userQuery.numberOfRecords.value = -1;
    var watch = Stopwatch();
    watch.start();
    ServerCommand cmd = ServerCommand(queryUserCommand: QueryUserCommand(
      userQueryCriteria: userQuery.queryCriteria,
      managingStoreId: managingStore.value?.storeId
    ));
    ServerResponse resp = await sendServerCommand(cmd);
    userQuery.result.value = resp.queryUserResponse!.result;
    watch.stop();
    userQuery.timeElapsed.value = watch.elapsedMilliseconds / 1000.0;
    userQuery.numberOfRecords.value = userQuery.result.length;
  }

  Future<void> queryMockMessageList() async {
    ServerCommand cmd = ServerCommand(queryMockMessageCommand: QueryMockMessageCommand(
        queryList: [MockMessageQuery(queryType: MockMessageQueryType.server)])
    );
    ServerResponse resp = await sendServerCommand(cmd);
    mockMessageQueryResult.value = resp.queryMockMessageResponse!.result;
  }

  void logout() {
    loginResponse = null;
    saved.loggedIn = null;
    saved.savedEmail = null;
    saved.savedHashedPassword = null;
    saveState();
    email = '';
    password = '';
    currentScreen.value = AdminAppScreen.loginScreen;

    AppSettings appSettings = Get.find();
    conn = appSettings.createServerConnection();
  }

  void cleanSlate() {
    mockMessageQueryResult.clear();
    loginResponse = null;
    email = '';
    password = '';
    userQuery.clean(queryCriteria: GenUser.empty());
    storeQuery.clean(queryCriteria: GenStore.empty());
    redeemPolicyQuery.clean(queryCriteria: GenRedeemPolicy.empty());
    managingStore.value = null;
    managingStoreExpanded.value = false;
    selectedUserStores = [];
    selectedStoreUsers = [];
    xtranQuery.clean(queryCriteria: GenTransaction.empty(storeId: -1));
  }

  Future<void> bringUpApp() async {
    AppSettings appSettings = Get.find();
    saved = appSettings.loadAdminAppSavedState() ?? AdminAppSavedState();
    conn = appSettings.createServerConnection();
    cleanSlate();
    currentScreen.value = AdminAppScreen.loginScreen;
    if (saved.loggedIn ?? false) {
      DateTime now = DateTime.now();
      try {
        loginResponse = await conn.login(
            LoginCommand(
                email: saved.savedEmail!,
                actuatedHashedPassword: SharedApi.actuatedHashedPassword(
                    saved.savedEmail!, saved.savedHashedPassword!, now),
                time: now
            )
        );
        await performAfterLogin();
      }
      catch(e) {
        log('error login: $e');
      }
    }
  }

  Future<void> bringUpAppAndLogin(String email, String password) async {
    AppSettings appSettings = Get.find();
    if (appSettings.mode.value != AppMode.adminApp) {
      appSettings.mode.value = AppMode.adminApp;
      appSettings.saveState();
    }
    saved = AdminAppSavedState();
    conn = appSettings.createServerConnection();
    cleanSlate();
    currentScreen.value = AdminAppScreen.loginScreen;
    this.email = email;
    this.password = password;
    await login();
  }

  void saveState() {
    AppSettings appSettings = Get.find();
    if (currentScreen.value != AdminAppScreen.loginScreen) {
      saved.screen = currentScreen.value;
    }
    appSettings.saveAdminAppSavedState(saved);
  }

  Future<void> updateSelectedUser() async {
    ServerCommand cmd = ServerCommand(
        updateUserCommand: UpdateUserCommand(
            user: selectedUser!,
            managingStoreId: managingStore.value?.storeId
        )
    );
    await sendServerCommand(cmd);
  }

  Future<void> deleteSelectedUser() async {
    ServerCommand cmd = ServerCommand(
        updateUserCommand: UpdateUserCommand(
            userIdToDelete: selectedUser!.uid,
            managingStoreId: managingStore.value?.storeId
        )
    );
    await sendServerCommand(cmd);
  }

  Future<void> queryStoreList() async {
    storeQuery.numberOfRecords.value = -1;
    var watch = Stopwatch();
    watch.start();
    ServerCommand cmd = ServerCommand(queryStoreCommand: QueryStoreCommand(
        storeQueryCriteria: storeQuery.queryCriteria
    ));
    ServerResponse resp = await sendServerCommand(cmd);
    storeQuery.result.value = resp.queryStoreResponse!.result;
    watch.stop();
    storeQuery.timeElapsed.value = watch.elapsedMilliseconds / 1000.0;
    storeQuery.numberOfRecords.value = storeQuery.result.length;
    int? managingStoreId = managingStore.value?.storeId;
    if (managingStoreId != null) {
      var where = storeQuery.result.where((element) => element.storeId == managingStoreId);
      if (where.isNotEmpty) {
        managingStore.value = where.first;
      }
    }
  }

  Future<void> queryRedeemPolicyList() async {
    redeemPolicyQuery.numberOfRecords.value = -1;
    var watch = Stopwatch();
    watch.start();
    ServerCommand cmd = ServerCommand(queryRedeemPolicyCommand: QueryRedeemPolicyCommand(
        redeemPolicyQueryCriteria: redeemPolicyQuery.queryCriteria
    ));
    ServerResponse resp = await sendServerCommand(cmd);
    redeemPolicyQuery.result.value = resp.queryRedeemPolicyResponse!.result;
    watch.stop();
    redeemPolicyQuery.timeElapsed.value = watch.elapsedMilliseconds / 1000.0;
    redeemPolicyQuery.numberOfRecords.value = redeemPolicyQuery.result.length;
  }

  Future<void> updateSelectedStore() async {
    ServerCommand cmd = ServerCommand(updateStoreCommand: UpdateStoreCommand(store: selectedStore!));
    await sendServerCommand(cmd);
  }

  Future<void> deleteSelectedStore() async {
    ServerCommand cmd = ServerCommand(updateStoreCommand: UpdateStoreCommand(storeIdToDelete: selectedStore!.storeId));
    await sendServerCommand(cmd);
  }

  Future<void> updateSelectedRedeemPolicy() async {
    ServerCommand cmd = ServerCommand(updateRedeemPolicyCommand: UpdateRedeemPolicyCommand(redeemPolicy: selectedRedeemPolicy!));
    await sendServerCommand(cmd);
  }

  Future<void> deleteSelectedRedeemPolicy() async {
    ServerCommand cmd = ServerCommand(updateRedeemPolicyCommand: UpdateRedeemPolicyCommand(policyIdToDelete: selectedRedeemPolicy!.policyId));
    await sendServerCommand(cmd);
  }

  Future<void> selectUserForEditing(GenUser rec) async {
    selectedUser = rec;
    var resp = await sendServerCommand(ServerCommand(
      queryUserCommand: QueryUserCommand(
        uid: rec.uid,
        queryStoreInfo: true
      )
    ));
    selectedUserStores = resp.queryUserResponse?.stores ?? [];
  }

  Future<void> selectStoreForEditing(GenStore rec) async {
    selectedStore = rec;
    var resp = await sendServerCommand(ServerCommand(
        queryStoreCommand: QueryStoreCommand(
            storeId: rec.storeId,
            queryUserInfo: true
        )
    ));
    selectedStoreUsers = resp.queryStoreResponse?.linkedUsers ?? [];
  }

  Future<void> addUserToStore(String email, GenStore addToStore, UserRoleAtStore role) async {
    await sendServerCommand(ServerCommand(
        addUserToStoreCommand: AddUserToStoreCommand(
          email: email,
          storeId: addToStore.storeId!,
          role: role,
        )
    ));
  }

  Future<void> queryXtranList() async {
    xtranQuery.numberOfRecords.value = -1;
    var watch = Stopwatch();
    watch.start();
    ServerCommand cmd = ServerCommand(queryTransactionCommand: QueryTransactionCommand(
        xtranQueryCriteria: xtranQuery.queryCriteria,
        managingStoreId: managingStore.value?.storeId,
        queryLinkedInfo: true,
    ));
    ServerResponse resp = await sendServerCommand(cmd);
    xtranQuery.result.value = resp.queryTransactionResponse!.result;
    watch.stop();
    xtranQuery.timeElapsed.value = watch.elapsedMilliseconds / 1000.0;
    xtranQuery.numberOfRecords.value = xtranQuery.result.length;
  }

  Future<void> selectXtranForEditing(GenTransaction rec) async {
    selectedXtran = rec;
  }

  Future<void> updateSelectedXtran() async {
    ServerCommand cmd = ServerCommand(
        updateTransactionCommand: UpdateTransactionCommand(
            xtran: selectedXtran!,
            managingStoreId: managingStore.value?.storeId
        )
    );
    await sendServerCommand(cmd);
  }

  Future<void> deleteSelectedXtran() async {
    ServerCommand cmd = ServerCommand(
        updateTransactionCommand: UpdateTransactionCommand(
            xidToDelete: selectedXtran!.xid!,
            managingStoreId: managingStore.value?.storeId
        )
    );
    await sendServerCommand(cmd);
  }

  Future<ServerResponse> sendServerCommandShowError(ServerCommand cmd) async {
    try {
      return await sendServerCommand(cmd);
    }
    on ServerException catch(e, st) {
      log('sendServerCommandShowError(): e: $e, st: $st');
      await alertErrorDialog('serverCode.${e.code!.name}'.tr);
      rethrow;
    }
  }

  Future<void> scanBarcodeImageForRedeem(String path) async {
    if (managingStore.value == null) {
      await alertErrorDialog("redeem.scanRedeemCodeRequireManagingStore".tr);
      return;
    }
    var code = await decodeBarcodeImage(path);
    await sendServerCommandShowError(ServerCommand(
      redeemForCodeCommand: RedeemForCodeCommand(
        code: code,
        managingStoreId: managingStore.value!.storeId!,
      )
    ));
    if (currentScreen.value == AdminAppScreen.xtranListScreen) {
      await queryXtranList();
    }
    else {
      xtranQuery.numberOfRecords.value = -1;
    }
    await alertDialog("redeem.success".tr);
  }
}

