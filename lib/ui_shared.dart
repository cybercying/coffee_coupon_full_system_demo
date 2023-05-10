/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:async';

import 'admin_app/mock_message_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:get/get.dart';
import 'package:protocol/client_state.dart';
import 'package:protocol/protocol.dart';

import 'app_settings.dart';
import 'demo_setting_ui.dart';
import 'mock_device_ui.dart';
import 'testing_keys.dart';

class UiTransientState {
  AppConfig appConfig;
  bool isSystemBusy = false;
  OverlayEntry? busyOverlay;
  SnackbarController? snackbarController;
  bool disableSnackbar = false;
  UiTransientState(this.appConfig);
  static UiTransientState get instance => Get.find();
  Future<void> closeSnackbar() async {
    var controller = snackbarController;
    snackbarController = null;
    await controller?.close(withAnimations: false);
  }
  void setSystemBusy(bool yes) {
    if (isSystemBusy != yes) {
      isSystemBusy = yes;
      if (yes) {
        var overlayContext = Get.overlayContext;
        if (overlayContext == null) {
          isSystemBusy = false;
          removeBusyOverlay();
        }
        else {
          var overlayEntry = OverlayEntry(
              builder: (context) {
                return Stack(
                  children: [
                    Container(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    const Center(
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator()),
                    ),
                  ],
                );
              }
          );
          Overlay.of(Get.overlayContext!).insert(overlayEntry);
          busyOverlay = overlayEntry;
        }
      }
      else {
        removeBusyOverlay();
      }
    }
  }

  void removeBusyOverlay() {
    var overlayEntry = busyOverlay;
    busyOverlay = null;
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry.dispose();
    }
  }
}

ThemeData buildTheme(Brightness brightness) {
  if (brightness == Brightness.dark) {
    return ThemeData(
      brightness: brightness,
      secondaryHeaderColor: Colors.indigo[400], // card header background
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: ColorScheme.fromSwatch(backgroundColor: Colors.black, brightness: brightness),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 5,
            textStyle: const TextStyle(fontSize: 18, inherit: false),
            backgroundColor: Colors.indigo[100]!, // button background color
            foregroundColor: Colors.white), // button text color
      ),
      cardTheme: CardTheme(
        elevation: 15,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 3, color: Colors.indigo[400]!),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  } else {
    return ThemeData(
      primaryColor: Colors.teal, // app header background
      secondaryHeaderColor: Colors.indigo[400], // card header background
      cardColor: Colors.indigo[50], // card field background
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue, backgroundColor: Colors.indigo[100]),
      textTheme: TextTheme(
        labelLarge: TextStyle(color: Colors.deepPurple[900]), // button text
        titleMedium: TextStyle(color:  Colors.grey[800]), // input text
        titleLarge: const TextStyle(color: Colors.white), // card header text
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 5,
            textStyle: const TextStyle(fontSize: 18, inherit: false),
            backgroundColor: Colors.indigo[100]!, // button background color
            foregroundColor: Colors.white), // button text color
      ),
      primaryTextTheme: TextTheme(
        titleLarge: TextStyle(color: Colors.lightBlue[50]), // app header text
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.indigo[400]), // style for labels
      ),
      cardTheme: CardTheme(
        elevation: 15,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 3, color: Colors.indigo[400]!),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}

const _snackbarAnimationDuration = Duration(milliseconds: 150);

Future<void> uiNotifyReceivedSMS(String title, String message) async {
  UiTransientState uiState = Get.find();
  if (uiState.appConfig.disableSnakebars || uiState.disableSnackbar) {
    return;
  }
  await uiState.closeSnackbar();
  SnackbarController? controller;
  controller = Get.snackbar(
    title,
    message,
    duration: const Duration(seconds: 60),
    icon: const Icon(Icons.sms),
    snackbarStatus: (status) {
      if (status == SnackbarStatus.CLOSED) {
        if (uiState.snackbarController == controller) {
          uiState.snackbarController = null;
        }
      }
    }
  );
  uiState.snackbarController = controller;
}

Future<void> uiNotifyCloseAll() async {
  UiTransientState uiState = Get.find();
  await uiState.closeSnackbar();
}

Future<void> uiNotifyUpdateSuccess([String? message, String? title]) async {
  UiTransientState uiState = Get.find();
  if (uiState.appConfig.disableSnakebars || uiState.disableSnackbar) {
    return;
  }
  await uiState.closeSnackbar();
  SnackbarController? controller;
  controller = Get.snackbar(
      title ?? 'adminApp.update'.tr,
      message ?? 'adminApp.operationSuccess'.tr,
      backgroundColor: Get.isDarkMode ? Colors.green[700] : Colors.lightGreen[200],
      duration: const Duration(seconds: 2),
      borderWidth: 1,
      borderColor: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      animationDuration: _snackbarAnimationDuration,
      snackbarStatus: (status) {
        if (status == SnackbarStatus.CLOSED) {
          if (uiState.snackbarController == controller) {
            uiState.snackbarController = null;
          }
        }
      }
  );
  uiState.snackbarController = controller;
}

