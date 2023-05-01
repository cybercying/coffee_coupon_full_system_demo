/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:async';
import 'dart:convert';
import 'dart:math' show Random;

import 'package:flutter/services.dart';

import 'ui_shared.dart' show buildTheme, uiNotifyReceivedSMS;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:protocol/client_state.dart';
import 'package:protocol/protocol.dart';
import 'package:protocol/test_data.dart';
import 'package:server/db_util.dart';
import 'admin_app/admin_app.dart';
import 'guest_app/guest_app.dart';
import 'languages.dart';
import 'welcome_app/welcome_app.dart';

class AppException implements Exception {
  String message;

  AppException([this.message = 'App internal error']);

  @override
  String toString() {
    return "AppException: $message";
  }
}

class MockNotificationListener {
  ServerConnection conn;
  MockDevice receiver;
  bool isShutdown = false;
  int unreadCount = 0;
  late AppSettings appSettings;
  final inbox = RxList<MockMessage>();
  Set<int> existingIds = {};

  MockNotificationListener({
    required this.conn,
    required this.receiver,
  });

  Future<void> queryMockMessage() async {
    List<MockMessageQuery> queryList = [];
    var email = receiver.email;
    if (email != null) {
      queryList.add(MockMessageQuery(queryType: MockMessageQueryType.email, email: email));
    }
    var phone = receiver.phone;
    if (phone != null) {
      queryList.add(MockMessageQuery(queryType: MockMessageQueryType.phone, phone: phone));
    }
    var resp = await conn.sendServerCommand(ServerCommand(
        queryMockMessageCommand: QueryMockMessageCommand(queryList: queryList)
      )
    );
    var result = resp.queryMockMessageResponse!.result;
    unreadCount = 0;
    for(var r in result) {
      if (r.read ?? false == false) {
        unreadCount ++;
      }
    }
    appSettings.updateMockReceiver();
    inbox.value = result;
    if (appSettings.isMessageNotificationOn) {
      List<MockMessage> newMsg = [];
      for (var m in inbox) {
        if (!existingIds.contains(m.id)) { // is new message?
          existingIds.add(m.id!);
          newMsg.add(m);
        }
      }
      if (newMsg.isNotEmpty) {
        appSettings.notifyNewMessages(newMsg);
      }
    }
  }

  Future<void> runListeningLoop() async {
    var waitList = <NotificationSpec>[];
    if (receiver.phone != null) {
      waitList.add(NotificationSpec(
        id: 0,
        type: NotificationType.mockMessageForPhone,
        phone: receiver.phone
      ));
    }
    if (receiver.email != null) {
      waitList.add(NotificationSpec(
          id: 1,
          type: NotificationType.mockMessageForEmail,
          email: receiver.email
      ));
    }
    await queryMockMessage(); // initial query
    if (waitList.isNotEmpty) {
      while(!isShutdown) {
        var waitForNotificationCommand = WaitForNotificationCommand(
            waitList: waitList,
            waitSeconds: 30
        );
        //log('waitForNotification: ${receiver.type}, cmd: ${waitForNotificationCommand.toJson()}');
        ServerResponse resp = await conn.sendServerCommand(
          ServerCommand(waitForNotificationCommand:
          waitForNotificationCommand
          )
        );
        //log('waitForNotification.1: ${receiver.type}, ids: ${resp.waitForNotificationResponse!.eventfulIds}');
        if (resp.waitForNotificationResponse!.eventfulIds.isNotEmpty) {
          await queryMockMessage();
        }
      }
    }
  }

  void beginListenServerNotification() {
    appSettings = Get.find();
    runListeningLoop();
  }

  void shutdown() {
    isShutdown = true;
    conn.shutdown();
  }
}

class AppAssets {
  String welcomeMarkdown;
  String readmeMarkdown;
  String dataSetupMarkdown;
  String userStoryMarkdown;
  String userDataMarkdown;
  AppAssets({
      this.welcomeMarkdown = _loadingPlaceholder,
      this.readmeMarkdown = _loadingPlaceholder,
      this.dataSetupMarkdown = _loadingPlaceholder,
      this.userStoryMarkdown = _loadingPlaceholder,
      this.userDataMarkdown = _loadingPlaceholder,
  });
}

