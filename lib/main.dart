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
import 'dart:io';
import 'dart:ui';

import 'app_settings.dart';
import 'guest_app/guest_app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:protocol/client_state.dart';

import 'admin_app/admin_app.dart';
import 'admin_app/admin_app_ui.dart';
import 'communication.dart';
import 'guest_app/guest_app.dart';
import 'languages.dart';
import 'ui_shared.dart';
import 'welcome_app/welcome_app.dart';
import 'welcome_app/welcome_screen.dart';

Future<void> initApp(AppConfig appConfig) async {
  Get.delete<AdminApp>();
  Get.delete<GuestApp>();
  Get.delete<UiTransientState>();
  Get.delete<AppSettings>();

  Get.put(AdminApp());
  Get.put(GuestApp());
  Get.put(WelcomeApp());
  Get.put(UiTransientState(appConfig));
  var appSettings = AppSettings(appConfig);
  Get.put(appSettings);
  await appSettings.init();
//  Languages().updateTranslationFiles(pathPrefix: appConfig.updateTranslationFilesPathPrefix);
}

Future<void> initServerAndApp(AppConfig appConfig) async {
  try {
    await initServer(
        dir: appConfig.dir != null ? Directory(appConfig.dir!) : null);
    if (appConfig.disableTransition) {
      Get.config(defaultTransition: Transition.noTransition);
    }
    else {
      Get.config(defaultTransition: Transition.rightToLeft);
    }
    await initApp(appConfig);
  }
  catch(e, st) {
    log("Error during starting app: error: $e, stackTrace: $st");
    if (appConfig.startupErrorHandling) {
      final completer = Completer();
      var theme = ThemeData.from(colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red));
      runApp(MaterialApp(
        theme: theme,
        home: Scaffold(
            appBar: AppBar(
              title: const Text("Startup recovery mode"),
            ),
            body: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const SizedBox(
                    width: double.infinity,
                    child: Text(
                      "It seems application startup has failed. In most cases this could be caused by database corruption or data version incompatibility. Would you like to reset the local database?",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 20),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                          child: SelectableText('Error: $e\n\nStack trace:\n$st')
                        ),
                      ),
                    )
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await resetServerDatabase();
                          completer.complete();
                        },
                        child: const Text('Reset database'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          exit(0);
                        },
                        child: const Text('Exit application'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          completer.complete();
                        },
                        child: const Text('Do nothing and continue'),
                      ),
                    ],
                  )
                ],
              ),
            )
          ),
        )
      );
      await completer.future;
    }
    else {
      rethrow;
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServerAndApp(const AppConfig(appAssetPathPrefix: '', useMouseToDrag: true));
  runApp(const MyApp());
}

class MyScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return buildFocus(context);
  }

  Widget buildFocus(BuildContext context) {
    AppSettings appSettings = Get.find();
    return GetMaterialApp(
        title: 'Flutter Demo',
        translations: appSettings.languages,
        locale: appSettings.language.value.locale,
        fallbackLocale: Languages.enUS.locale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        scrollBehavior: appSettings.appConfig.useMouseToDrag ? MyScrollBehavior() : null,
        supportedLocales: Languages.supportedLocales,
        theme: buildTheme(appSettings.isDarkTheme.value ? Brightness.dark : Brightness.light),
        debugShowCheckedModeBanner: false,
        home: Obx(()=>buildContent(context))
    );
  }

  Widget buildContent(BuildContext context) {
    AppSettings appSettings = Get.find();
    switch(appSettings.mode.value) {
      case AppMode.adminApp:
        return const AdminAppWidget();
      case AppMode.welcomeScreen:
        return const WelcomeScreen();
      case AppMode.guestApp:
        return const GuestAppWidget();
    }
  }
}


