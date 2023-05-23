// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig(
      appAssetPathPrefix: json['appAssetPathPrefix'] as String,
      overrideCurrentDevice: json['overrideCurrentDevice'] as int?,
      dir: json['dir'] as String?,
      disableTransition: json['disableTransition'] as bool? ?? false,
      disableSnackbar: json['disableSnackbar'] as bool? ?? false,
      disableListViewBuilder: json['disableListViewBuilder'] as bool? ?? false,
      useMouseToDrag: json['useMouseToDrag'] as bool? ?? false,
      updateTranslationFilesPathPrefix:
          json['updateTranslationFilesPathPrefix'] as String?,
      startupErrorHandling: json['startupErrorHandling'] as bool? ?? true,
    );

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) {
  final val = <String, dynamic>{
    'appAssetPathPrefix': instance.appAssetPathPrefix,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('overrideCurrentDevice', instance.overrideCurrentDevice);
  writeNotNull('dir', instance.dir);
  val['disableTransition'] = instance.disableTransition;
  val['disableSnackbar'] = instance.disableSnackbar;
  val['disableListViewBuilder'] = instance.disableListViewBuilder;
  val['useMouseToDrag'] = instance.useMouseToDrag;
  writeNotNull('updateTranslationFilesPathPrefix',
      instance.updateTranslationFilesPathPrefix);
  val['startupErrorHandling'] = instance.startupErrorHandling;
  return val;
}

WelcomeAppSavedState _$WelcomeAppSavedStateFromJson(
        Map<String, dynamic> json) =>
    WelcomeAppSavedState()..currentPageIndex = json['currentPageIndex'] as int;

Map<String, dynamic> _$WelcomeAppSavedStateToJson(
        WelcomeAppSavedState instance) =>
    <String, dynamic>{
      'currentPageIndex': instance.currentPageIndex,
    };

MockDevice _$MockDeviceFromJson(Map<String, dynamic> json) => MockDevice(
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      deviceSettings: json['deviceSettings'] == null
          ? null
          : DeviceSettings.fromJson(
              json['deviceSettings'] as Map<String, dynamic>),
    )
      ..adminAppSavedState = json['adminAppSavedState'] == null
          ? null
          : AdminAppSavedState.fromJson(
              json['adminAppSavedState'] as Map<String, dynamic>)
      ..guestAppSavedState = json['guestAppSavedState'] == null
          ? null
          : GuestAppSavedState.fromJson(
              json['guestAppSavedState'] as Map<String, dynamic>)
      ..welcomeAppSavedState = json['welcomeAppSavedState'] == null
          ? null
          : WelcomeAppSavedState.fromJson(
              json['welcomeAppSavedState'] as Map<String, dynamic>);

Map<String, dynamic> _$MockDeviceToJson(MockDevice instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('email', instance.email);
  writeNotNull('phone', instance.phone);
  writeNotNull('description', instance.description);
  writeNotNull('adminAppSavedState', instance.adminAppSavedState?.toJson());
  writeNotNull('guestAppSavedState', instance.guestAppSavedState?.toJson());
  writeNotNull('welcomeAppSavedState', instance.welcomeAppSavedState?.toJson());
  writeNotNull('deviceSettings', instance.deviceSettings?.toJson());
  return val;
}

DeviceSettings _$DeviceSettingsFromJson(Map<String, dynamic> json) =>
    DeviceSettings(
      locale: json['locale'] as String?,
    )
      ..isDarkTheme = json['isDarkTheme'] as bool?
      ..appMode = $enumDecodeNullable(_$AppModeEnumMap, json['appMode']);

Map<String, dynamic> _$DeviceSettingsToJson(DeviceSettings instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('locale', instance.locale);
  writeNotNull('isDarkTheme', instance.isDarkTheme);
  writeNotNull('appMode', _$AppModeEnumMap[instance.appMode]);
  return val;
}

const _$AppModeEnumMap = {
  AppMode.welcomeScreen: 'welcomeScreen',
  AppMode.adminApp: 'adminApp',
  AppMode.guestApp: 'guestApp',
};

AppSettingsSavedState _$AppSettingsSavedStateFromJson(
        Map<String, dynamic> json) =>
    AppSettingsSavedState()
      ..mockReceiverList = (json['mockReceiverList'] as List<dynamic>)
          .map((e) => MockDevice.fromJson(e as Map<String, dynamic>))
          .toList()
      ..dataVersion = json['dataVersion'] as int?
      ..currentMockDevice = json['currentMockDevice'] as int?
      ..serverMode = $enumDecode(_$ServerModeEnumMap, json['serverMode'])
      ..serverUrl = json['serverUrl'] as String;

Map<String, dynamic> _$AppSettingsSavedStateToJson(
    AppSettingsSavedState instance) {
  final val = <String, dynamic>{
    'mockReceiverList':
        instance.mockReceiverList.map((e) => e.toJson()).toList(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('dataVersion', instance.dataVersion);
  writeNotNull('currentMockDevice', instance.currentMockDevice);
  val['serverMode'] = _$ServerModeEnumMap[instance.serverMode]!;
  val['serverUrl'] = instance.serverUrl;
  return val;
}

const _$ServerModeEnumMap = {
  ServerMode.local: 'local',
  ServerMode.remote: 'remote',
};

AdminAppSavedState _$AdminAppSavedStateFromJson(Map<String, dynamic> json) =>
    AdminAppSavedState()
      ..savedEmail = json['savedEmail'] as String?
      ..savedHashedPassword = json['savedHashedPassword'] as String?
      ..loggedIn = json['loggedIn'] as bool?
      ..managingStoreId = json['managingStoreId'] as int?
      ..screen = $enumDecodeNullable(_$AdminAppScreenEnumMap, json['screen']);

Map<String, dynamic> _$AdminAppSavedStateToJson(AdminAppSavedState instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('savedEmail', instance.savedEmail);
  writeNotNull('savedHashedPassword', instance.savedHashedPassword);
  writeNotNull('loggedIn', instance.loggedIn);
  writeNotNull('managingStoreId', instance.managingStoreId);
  writeNotNull('screen', _$AdminAppScreenEnumMap[instance.screen]);
  return val;
}

const _$AdminAppScreenEnumMap = {
  AdminAppScreen.loginScreen: 'loginScreen',
  AdminAppScreen.userListScreen: 'userListScreen',
  AdminAppScreen.storeListScreen: 'storeListScreen',
  AdminAppScreen.redeemPolicyListScreen: 'redeemPolicyListScreen',
  AdminAppScreen.xtranListScreen: 'xtranListScreen',
};

DataTesterState _$DataTesterStateFromJson(Map<String, dynamic> json) =>
    DataTesterState()
      ..rootUser = json['rootUser'] as String?
      ..dataVersion = json['dataVersion'] as int;

Map<String, dynamic> _$DataTesterStateToJson(DataTesterState instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('rootUser', instance.rootUser);
  val['dataVersion'] = instance.dataVersion;
  return val;
}

GuestAppSavedState _$GuestAppSavedStateFromJson(Map<String, dynamic> json) =>
    GuestAppSavedState()
      ..savedPhone = json['savedPhone'] as String?
      ..savedHashedPassword = json['savedHashedPassword'] as String?
      ..loggedIn = json['loggedIn'] as bool?
      ..currentScreen =
          $enumDecode(_$GuestAppScreenEnumMap, json['currentScreen']);

Map<String, dynamic> _$GuestAppSavedStateToJson(GuestAppSavedState instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('savedPhone', instance.savedPhone);
  writeNotNull('savedHashedPassword', instance.savedHashedPassword);
  writeNotNull('loggedIn', instance.loggedIn);
  val['currentScreen'] = _$GuestAppScreenEnumMap[instance.currentScreen]!;
  return val;
}

const _$GuestAppScreenEnumMap = {
  GuestAppScreen.bindScreen: 'bindScreen',
  GuestAppScreen.otpCodeVerifyScreen: 'otpCodeVerifyScreen',
  GuestAppScreen.updateGuestAccount: 'updateGuestAccount',
  GuestAppScreen.coupons: 'coupons',
  GuestAppScreen.favoriteCoupons: 'favoriteCoupons',
  GuestAppScreen.stores: 'stores',
  GuestAppScreen.guestAccount: 'guestAccount',
};