class AppTheme {
  final Color managingStoreColor;
  final Color couponCardColor;
  final Color topPanelShadowColor;
  final Color queryPanelColor;
  final Color adminAppNavigationBarColor;
  final Color textColor;
  final Color pointsIndicatorBackgroundColor;

  AppTheme({
    required this.managingStoreColor,
    required this.couponCardColor,
    required this.topPanelShadowColor,
    required this.queryPanelColor,
    required this.adminAppNavigationBarColor,
    required this.textColor,
    required this.pointsIndicatorBackgroundColor,
  });

  static final dark = AppTheme(
      managingStoreColor: Colors.orange[900]!,
      couponCardColor: Colors.grey[700]!,
      topPanelShadowColor: Colors.grey[900]!,
      queryPanelColor: Colors.cyan[900]!,
      adminAppNavigationBarColor: Colors.cyan[900]!,
      textColor: Colors.white,
      pointsIndicatorBackgroundColor: Colors.lightBlue[200]!.withOpacity(0.75),
  );

  static final light = AppTheme(
      managingStoreColor: Colors.orange[300]!,
      couponCardColor: Colors.white,
      topPanelShadowColor: Colors.grey[400]!,
      queryPanelColor: Colors.cyan[100]!,
      adminAppNavigationBarColor: Colors.blue[100]!,
      textColor: Colors.black,
    pointsIndicatorBackgroundColor: Colors.lightBlue[200]!.withOpacity(0.75),
  );
}

const _loadingPlaceholder = 'Loading...';
// const _appAssetPathPrefix = 'assets'; // working if run locally
// const _appAssetPathPrefix = 'packages/coffee_coupon_full_system_demo/assets'; // working if run as package

class AppSettings extends GetxController {
  static const hiveKey = 'mainApp';

  final isDarkTheme = false.obs;
  final mode = Rx(AppMode.welcomeScreen);
  final language = Languages.enUS.obs;
  final clientBox = Hive.box('client');
  var state = AppSettingsSavedState();
  final languages = Languages();
  List<MockNotificationListener> mockListeners = [];
  int totalUnreadCount = 0;
  MockDevice? selectedMockDevice;
  AppConfig appConfig;
  AppAssets appAssets = AppAssets();
  bool isMessageNotificationOn = false;
  AppTheme appTheme = AppTheme.light;

  AppSettings(this.appConfig);

  ServerConnection createServerConnection() {
    switch(state.serverMode) {
      case ServerMode.local:
        return LocalServerConnection(du: Get.find());
      case ServerMode.remote:
        return HttpServerConnection(Uri.parse(state.serverUrl));
    }
  }

  void updateMockReceiver() {
    totalUnreadCount = 0;
    for(var l in mockListeners) {
      totalUnreadCount += l.unreadCount;
    }
    update(['mockReceiverList']);
  }

  Future<void> reInit({String? defaultLocale}) async {
    state = AppSettingsSavedState();
    mode.value = AppMode.welcomeScreen;
    language.value = Languages.enUS;
    isDarkTheme.value = false;
    await init(defaultDeviceSetting: defaultLocale != null ? DeviceSettings(locale: defaultLocale) : null);
  }

