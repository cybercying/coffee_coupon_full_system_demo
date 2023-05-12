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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:card_settings/card_settings.dart';
import '../admin_app/user_ui.dart';
import '../app_settings.dart';
import '../communication.dart';
import '../demo_setting_ui.dart';
import '../testing_keys.dart';
import '../welcome_app/widget_finder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:protocol/client_state.dart';
import 'package:protocol/protocol.dart';
import 'package:protocol/test_data.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher.dart';
import '../admin_app/admin_app.dart';
import '../guest_app/guest_account_ui.dart';
import '../guest_app/guest_app.dart';
import '../ui_shared.dart';
import 'tutorial_helper.dart';
import 'welcome_app.dart';

const _isTesting = false;

const _testingMarkdown = '''
# Welcome to the Demo

## What is "Full Flutter System Demo for Coffee Coupons"
This project provides a full [Flutter](https://flutter.dev/)/Dart system template from front-end APPs to the backend database to demonstrate a coupon management system, which is suitable for a coffeehouse chain (or any restaurant chain) to build customer loyalty.

More detailed information can be found at [here](https://gvn.page.link/coffee_coupon_full_system_demo).

## How to use this demo?
This is a full featured demo, you might need to learn some basics in order to experience the full extent of this project. Click the _**"Quick tour"**_ button below to learn quickly how this program works.

''';

const _projectOfficialUrl = 'https://github.com/cybercying/coffee_coupon_full_system_demo';

String? hasPrefix(String? str, String prefix) {
  if (str == null) {
    return null;
  }
  if (str.startsWith(prefix)) {
    return str.substring(prefix.length);
  }
  return null;
}

Markdown buildMarkdown(AppSettings appSettings, ThemeData theme, String data, {selectable = false}) {
  return Markdown(
      selectable: selectable,
      styleSheet: buildMarkdownStyleSheet(appSettings, theme),
      imageBuilder: (Uri uri, String? title, String? alt) => CachedNetworkImage(imageUrl: uri.toString()),
      onTapLink: (String text, String? href, String title) async {
        const fileNameMapping = {
          'README.md': 'loc:en_US',
          'README_zh.md': 'loc:zh_TW',
          'README_ja.md': 'loc:ja_JP',
          'README_ko.md': 'loc:ko_KR',
          'README_es.md': 'loc:es_ES',
          'LICENSE': '$_projectOfficialUrl/blob/main/LICENSE',
        };
        log('onTapLink: text: $text, href: $href, title: $title');
        href = fileNameMapping[href] ?? href;
        String? loc = hasPrefix(href, 'loc:');
        if (loc != null) {
          appSettings.changeLocaleIfValid(loc);
        }
        else if (href != null) {
          void replacePrefix(String prefix, String replaceWith) {
            if (href!.startsWith(prefix)) {
              href = href!.replaceRange(0, prefix.length, replaceWith);
            }
          }
          replacePrefix('doc/', '$_projectOfficialUrl/blob/main/doc/');
          replacePrefix('assets/markdown/', '$_projectOfficialUrl/blob/main/assets/markdown/');
          await confirmOpenUrl(href);
        }
      },
      data: _isTesting ? _testingMarkdown : data
  );
}

Future<void> confirmOpenUrl(String? href) async {
  if (href != null && href.startsWith('https://')) {
    if (await confirmDialog(content: "welcomeScreen.openBrowser".tr)) {
      launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
    }
  }
}

MarkdownStyleSheet buildMarkdownStyleSheet(AppSettings appSettings, ThemeData theme) {
  appSettings.isDarkTheme.value; // this line must not be removed!!!
  return MarkdownStyleSheet(
    h1: buildHeading1Style(theme),
    h2: theme.textTheme.titleLarge!.copyWith(color: appSettings.appTheme.textColor),
  );
}

