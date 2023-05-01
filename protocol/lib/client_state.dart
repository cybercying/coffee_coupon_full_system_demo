/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'package:json_annotation/json_annotation.dart';

part 'client_state.g.dart';

enum AppMode {
  welcomeScreen,
  adminApp,
  guestApp,
}

enum ServerMode {
  local,
  remote,
}

@JsonSerializable()
class AppConfig {
  final String appAssetPathPrefix;
  final int? overrideCurrentDevice;
  final String? dir;
  final bool disableTransition;
  final bool disableSnakebars;
  final bool disableListViewBuilder;
  final bool useMouseToDrag;
  final String? updateTranslationFilesPathPrefix;
  final bool startupErrorHandling;
  const AppConfig({
    required this.appAssetPathPrefix,
    this.overrideCurrentDevice,
    this.dir,
    this.disableTransition = false,
    this.disableSnakebars = false,
    this.disableListViewBuilder = false,
    this.useMouseToDrag = false,
    this.updateTranslationFilesPathPrefix,
    this.startupErrorHandling = true,
  });
  AppConfig copyWith({String? dir, String? appAssetPathPrefix, bool? useMouseToDrag}) {
    var json = toJson();
    if (dir != null) {
      json['dir'] = dir;
    }
    if (appAssetPathPrefix != null) {
      json['appAssetPathPrefix'] = appAssetPathPrefix;
    }
    if (useMouseToDrag != null) {
      json['useMouseToDrag'] = useMouseToDrag;
    }
    return AppConfig.fromJson(json);
  }
  factory AppConfig.fromJson(Map<String, dynamic> json) =>
      _$AppConfigFromJson(json);
  Map<String, dynamic> toJson() => _$AppConfigToJson(this);
}

@JsonSerializable()
class WelcomeAppSavedState {
  int currentPageIndex = 0;
  WelcomeAppSavedState();
  factory WelcomeAppSavedState.fromJson(Map<String, dynamic> json) =>
      _$WelcomeAppSavedStateFromJson(json);
  Map<String, dynamic> toJson() => _$WelcomeAppSavedStateToJson(this);
}

@JsonSerializable()
class MockDevice {
  String? email;
  String? phone;
  String? description;

  MockDevice({
    this.email,
    this.phone,
    this.description,
    this.deviceSettings,
  });
  AdminAppSavedState? adminAppSavedState;
  GuestAppSavedState? guestAppSavedState;
  WelcomeAppSavedState? welcomeAppSavedState;
  DeviceSettings? deviceSettings;
  factory MockDevice.fromJson(Map<String, dynamic> json) =>
      _$MockDeviceFromJson(json);
  Map<String, dynamic> toJson() => _$MockDeviceToJson(this);

  @override
  String toString() {
    return 'MockDevice{email: $email, phone: $phone, description: $description, adminAppSavedState: $adminAppSavedState, guestAppSavedState: $guestAppSavedState, welcomeAppSavedState: $welcomeAppSavedState, deviceSettings: $deviceSettings}';
  }
}

@JsonSerializable()
class DeviceSettings {
  String? locale;
  bool? isDarkTheme;
  AppMode? appMode;
  DeviceSettings({this.locale});
  factory DeviceSettings.fromJson(Map<String, dynamic> json) =>
      _$DeviceSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceSettingsToJson(this);

  @override
  String toString() {
    return 'DeviceSettings{locale: $locale, isDarkTheme: $isDarkTheme, appMode: $appMode}';
  }
  DeviceSettings? copyWith() {
    var json = toJson();
    return DeviceSettings.fromJson(json);

  }
}

@JsonSerializable()
class AppSettingsSavedState {
  List<MockDevice> mockReceiverList = [];
  int? dataVersion;
  int? currentMockDevice;
  ServerMode serverMode = ServerMode.local;
  String serverUrl = '';
  AppSettingsSavedState();
  factory AppSettingsSavedState.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsSavedStateFromJson(json);
  Map<String, dynamic> toJson() => _$AppSettingsSavedStateToJson(this);

  @override
  String toString() {
    return 'AppSettingsSavedState{mockReceiverList: $mockReceiverList, dataVersion: $dataVersion, currentMockDevice: $currentMockDevice, serverMode: $serverMode, serverUrl: $serverUrl}';
  }
}

enum AdminAppScreen {
  loginScreen,
  userListScreen,
  storeListScreen,
  redeemPolicyListScreen,
  xtranListScreen,
}

@JsonSerializable()
class AdminAppSavedState {
  String? savedEmail;
  String? savedHashedPassword;
  bool? loggedIn;
  int? managingStoreId;
  AdminAppScreen? screen;
  AdminAppSavedState();
  factory AdminAppSavedState.fromJson(Map<String, dynamic> json) =>
      _$AdminAppSavedStateFromJson(json);
  Map<String, dynamic> toJson() => _$AdminAppSavedStateToJson(this);
}

@JsonSerializable()
class DataTesterState {
  String? rootUser;
  int dataVersion = 0;
  DataTesterState();
  factory DataTesterState.fromJson(Map<String, dynamic> json) =>
      _$DataTesterStateFromJson(json);
  Map<String, dynamic> toJson() => _$DataTesterStateToJson(this);
}

enum GuestAppScreen {
  bindScreen,
  otpCodeVerifyScreen,
  updateGuestAccount,
  coupons,
  favoriteCoupons,
  stores,
  guestAccount,
}

@JsonSerializable()
class GuestAppSavedState {
  String? savedPhone;
  String? savedHashedPassword;
  bool? loggedIn;
  GuestAppScreen currentScreen = GuestAppScreen.coupons;
  GuestAppSavedState();
  factory GuestAppSavedState.fromJson(Map<String, dynamic> json) =>
      _$GuestAppSavedStateFromJson(json);
  Map<String, dynamic> toJson() => _$GuestAppSavedStateToJson(this);
}