Future<void> uiNotifyServerError(ServerException e) async {
  await uiNotifyError('serverCode.${e.code?.name}'.tr, title: 'adminApp.serverError'.tr);
}

Future<void> alertServerError(ServerException e) async {
  await alertErrorDialog('serverCode.${e.code?.name}'.tr);
}

Future<void> uiNotifyError(String message, {String? title}) async {
  title ??= 'gen.error'.tr;
  UiTransientState uiState = Get.find();
  if (uiState.appConfig.disableSnakebars || uiState.disableSnackbar) {
    return;
  }
  await uiState.closeSnackbar();
  SnackbarController? controller;
  controller = Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red[300],
      duration: const Duration(seconds: 3),
      borderWidth: 1,
      borderColor: Colors.black,
      snackPosition: SnackPosition.BOTTOM,
      animationDuration: _snackbarAnimationDuration,
      snackbarStatus: (status) {
        if (status == SnackbarStatus.CLOSED) {
          if (uiState.snackbarController == controller) {
            uiState.snackbarController = null;
          }
        }
      }
  );
  uiState.snackbarController = controller;
}

class OptionAndPressed {
  String option;
  VoidCallback onPressed;
  Key? key;
  OptionAndPressed(this.option, this.onPressed, {this.key});
}

void uiSimpleDialog(String title, List<OptionAndPressed> optionAndPressedList) {
  Get.dialog(SimpleDialog(
    title: buildDialogTitleText(title),
    children: <Widget>[
      for(var oap in optionAndPressedList)
        SimpleDialogOption(
          key: oap.key,
          child: Text(oap.option),
          onPressed: () {
            Get.back();
            oap.onPressed();
          },
        ),
    ],
  ));
}

Future<void> alertErrorDialog(String content) async {
  await alertDialog(content, title: 'gen.error'.tr);
}

Text? buildDialogTitleText(String? title) {
  return title == null ? null : Text(
    title,
    style: TextStyle(color: Get.theme.textTheme.bodyLarge!.color),
  );
}

Future<void> alertDialog(String content, {String? title}) async {
  await Get.dialog<bool>(AlertDialog(
    title: buildDialogTitleText(title),
    content: Text(content),
    actionsAlignment: MainAxisAlignment.center,
    actions: <Widget>[
      ElevatedButton(
        key: TestingKeys.okBtn,
        onPressed: () {
          Get.back();
        },
        child: Text('gen.ok'.tr),
      ),
    ],
  ));
}

Future<bool> confirmDeleteDialog({String? content, VoidCallback? onPressed, Key? key}) async {
  content ??= 'gen.confirmDelete'.tr;
  return confirmDialog(content: content, onPressed: onPressed, key: key);
}

Future<bool> confirmDialog({String? content, VoidCallback? onPressed, Key? key}) async {
  content ??= 'gen.areYouSure'.tr;
  bool? value = await Get.dialog<bool>(AlertDialog(
    key: key,
    content: Text(content),
    actionsAlignment: MainAxisAlignment.center,
    actions: <Widget>[
      ElevatedButton(
        key: TestingKeys.okBtn,
        onPressed: () {
          Get.back(result: true);
          if (onPressed != null) {
            onPressed();
          }
        },
        child: Text('gen.ok'.tr),
      ),
      OutlinedButton(
        onPressed: () {
          Get.back(result: false);
        },
        child: Text('gen.cancel'.tr),
      ),
    ],
  ));
  return value == true;
}

class AppbarBuilder {
  AppbarBuilder();

