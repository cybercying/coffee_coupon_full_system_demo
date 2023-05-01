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

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:protocol/client_state.dart';
import 'package:protocol/protocol.dart';

import '../app_settings.dart';
import '../ui_shared.dart';

class GuestApp extends GetxController {
  var currentScreen = GuestAppScreen.bindScreen.obs;
  var isRegisterPhoneValid  = false.obs;
  var registeringPhone = TextEditingController();
  var isOtpCodeValid = false.obs;
  var enteringOtpCode = TextEditingController();
  late ServerConnection conn;
  final guestAccount = GenGuest.empty().obs;
  final pointsRemaining = 0.obs;
  GuestAppSavedState saved = GuestAppSavedState();
  List<GenRedeemPolicy> redeemPolicyQueryResult = [];
  GuestLoginResponse? guestLoginResponse;
  GuestSuppInfo guestSuppInfo = GuestSuppInfo(guestId: 0);
  Map<int, RxBool> favoriteMap = {};
  final storeQueryResult = RxList<GenStore>();
  final xtranQueryResult = RxList<GenTransaction>();

  Future<void> guestLogin() async {
    try {
      DateTime now = DateTime.now();
      var resp = await conn.sendServerCommand(ServerCommand(
          guestLoginCommand: GuestLoginCommand(
              phone: saved.savedPhone!,
              actuatedHashedPassword: SharedApi.actuatedHashedPassword(saved.savedPhone!, saved.savedHashedPassword!, now),
              time: now
          )
      ));
      guestLoginResponse = resp.guestLoginResponse;
      await performAfterLogin();
    }
    catch(e, s) {
      log('error login: $e, $s');
    }
  }

  Future<void> bringUpApp() async {
    AppSettings appSettings = Get.find();
    saved = appSettings.loadGuestAppSavedState() ?? GuestAppSavedState();
    conn = appSettings.createServerConnection();
    guestLoginResponse = null;
    registeringPhone.text = '';
    enteringOtpCode.text = '';
    currentScreen.value = GuestAppScreen.bindScreen;
    redeemPolicyQueryResult = [];
    update(['redeemPolicyQueryResult']);
    if (saved.loggedIn ?? false) {
      await guestLogin();
    }
  }

  Future<void> bringUpAppAndRegister(GenGuest testGuest) async {
    AppSettings appSettings = Get.find();
    if (appSettings.mode.value != AppMode.guestApp) {
      appSettings.mode.value = AppMode.guestApp;
      appSettings.saveState();
    }
    saved = GuestAppSavedState();
    conn = appSettings.createServerConnection();
    guestLoginResponse = null;
    registeringPhone.text = '';
    enteringOtpCode.text = '';
    currentScreen.value = GuestAppScreen.bindScreen;
    redeemPolicyQueryResult = [];
    update(['redeemPolicyQueryResult']);

    registeringPhone.text = testGuest.phone;
    await enteredPhoneNumber();

    var resp = await conn.sendServerCommand(ServerCommand(
        queryMockMessageCommand: QueryMockMessageCommand(
            queryList: [
              MockMessageQuery(
                  queryType: MockMessageQueryType.phone,
                  phone: testGuest.phone)
            ]
        )
    ));
    MockMessage msg = resp.queryMockMessageResponse!.result[0];
    enteringOtpCode.text = msg.otpCode!;
    await enteredOtpCode();

    guestAccount.value.fullName = testGuest.fullName;
    guestAccount.value.email = testGuest.email;
    guestAccount.value.birthday = testGuest.birthday;
    guestAccount.value.gender = testGuest.gender;
    await updateGuestAccount();
  }

  void togglePolicyFavorite(GenRedeemPolicy policy, RxBool isFavorite) {
    isFavorite.value = !isFavorite.value;
    if (isFavorite.value) {
      guestSuppInfo.favoritePolicyIds.add(policy.policyId!);
    }
    else {
      guestSuppInfo.favoritePolicyIds.remove(policy.policyId!);
    }
    updateGuestSuppInfoLater();
    update(['redeemPolicyQueryResultFavorite']);
  }

  Future<void> queryRedeemPolicyList() async {
    try {
      ServerResponse resp = await conn.sendServerCommand(ServerCommand(
          queryRedeemPolicyCommand: QueryRedeemPolicyCommand()));
      redeemPolicyQueryResult = resp.queryRedeemPolicyResponse!.result;
      favoriteMap = {};
      for(var policy in redeemPolicyQueryResult) {
        favoriteMap[policy.policyId!] = RxBool(guestSuppInfo.favoritePolicyIds.contains(policy.policyId!));
      }
      update(['redeemPolicyQueryResult']);
    }
    catch(e, s) {
      if (kDebugMode) {
        print(e);
        print(s);
      }
    }
  }

  Future<void> queryStoreList() async {
    ServerResponse resp = await conn.sendServerCommand(ServerCommand(
        queryStoreCommand: QueryStoreCommand()));
    storeQueryResult.value = resp.queryStoreResponse!.result;
  }

  Future<void> queryGuestSuppInfo() async {
    var resp = await conn.sendServerCommand(ServerCommand(queryGuestSuppInfoCommand: QueryGuestSuppInfoCommand()));
    guestSuppInfo = resp.queryGuestSuppInfoResponse!.guestSuppInfo ?? GuestSuppInfo(guestId: guestAccount.value.guestId!);
    List<int> newList = [];
    newList.addAll(guestSuppInfo.favoritePolicyIds);
    guestSuppInfo.favoritePolicyIds = newList;
  }

  Timer? _updateGuestSuppInfoTimer;

