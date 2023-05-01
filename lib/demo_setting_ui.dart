/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:developer';

import 'package:card_settings/card_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:protocol/client_state.dart';

import 'admin_app/admin_app.dart';
import 'app_settings.dart';
import 'card_settings_fixes.dart';
import 'guest_app/guest_app.dart';
import 'languages.dart';
import 'testing_keys.dart';
import 'ui_shared.dart';
import 'welcome_app/welcome_app.dart';

class DemoSettingScreen extends StatefulWidget {
  const DemoSettingScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DemoSettingScreenState();
  }
}

class ServerModeItem {
  final ServerMode mode;
  const ServerModeItem(this.mode);
  @override
  String toString() {
    return 'serverMode.${mode.name}'.tr;
  }
}

const serverModeItems = [ServerModeItem(ServerMode.local), ServerModeItem(ServerMode.remote)];

ServerModeItem findServerModeItem(ServerMode mode) {
  return serverModeItems.firstWhere((item)=>item.mode == mode);
}

class _DemoSettingScreenState extends State<DemoSettingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    return Scaffold(
        appBar: AppBar(
          title: Text('main.demoSettings'.tr),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Form(
                        key: _formKey,
                        child: CardSettings(
                            showMaterialonIOS: true,
                            labelWidth: 150,
                            contentAlign: TextAlign.left,
                            //margin: const EdgeInsets.all(20),
                            children: <CardSettingsSection>[
                              CardSettingsSection(
                                  header: CardSettingsHeader(
                                    label: 'gen.appearance'.tr,
                                  ),
                                  children: <CardSettingsWidget>[
                                    CardSettingsSwitch(
                                      key: TestingKeys.darkModeSwitch,
                                      label: 'gen.darkMode'.tr,
                                      trueLabel: 'gen.yes'.tr,
                                      falseLabel: 'gen.no'.tr,
                                      initialValue: appSettings.isDarkTheme.value,
                                      onChanged: (value) async {
                                        appSettings.isDarkTheme.value = value;
                                        log('changeDarkMode1: $value');
                                        Get.changeTheme(buildTheme(value ? Brightness.dark : Brightness.light));
                                        await Get.forceAppUpdate();
                                        appSettings.saveState();
                                      },
                                    ),
                                    CardSettingsRadioPicker<LanguageOption>(
                                      key: TestingKeys.languagePick,
                                      label: 'gen.language'.tr,
                                      items: Languages.languageOptions,
                                      initialItem: appSettings.language.value,
                                      validator: (LanguageOption? value) {
                                        if (value == null) {
                                          return 'You must pick an item.';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) async {
                                        await appSettings.reloadAppAssets(value.locale.toString());
                                        appSettings.language.value = value;
                                        log('updating locale to: ${value.locale}');
                                        Get.updateLocale(value.locale);
                                        appSettings.saveState();
                                      },
                                    )
                                  ]
                              ),
                              CardSettingsSection(
                                  header: CardSettingsHeader(
                                    label: 'main.screenSelection'.tr,
                                  ),
                                  children: <CardSettingsWidget>[
                                    CardFieldLayout2(
                                        <CardSettingsWidget>[
                                          CardSettingsButton2(
                                            label: 'main.welcomeScreen'.tr,
                                            backgroundColor: appSettings.mode.value == AppMode.welcomeScreen ? Colors.red : Colors.indigo,
                                            onPressed: () async {
                                              WelcomeApp welcomeApp = Get.find();
                                              await welcomeApp.bringUpApp();
                                              appSettings.mode.value = AppMode.welcomeScreen;
                                              Get.back();
                                              appSettings.saveState();
                                            },
                                          ),
                                          CardSettingsButton2(
                                            key: TestingKeys.adminAppBtn,
                                            label: 'adminApp.app'.tr,
                                            backgroundColor: appSettings.mode.value == AppMode.adminApp ? Colors.red : Colors.indigo,
                                            onPressed: () async {
                                              AdminApp adminApp = Get.find();
                                              await adminApp.bringUpApp();
                                              appSettings.mode.value = AppMode.adminApp;
                                              Get.back();
                                              appSettings.saveState();
                                            },
                                          ),
                                          CardSettingsButton2(
                                            key: TestingKeys.guestAppBtn,
                                            label: 'guestApp.app'.tr,
                                            backgroundColor: appSettings.mode.value == AppMode.guestApp ? Colors.red : Colors.indigo,
                                            onPressed: () async {
                                              GuestApp guestApp = Get.find();
                                              await guestApp.bringUpApp();
                                              appSettings.mode.value = AppMode.guestApp;
                                              Get.back();
                                              appSettings.saveState();
                                            },
                                          ),
                                        ]
                                    ),
                                  ]
                              ),
                              CardSettingsSection(
                                  header: CardSettingsHeader(
                                    label: "main.serverOptions".tr,
                                  ),
                                  children: <CardSettingsWidget>[
                                    CardSettingsRadioPicker<ServerModeItem>(
                                      label: "main.serverMode".tr,
                                      items: const [ServerModeItem(ServerMode.local), ServerModeItem(ServerMode.remote)],
                                      initialItem: findServerModeItem(appSettings.state.serverMode),
                                      validator: (ServerModeItem? value) {
                                        if (value == null) {
                                          return 'You must pick an item.';
                                        }
                                        return null;
                                      },
                                      onChanged: (value) async {
                                        appSettings.state.serverMode = value.mode;
                                        appSettings.saveState();
                                        appSettings.serverTypeChanged();
                                      },
                                    ),
                                    CardSettingsText(
                                      key: TestingKeys.serverUrlEdit,
                                      label: "main.serverUrl".tr,
                                      maxLength: 500,
                                      initialValue: appSettings.state.serverUrl,
                                      onChanged: (value) async {
                                        appSettings.state.serverUrl = value;
                                        appSettings.saveState();
                                        appSettings.serverTypeChanged();
                                      },
                                    ),
                                  ]
                              ),

                            ]
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
        )
    );
  }
}