  List<Widget> buildAppbarActions() {
    return <Widget>[
      GetBuilder<AppSettings>(
          id: 'mockReceiverList',
          builder: (appSettings) {
            final mockListeners = appSettings.mockListeners;
            return PopupMenuButton<MockDevice>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(maxHeight: 400),
                tooltip: 'main.hintMockDeviceButton'.tr,
                onSelected: (value) {},
                itemBuilder: (context) =>
                [
                  for(int index=0;index<mockListeners.length;index++)
                    buildPopupMenuItem(index, appSettings),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: MockDevice(),
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        appSettings.selectedMockDevice = null;
                        Get.to(()=>const MockDeviceDetailScreen());
                      },
                      child: ListTile(
                        leading: const Icon(Icons.add),
                        title: Text('mockDevice.ui.menuCreateNew'.tr),
                      ),
                    ),
                  ),
                ],
                child:
                Container(
                  alignment: const AlignmentDirectional(0, 0),
                  padding: const EdgeInsets.all(5),
                  child: Badge(
                    key: TestingKeys.mockDevicesBtn,
                    label: Text('${appSettings.totalUnreadCount}'),
                    largeSize: 20,
                    isLabelVisible: appSettings.totalUnreadCount > 0,
                    alignment: const AlignmentDirectional(15, -8),
                    child: const Icon(
                      Icons.phone_android,
                    ),
                  ),
                )
            );
          }
      ),
      IconButton(
        key: TestingKeys.demoSettingsBtn,
        icon: const Icon(Icons.build),
        tooltip: 'main.hintOpenDemoSetting'.tr,
        onPressed: () {
          Get.to(()=>const DemoSettingScreen());
        },
      ),
    ];
  }

  PopupMenuItem<MockDevice> buildPopupMenuItem(int index, AppSettings appSettings) {
    MockNotificationListener mockListener = appSettings.mockListeners[index];
    bool isCurrentDevice = appSettings.state.currentMockDevice == index;
    Color? currentColor = Get.isDarkMode ? Colors.red[200] : Colors.red;
    return PopupMenuItem(
      value: mockListener.receiver,
      child: GestureDetector(
        onTap: () async {
          Get.back();
          uiSimpleDialog('main.mockDeviceActions'.trParams({'description': mockListener.receiver.description ?? ''}), [
            if (!isCurrentDevice) OptionAndPressed('main.mockDeviceAction.use'.tr, () async {
              appSettings.state.currentMockDevice = index;
              await appSettings.loadDeviceSettings();
              appSettings.saveState();
            }, key: TestingKeys.switchToThisDeviceOption),
            OptionAndPressed('main.mockDeviceAction.modify'.tr, () {
              Get.back();
              appSettings.selectedMockDevice = mockListener.receiver;
              Get.to(()=>const MockDeviceDetailScreen());
            }),
            OptionAndPressed('main.mockDeviceAction.inbox'.tr, () {
              Get.to(()=>MockMessageListScreen(mockListener: mockListener));
            }),
          ]);
        },
        child: ListTile(
          leading: Badge(
            label: Text('${mockListener.unreadCount}'),
            largeSize: 20,
            isLabelVisible: mockListener.unreadCount > 0,
            alignment: const AlignmentDirectional(15, -8),
            child: const Icon(
              Icons.phone_android,
            ),
          ),
          tileColor: isCurrentDevice ? Get.theme.highlightColor : null,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mockListener.receiver.description ?? '(null)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              DefaultTextStyle(
                style: Get.theme.textTheme.bodyMedium!,
                child: Wrap(children: [
                  if (mockListener.receiver.phone!=null) const Icon(Icons.phone, size: 20),
                  if (mockListener.receiver.phone!=null) Text(mockListener.receiver.phone!),
                  if (mockListener.receiver.phone!=null && mockListener.receiver.email!=null) const SizedBox(width: 10),
                  if (mockListener.receiver.email!=null) const Icon(Icons.email, size: 20),
                  if (mockListener.receiver.email!=null) Text(mockListener.receiver.email!),
                ],),
              ),
              if (isCurrentDevice)
                Wrap(
                  children: [
                    Icon(Icons.star, size: 20, color: currentColor),
                    Text('main.currentDevice'.tr,
                        style: Get.theme.textTheme.bodyMedium!.copyWith(color: currentColor, fontWeight: FontWeight.bold)
                    )],
                )
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> getAppbarActions() {
  return AppbarBuilder().buildAppbarActions();
}

MaskedInputFormatter getPhoneInputFormatter() {
  return MaskedInputFormatter('000-000-0000');
}

Future<void> guardUpdateOp(Function() op, {String? successMessage, AnimationController? controller}) async {
  String? err;
  successMessage ??= 'adminApp.operationSuccess'.tr;
  try {
    await op();
  }
  on ServerException catch(e) {
    if (e.type == ServerResponseType.error) {
      err = 'serverCode.${e.code!.name}'.tr;
    }
  }
  catch(e) {
    err = e.toString();
  }
  if (err == null) {
    Get.back();
    await uiNotifyUpdateSuccess(successMessage);
  }
  else {
    await controller?.forward(from: 0);
    await alertErrorDialog(err);
  }
}

Widget buildTestableListView({
     required BuildContext context,
     required int itemCount,
     required NullableIndexedWidgetBuilder itemBuilder}) {
  UiTransientState state = Get.find();
  if (state.appConfig.disableListViewBuilder) {
    List<Widget> list = [];
    for(int i=0;i<itemCount;i++) {
      var widget = itemBuilder(context, i);
      if (widget != null) {
        list.add(SizedBox(
          width: double.infinity,
          child: widget));
      }
    }
    return SingleChildScrollView(
      child: Column(
        children: list
      ),
    );
  }
  else {
    return ListView.builder(
        itemCount: itemCount,
        itemBuilder: itemBuilder);
  }
}

class AttributeCard extends StatelessWidget {
  final EdgeInsets? padding;
  final List<Widget> children;
  final void Function()? onTap;
  final Widget? icon;
  final Color? color;
  const AttributeCard({
    super.key,
    this.padding,
    this.onTap,
    this.icon,
    this.color,
    required this.children
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Card(
        elevation: 5,
        color: color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  icon ?? const Icon(Icons.info_outline),
                  ...children]
            ),
          ),
        ),
      ),
    );
  }
}