  Future<void> init({DeviceSettings? defaultDeviceSetting}) async {
    var json = clientBox.get(hiveKey);
    if (json!=null) {
      state = AppSettingsSavedState.fromJson(SharedApi.fixHiveJsonType(json));
    }
    state.currentMockDevice ??= 0;
    if ((state.dataVersion ?? 0) < 1 || state.mockReceiverList.isEmpty) {
      var guests = GuestData();
      var users = UserData();
      state.dataVersion = 1;
      void addMockDevice({required String description, String? email, String? phone}) {
        DeviceSettings? deviceSettings = defaultDeviceSetting?.copyWith();
        state.mockReceiverList.add(MockDevice(description: description, email: email, phone: phone, deviceSettings: deviceSettings));
      }
      addMockDevice(description: 'Brynn\'s phone', email: users.brynn.email, phone: users.brynn.phone);
      addMockDevice(description: 'Lazar\'s phone', email: users.lazar.email, phone: users.lazar.phone);
      addMockDevice(description: 'Tersina\'s phone', email: users.tersina.email, phone: users.tersina.phone);
      addMockDevice(description: 'Madeline\'s phone', email: users.madeline.email, phone: users.madeline.phone);
      addMockDevice(description: 'Haskell\'s phone', phone: guests.haskell.phone);
      addMockDevice(description: 'Shawn\'s phone', phone: guests.shawn.phone);
      saveState(initialSave: true);
    }
    if (state.currentMockDevice! >= state.mockReceiverList.length - 1) {
      state.currentMockDevice = state.mockReceiverList.length - 1;
    }
    refreshMockListeners();
    if (appConfig.overrideCurrentDevice != null) {
      state.currentMockDevice = appConfig.overrideCurrentDevice;
    }
    await loadDeviceSettings();
    Future.delayed(const Duration(milliseconds: 100)).then((_){
      isMessageNotificationOn = true;
    });
  }

  void refreshMockListeners() {
    var list = state.mockReceiverList.toList(); // make a copy
    var toRemove = <MockNotificationListener>[];
    for(var l in mockListeners) {
      if (list.contains(l.receiver)) {
        list.remove(l.receiver); // remove existing, so the what remaining in list must be newly added
      }
      else {
        // this listener must be terminated
        toRemove.add(l);
      }
    }
    for(var l in toRemove) {
      l.shutdown();
      mockListeners.remove(l);
    }
    for(var m in list) {
      var listener = MockNotificationListener(
          conn: createServerConnection(),
          receiver: m
      );
      listener.beginListenServerNotification();
      mockListeners.add(listener);
    }
  }

  Timer? _serverTypeChangedTimer;

  void serverTypeChanged() {
    _serverTypeChangedTimer?.cancel();
    _serverTypeChangedTimer ??= Timer(const Duration(seconds: 1), () {
      _serverTypeChangedTimer = null;
      for(var l in mockListeners) {
        l.shutdown();
      }
      mockListeners = [];
      refreshMockListeners();
      updateMockReceiver();
    });
  }

  DeviceSettings currentDeviceSettings() {
    var device = state.mockReceiverList[state.currentMockDevice!];
    device.deviceSettings ??= DeviceSettings();
    return device.deviceSettings!;
  }

  MockDevice currentMockDevice() {
    return state.mockReceiverList[state.currentMockDevice!];
  }

  Future<void> loadDeviceSettings() async {
    var deviceSettings = currentDeviceSettings();
    isDarkTheme.value = deviceSettings.isDarkTheme ?? false;
    mode.value = deviceSettings.appMode ?? AppMode.welcomeScreen;
    language.value =  Languages.getLanguageOption(deviceSettings.locale);
    await reloadAppAssets(language.value.locale.toString());
    if (mode.value == AppMode.adminApp) {
      AdminApp adminApp = Get.find();
      await adminApp.bringUpApp();
    }
    else if (mode.value == AppMode.guestApp) {
      GuestApp guestApp = Get.find();
      await guestApp.bringUpApp();
    }
    else if (mode.value == AppMode.welcomeScreen) {
      WelcomeApp welcomeApp = Get.find();
      await welcomeApp.bringUpApp();
    }
    Get.changeTheme(buildTheme(isDarkTheme.value ? Brightness.dark : Brightness.light));
    Get.updateLocale(language.value.locale);
  }

  String replaceAssetString(String locale, String input) {
    String? inputTr = languages.keys[locale]?[input];
    inputTr ??= languages.keys["en_US"]![input]!;
    rootBundle.evict(inputTr);
    return inputTr
        .replaceAll("{r}", appConfig.appAssetPathPrefix)
        .replaceAll("{md}", '${appConfig.appAssetPathPrefix}assets/markdown/');
  }