  Future<void> updateGuestSuppInfo() async {
    await conn.sendServerCommand(ServerCommand(
        updateGuestSuppInfoCommand: UpdateGuestSuppInfoCommand(
            guestSuppInfo: guestSuppInfo
        )
    ));
  }

  void updateGuestSuppInfoLater() {
    _updateGuestSuppInfoTimer?.cancel();
    _updateGuestSuppInfoTimer = Timer(const Duration(seconds: 5), () {
      _updateGuestSuppInfoTimer = null;
      updateGuestSuppInfo();
    });
  }

  Future<void> performAfterLogin() async {
    guestAccount.value = guestLoginResponse!.loggedInGuest;
    await queryGuestSuppInfo();
    await queryRedeemPolicyList();
    await queryStoreList();
    currentScreen.value = saved.currentScreen;
  }

  Future<void> enteredPhoneNumber() async {
    await conn.sendServerCommand(ServerCommand(
        registerAccountCommand: RegisterAccountCommand(
            type: IdentityType.guest,
            phone: registeringPhone.text
        )
    ));
    currentScreen.value = GuestAppScreen.otpCodeVerifyScreen;
  }

  Future<void> enteredOtpCode() async {
    var resp = await conn.sendServerCommand(ServerCommand(
        bindAccountCommand: BindAccountCommand(
          enteredOtpCode: enteringOtpCode.text,
          action: BindAccountCommandAction.query,
        )
    ));
    guestAccount.value = resp.bindAccountResponse!.guest ?? GenGuest(
        fullName: '',
        phone: registeringPhone.text,
        birthday: DateTime.parse('1980-01-01'),
        gender: Gender.unspecified,
        email: ''
    );
    currentScreen.value = GuestAppScreen.updateGuestAccount;
  }

  Future<void> updateGuestAccount() async {
    AppSettings appSettings = Get.find();
    saved.savedPhone = registeringPhone.text;
    saved.savedHashedPassword = appSettings.generateRandomString();
    guestAccount.value.hashedPassword = saved.savedHashedPassword;
    await conn.sendServerCommand(ServerCommand(
            bindAccountCommand: BindAccountCommand(
              enteredOtpCode: enteringOtpCode.text,
              action: BindAccountCommandAction.update,
              guest: guestAccount.value,
            )
        )
    );
    DateTime now = DateTime.now();
    var resp = await conn.sendServerCommand(ServerCommand(
        guestLoginCommand: GuestLoginCommand(
            phone: saved.savedPhone!,
            actuatedHashedPassword: SharedApi.actuatedHashedPassword(saved.savedPhone!, saved.savedHashedPassword!, now),
            time: now
        )
    ));
    guestLoginResponse = resp.guestLoginResponse;
    saved.loggedIn = true;
    saveState();
    await performAfterLogin();
  }

  void saveState() {
    AppSettings appSettings = Get.find();
    const validScreens = [GuestAppScreen.coupons, GuestAppScreen.favoriteCoupons, GuestAppScreen.guestAccount];
    if (validScreens.contains(currentScreen.value)) {
      saved.currentScreen = currentScreen.value;
    }
    appSettings.saveGuestAppSavedState(saved);
  }

  Future<void> updateGuestAccountAfterLogin() async {
    await sendServerCommand(ServerCommand(
      updateGuestCommand: UpdateGuestCommand(
        guest: guestAccount.value
      )
    ));
    await queryGuestInfo();
  }

  void logout() {
    AppSettings appSettings = Get.find();
    saved = GuestAppSavedState();
    conn = appSettings.createServerConnection();
    registeringPhone.text = '';
    enteringOtpCode.text = '';
    currentScreen.value = GuestAppScreen.bindScreen;
    redeemPolicyQueryResult = [];
    update(['redeemPolicyQueryResult']);
    saveState();
  }

  @override
  void onInit() {
    super.onInit();
    currentScreen.listen((value) async {
      if (guestLoginResponse != null) {
        if (value == GuestAppScreen.guestAccount) {
          await queryGuestInfo();
        }
      }
    });
  }

  Future<void> queryGuestInfo() async {
    var resp = await sendServerCommand(ServerCommand(
        queryGuestInfoCommand: QueryGuestInfoCommand()
    ));
    if (resp.queryGuestInfoResponse != null) {
      if (resp.queryGuestInfoResponse!.guest != null) {
        guestAccount.value = resp.queryGuestInfoResponse!.guest!;
      }
      if (resp.queryGuestInfoResponse!.pointsRemaining != null) {
        pointsRemaining.value = resp.queryGuestInfoResponse!.pointsRemaining!;
      }
    }
  }

  Future<ServerResponse> sendServerCommand(ServerCommand cmd) async {
    try {
      UiTransientState.instance.setSystemBusy(true);
      return await conn.sendServerCommand(cmd);
    }
    on ServerException catch(e) {
      UiTransientState.instance.setSystemBusy(false);
      if (e.type == ServerResponseType.notAuthenticated) {
        if (await confirmDialog(content: "adminApp.disconnectPrompt".tr)) {
          try {
            await guestLogin();
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

  Future<void> queryXtranGuest() async {
    var resp = await sendServerCommand(ServerCommand(
      queryTransactionCommand: QueryTransactionCommand(),
    ));
    xtranQueryResult.value = resp.queryTransactionResponse?.result ?? [];
  }

  Future<String> generateCodeForPolicy(int policyId) async {
    var resp = await sendServerCommand(ServerCommand(
      generateCodeCommand: GenerateCodeCommand(
        generateForRedeemPolicyId: policyId
      )
    ));
    return resp.generateCodeResponse!.code;
  }

}