TextStyle buildHeading1Style(ThemeData theme) => theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  Future<void> onQuickTour() async {
    await TutorialHelper(
      contextFinder: WidgetFinder(matcher: TypeMatcher(type: WelcomeScreen)),
      finder: WidgetFinder(matcher: KeyMatcher(key: TestingKeys.demoSettingsBtn)),
      title: "quickTour.demoSettings.title".tr,
      description: "quickTour.demoSettings".tr,
      tapWidgetAfterFinish: true,
    ).show();
    await TutorialHelper(
      contextFinder: WidgetFinder(matcher: TypeMatcher(type: DemoSettingScreen)),
      finder: WidgetFinder(matcher: TypeMatcher(type: CardSettings)),
      waitForWidget: const Duration(milliseconds: 500),
      description: "quickTour.demoSettings.intro".tr,
      shape: ShapeLightFocus.RRect,
    ).show();
    await TutorialHelper(
      contextFinder: WidgetFinder(matcher: TypeMatcher(type: DemoSettingScreen)),
      finder: WidgetFinder(
          matcher: KeyMatcher(
              key: TestingKeys.adminAppBtn
          ),
          elementGetter: elementGetterOfAncestorIsType<CardSettingsSection>),
      waitForWidget: const Duration(milliseconds: 50),
      title: "quickTour.appSelection.title".tr,
      description: "quickTour.appSelection".tr,
      shape: ShapeLightFocus.RRect,
    ).show();
    await TutorialHelper(
      contextFinder: WidgetFinder(matcher: TypeMatcher(type: DemoSettingScreen)),
      finder: WidgetFinder(
          matcher: KeyMatcher(
              key: TestingKeys.serverUrlEdit
          ),
          elementGetter: elementGetterOfAncestorIsType<CardSettingsSection>),
      waitForWidget: const Duration(milliseconds: 500),
      title: "quickTour.serverType.title".tr,
      description: "quickTour.serverType".tr,
      shape: ShapeLightFocus.RRect,
    ).show();
    Get.back();
    await TutorialHelper(
      contextFinder: WidgetFinder(matcher: TypeMatcher(type: WelcomeScreen)),
      finder: WidgetFinder(
          matcher: KeyMatcher(
              key: TestingKeys.mockDevicesBtn
          ),
          elementGetter: elementGetterOfAncestorIsType<CardSettingsSection>),
      waitForWidget: const Duration(milliseconds: 500),
      title: "quickTour.mockDevices.title".tr,
      description: "quickTour.mockDevices".tr
    ).show();
    log('TutorialHelper completed!');
  }

  @override
  Widget build(BuildContext context) {
    final intro = GlobalKey<IntroductionScreenState>();
    AppSettings appSettings = Get.find();
    WelcomeApp welcomeApp = Get.find();
    ThemeData theme = Get.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text("main.welcomeScreen".tr),
        actions: getAppbarActions(),
      ),
      body: Obx(()=>
        IntroductionScreen(
            key: intro,
            initialPage: welcomeApp.currentPageIndex.value,
            overrideNext: GestureDetector(
              onTap: (){
                intro.currentState!.next();
              },
              child: buildTextButton("welcomeScreen.next".tr)
            ),
            overrideBack: GestureDetector(
                onTap: (){
                  intro.currentState!.previous();
                },
                child: buildTextButton("welcomeScreen.back".tr),
            ),
            onChange: (value) async {
              welcomeApp.currentPageIndex.value = value;
              welcomeApp.saveState();
            },
            controlsPadding: const EdgeInsets.only(bottom: 20),
            bodyPadding: const EdgeInsets.only(bottom: 40),
            showDoneButton: false,
            showNextButton: true,
            showBackButton: true,
            dotsDecorator: DotsDecorator(
              size: const Size.square(10.0),
              activeSize: const Size(20.0, 10.0),
              activeColor: Theme.of(context).colorScheme.secondary,
//          color: Colors.black26,
              spacing: const EdgeInsets.symmetric(horizontal: 3.0),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0)
              ),
            ),
            rawPages: [
              Column(
                children: [
                  Expanded(
                    child: Obx(()=>
                      buildMarkdown(appSettings, theme, appSettings.appAssets.welcomeMarkdown)
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () {
                          Get.to(()=>const ProjectInfoScreen());
                        },
                        heroTag: 'moreInfo',
                        label: Text("welcomeScreen.moreInfo".tr),
                      ),
                      FloatingActionButton.extended(
                        onPressed: onQuickTour,
                        heroTag: 'quickTour',
                        label: Text("welcomeScreen.quickTour".tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),

              Column(
                children: [
                  Expanded(
                    child: Obx(()=>buildMarkdown(appSettings, theme, appSettings.appAssets.dataSetupMarkdown))
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () {
                          Get.to(()=>const UserStoryScreen());
                        },
                        heroTag: 'userStory',
                        label: Text("welcomeScreen.userStory".tr),
                      ),
                      FloatingActionButton.extended(
                        onPressed: onDataSetup,
                        backgroundColor: Colors.red,
                        heroTag: 'dataSetup',
                        label: Text("welcomeScreen.dataSetup".tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              const UserDataBlock(),
              const GuestDataBlock(),
            ],
          ),
      ),
    );
  }

  Widget buildTextButton(String text) {
    return Align(
      alignment: Alignment.center,
      child: Text(text,
          style: const TextStyle(
            decoration: TextDecoration.underline,
          )
      ),
    );
  }

  Future<void> onDataSetup() async {
    UiTransientState uiState = Get.find();
    AppSettings appSettings = Get.find();
    AdminApp adminApp = Get.find();
    GuestApp guestApp = Get.find();
    WelcomeApp welcomeApp = Get.find();
    var users = UserData();
    var guests = GuestData();
    if (await confirmDialog(content: "welcomeScreen.confirmDataSetup".tr)) {
      try {
        uiState.disableSnackbar = true;
        uiState.setSystemBusy(true);
        await resetServerDatabase(defaultLocale: appSettings.language.value.locale.toString());
        await appSettings.changeCurrentMockDevice(email: users.brynn.email);
        await adminApp.bringUpAppAndLogin(users.brynn.email, users.brynn.plainPassword!);
        await appSettings.changeCurrentMockDevice(email: users.lazar.email);
        await adminApp.bringUpAppAndLogin(users.lazar.email, users.lazar.plainPassword!);
        await appSettings.changeCurrentMockDevice(phone: users.madeline.phone);
        await adminApp.bringUpAppAndLogin(users.madeline.email, users.madeline.plainPassword!);
        await appSettings.changeCurrentMockDevice(phone: users.tersina.phone);
        await appSettings.changeToAppMode(AppMode.adminApp);
        await appSettings.changeCurrentMockDevice(phone: guests.haskell.phone);
        await guestApp.bringUpAppAndRegister(guests.haskell);
        await appSettings.changeCurrentMockDevice(phone: guests.shawn.phone);
        welcomeApp.currentPageIndex.value = 1;
        welcomeApp.saveState();
        await alertDialog("welcomeScreen.dataSetup.completed".tr);
        await TutorialHelper(
            contextFinder: WidgetFinder(matcher: TypeMatcher(type: WelcomeScreen)),
            finder: WidgetFinder(
                matcher: KeyMatcher(
                    key: TestingKeys.mockDevicesBtn
                ),
                elementGetter: elementGetterOfAncestorIsType<CardSettingsSection>),
            waitForWidget: const Duration(milliseconds: 500),
            title: "welcomeScreen.dataSetup.tutorial".tr,
            description: "welcomeScreen.dataSetup.tutorial.title".tr,
            tapWidgetAfterFinish: true
        ).show();
      }
      catch(err, st) {
        log('err: $err, st: $st');
        uiNotifyError("welcomeScreen.dataSetup.failed".trParams({"err": err.toString()}));
      }
      finally {
        uiState.disableSnackbar = false;
        UiTransientState.instance.setSystemBusy(false);
      }
    }
  }
}

class ProjectInfoScreen extends StatelessWidget {
  const ProjectInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    ThemeData theme = Get.theme;
    return Scaffold(
        appBar: AppBar(
            title: Text("welcomeScreen.moreInfo".tr),
            //actions: getAppbarActions(),
        ),
        body: Column(
            children: [
                Expanded(
                  child: Obx(()=>
                      buildMarkdown(appSettings, theme, appSettings.appAssets.readmeMarkdown)
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.extended(
                      onPressed: () async {
                        await confirmOpenUrl(_projectOfficialUrl);
                      },
                      heroTag: 'openGitHub',
                      label: Text("welcomeScreen.openGitHub".tr),
                    )
                  ],
                ),
                const SizedBox(height: 10),
            ],
        ),
    );
  }
}

class UserStoryScreen extends StatelessWidget {
  const UserStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    ThemeData theme = Get.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text("welcomeScreen.userStory".tr),
        //actions: getAppbarActions(),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(()=>
                buildMarkdown(appSettings, theme, appSettings.appAssets.userStoryMarkdown)
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class GuestItemCardBase extends StatelessWidget {
  final GenGuest guest;
  final AppSettings appSettings;
  final EdgeInsets? padding;
  final Widget? icon;
  const GuestItemCardBase({
    super.key,
    required this.guest,
    required this.appSettings,
    this.padding,
    this.icon,
  });

  Future<void> onTap() async {}

  @override
  Widget build(BuildContext context) {
    return AttributeCard(
        onTap: onTap,
        padding: padding,
        icon: icon,
        children: GuestFieldsBuilder(app: appSettings).buildGuestFields(guest)
    );
  }
}

Widget buildTitledScrollingListScreen({required String title, required List<Widget> children}) {
  return Padding(
    padding: const EdgeInsets.all(15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: buildHeading1Style(Get.theme)),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    ),
  );
}

class UserItemCardTest extends StatelessWidget {
  final AppSettings appSettings;
  final GenUser rec;
  final EdgeInsets? padding;
  const UserItemCardTest({
    super.key,
    required this.rec,
    required this.appSettings,
    this.padding,
  });

  Future<void> onTap() async {
    if (rec.plainPassword != null) {
      if (await confirmDialog(content: "welcomeScreen.testUserLogin".trParams({"email": rec.email}))) {
        AdminApp adminApp = Get.find();
        await adminApp.bringUpAppAndLogin(rec.email, rec.plainPassword!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AttributeCard(
        padding: padding,
        icon: const Icon(Icons.login),
        onTap: onTap,
        children: UserFieldsBuilder(app: appSettings).buildUserFields(rec)
    );
  }
}

class UserDataBlock extends StatelessWidget {
  const UserDataBlock({super.key});

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    var users = UserData();
    final userList = [users.brynn, users.lazar, users.tersina, users.madeline, users.josh, users.krystin, users.adriana, users.toiboid, users.orelee, users.yalonda];
    return buildTitledScrollingListScreen(
      title: "welcomeScreen.userTestData".tr,
        children: [
          for(var user in userList)
            SizedBox(
                width: double.infinity,
                child:
                UserItemCardTest(rec: user, appSettings: appSettings, padding: const EdgeInsets.only(bottom: 10))
            ),
        ]
    );
  }
}

class GuestItemCardTest extends GuestItemCardBase {
  const GuestItemCardTest({
    super.key,
    required super.guest,
    required super.appSettings,
    super.padding,
    super.icon = const Icon(Icons.login)
  });

  @override
  Future<void> onTap() async {
    if (appSettings.currentMockDevice().phone == guest.phone) {
      if (await confirmDialog(content: "welcomeScreen.testGuestRegister".tr)) {
        GuestApp guestApp = Get.find();
        await guestApp.bringUpAppAndRegister(guest);
      }
    }
    else {
      await alertErrorDialog("welcomeScreen.cannotRegisterDueToPhoneMismatch".tr);
    }
  }
}

class GuestDataBlock extends StatelessWidget {
  const GuestDataBlock({super.key});

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    var guests = GuestData();
    final guestList = [guests.haskell, guests.shawn];
    return buildTitledScrollingListScreen(
        title: "welcomeScreen.guestTestData".tr,
        children: [
          for(var guest in guestList)
            SizedBox(
                width: double.infinity,
                child:
                GuestItemCardTest(guest: guest, appSettings: appSettings, padding: const EdgeInsets.only(bottom: 10))
            ),
        ]
    );
  }
}