  Future<void> reloadAppAssets(String locale) async {
    appAssets = AppAssets(
        welcomeMarkdown: await rootBundle.loadString(
            replaceAssetString(locale, 'main.welcomeMarkdown')),
        readmeMarkdown: await rootBundle.loadString(
            replaceAssetString(locale, 'main.readmeMarkdown')),
        dataSetupMarkdown: await rootBundle.loadString(
            replaceAssetString(locale, "main.dataSetupMarkdown")),
        userStoryMarkdown: await rootBundle.loadString(
            replaceAssetString(locale, 'main.userStoryMarkdown')),
        userDataMarkdown: await rootBundle.loadString(
            replaceAssetString(locale, 'main.userDataMarkdown')),
    );
  }

  Timer? _writeStateLaterTimer;

  void saveState({bool? initialSave}) {
    if (!(initialSave ?? false)) {
      var deviceSettings = currentDeviceSettings();
      deviceSettings.isDarkTheme = isDarkTheme.value;
      deviceSettings.appMode = mode.value;
      deviceSettings.locale = language.value.locale.toString();
    }
    _writeStateLaterTimer ??= Timer(const Duration(milliseconds: 100), () async {
      _writeStateLaterTimer = null;
      await clientBox.put(hiveKey, state.toJson());
    });
  }

  Future<void> onMockDeviceChanged(MockDevice mockDevice, {bool isCreate = false, bool isDelete = false}) async {
    if (isCreate) {
      state.mockReceiverList.add(mockDevice);
      refreshMockListeners();
    }
    else if (isDelete) {
      MockDevice currentDevice = state.mockReceiverList[state.currentMockDevice!];
      int i = state.mockReceiverList.indexWhere((element)=>element == selectedMockDevice);
      if (i == -1) {
        throw AppException('mockReceiver not found in existing list');
      }
      else if (i == state.currentMockDevice) {
        throw AppException('Cannot delete current device');
      }
      else {
        state.mockReceiverList.removeAt(i);
      }
      state.currentMockDevice = state.mockReceiverList.indexOf(currentDevice);
      refreshMockListeners();
    }
    else {
      int i = state.mockReceiverList.indexWhere((element)=>element == selectedMockDevice);
      if (i == -1) {
        throw AppException('mockReceiver not found in existing list');
      }
      state.mockReceiverList[i] = mockDevice;
      mockListeners[i].shutdown();
      mockListeners[i] = MockNotificationListener(
          conn: createServerConnection(),
          receiver: mockDevice);
      mockListeners[i].beginListenServerNotification();
    }
    saveState();
    updateMockReceiver();
  }

  WelcomeAppSavedState? loadWelcomeAppSavedState() {
    return state.mockReceiverList[state.currentMockDevice!].welcomeAppSavedState;
  }

  void saveWelcomeAppSavedState(WelcomeAppSavedState? saved) {
    state.mockReceiverList[state.currentMockDevice!].welcomeAppSavedState = saved;
    saveState();
  }

  AdminAppSavedState? loadAdminAppSavedState() {
    return state.mockReceiverList[state.currentMockDevice!].adminAppSavedState;
  }

  void saveAdminAppSavedState(AdminAppSavedState? saved) {
    state.mockReceiverList[state.currentMockDevice!].adminAppSavedState = saved;
    saveState();
  }

  void saveGuestAppSavedState(GuestAppSavedState? saved) {
    state.mockReceiverList[state.currentMockDevice!].guestAppSavedState = saved;
    saveState();
  }

  bool isSelectedMockDeviceCurrentlyActive() {
    if (selectedMockDevice == null) {
      return false;
    }
    else {
      return state.mockReceiverList.indexOf(selectedMockDevice!) == state.currentMockDevice;
    }
  }

  DateFormat? dfmt;
  DateFormat? dfmtDetailed;
  Locale? cachedLocale;

  String? fmtDate(DateTime? dt, {bool detailed = false}) {
    var locale = Get.locale;
    if (cachedLocale != locale) {
      dfmt = DateFormat.yMd(locale.toString());
      dfmtDetailed = DateFormat.yMd(locale.toString()).add_Hm();
      cachedLocale = locale;
    }
    if (dt == null) {
      return null;
    }
    if (detailed) {
      return dfmtDetailed!.format(dt);
    }
    else {
      return dfmt!.format(dt);
    }
  }

  GuestAppSavedState? loadGuestAppSavedState() {
    return state.mockReceiverList[state.currentMockDevice!].guestAppSavedState;
  }

  Random random = Random.secure();

  String generateRandomString([int length = 32]) {
    var values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  void notifyNewMessages(List<MockMessage> newMsg) {
    if (appConfig.disableSnakebars) {
      return;
    }
    var device = currentMockDevice();
    for(var msg in newMsg) {
      if (device.phone != null && msg.phone == device.phone) {
        uiNotifyReceivedSMS('${device.phone} received SMS', msg.content ?? "(empty)");
      }
    }
  }

  Future<void> changeCurrentMockDevice({String? phone, String? email, String? descriptionContains}) async {
    if (phone == null && email == null && descriptionContains == null) {
      throw Exception("Must specify at least one condition");
    }
    int indexFound = -1;
    for(var i=0;i<state.mockReceiverList.length;i++) {
      var device = state.mockReceiverList[i];
      if (device.phone != null && phone != null && device.phone == phone) {
        indexFound = i;
        break;
      }
      if (device.email != null && email != null && device.email == email) {
        indexFound = i;
        break;
      }
      if (device.description != null && descriptionContains != null && device.description!.contains(descriptionContains)) {
        indexFound = i;
        break;
      }
    }
    if (indexFound == -1) {
      throw Exception("Cannot find a specified mock device");
    }
    if (state.currentMockDevice != indexFound) {
      await changeCurrentMockDeviceByIndex(indexFound);
    }
  }

  Future<void> changeCurrentMockDeviceByIndex(int index) async {
    if (state.currentMockDevice != index) {
      saveState();
      state.currentMockDevice = index;
      await loadDeviceSettings();
    }
  }

  Future<void> changeToAppMode(AppMode newMode) async {
    if (mode.value == newMode) {
      return;
    }
    saveState();
    if (newMode == AppMode.welcomeScreen) {
      WelcomeApp welcomeApp = Get.find();
      await welcomeApp.bringUpApp();
      mode.value = AppMode.welcomeScreen;
    }
    else if (newMode == AppMode.adminApp) {
      AdminApp adminApp = Get.find();
      await adminApp.bringUpApp();
      mode.value = AppMode.adminApp;
    }
    else if (newMode == AppMode.guestApp) {
      GuestApp guestApp = Get.find();
      await guestApp.bringUpApp();
      mode.value = AppMode.guestApp;
    }
    else {
      throw UnimplementedError();
    }
  }

  @override
  void onInit() {
    super.onInit();
    isDarkTheme.listen((value) {
      appTheme = value ? AppTheme.dark : AppTheme.light;
    });
  }

  Future<void> changeLocaleIfValid(String loc) async {
     var l = Languages.getLanguageOptionNull(loc);
     if (l != null && language.value != l) {
       language.value = l;
       await reloadAppAssets(language.value.locale.toString());
       Get.updateLocale(language.value.locale);
       saveState();
     }
  }

// Future<void> saveScreenshotToFile(GlobalKey scr) async {
  //   RenderRepaintBoundary boundary = scr.currentContext!.findRenderObject() as RenderRepaintBoundary;
  //   var image = await boundary.toImage();
  //   var byteData = await image.toByteData(format: ImageByteFormat.png);
  //   var dir = Directory('${appConfig.dir ?? '.'}/snapshot');
  //   if (!await dir.exists()) {
  //     await dir.create();
  //   }
  //   DateTime now = DateTime.now();
  //   DateFormat df = DateFormat('yyyy-MM-dd-HHmmss');
  //   var file = File('${dir.path}/snapshot-${df.format(now)}.png');
  //   await file.writeAsBytes(byteData!.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  //   log('saveScreenshotToFile(): size: ${byteData.lengthInBytes}, file: ${file.path}');
  // }
}

