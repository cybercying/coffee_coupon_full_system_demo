/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'xtran_ui.dart';

import 'redeem_policy_ui.dart';
import 'package:protocol/client_state.dart';

import '../app_settings.dart';

import '../ui_shared.dart';
import 'store_ui.dart';
import 'user_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:protocol/protocol.dart';
import 'admin_app.dart';
import 'admin_login_ui.dart';
import 'mock_message_ui.dart';

ListView getDrawerItems(BuildContext context) {
  AdminApp adminApp = Get.find();
  return ListView(
    children: [
      UserAccountsDrawerHeader(
        accountName: Text(adminApp.loggedInFullName.value),
        accountEmail: Text(adminApp.loggedInEmail.value),
        currentAccountPicture: const CircleAvatar(
          child: FlutterLogo(size: 42.0),
        ),
      ),
      ListTile(
        title: Text(
          'adminApp.viewMockMessageList'.tr,
        ),
        leading: const Icon(Icons.favorite),
        onTap: () async {
          Get.back();
          AdminApp adminApp = Get.find();
          try {
            await adminApp.queryMockMessageList();
            Get.to(() => const MockMessageServerListScreen());
          }
          on ServerException catch(e) {
            uiNotifyServerError(e);
          }
        },
      ),
      ListTile(
        title: Text(
          'gen.logout'.tr,
        ),
        leading: const Icon(Icons.comment),
        onTap: () async {
          if (await confirmDialog()) {
            AdminApp adminApp = Get.find();
            adminApp.logout();
          }
        },
      ),
    ],
  );
}

class AdminAppNavigationBar extends StatelessWidget {
  const AdminAppNavigationBar({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    AdminApp adminApp = Get.find();
    AppSettings appSettings = Get.find();
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: appSettings.appTheme.adminAppNavigationBarColor,
//      selectedItemColor: AppTheme.primaryColor,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      currentIndex: getCurrentIndex(adminApp),
      onTap: (value) async {
        if (value == 1) {
          adminApp.currentScreen.value = AdminAppScreen.userListScreen;
          adminApp.saveState();
        }
        else if (value == 0) {
          adminApp.currentScreen.value = AdminAppScreen.storeListScreen;
          adminApp.saveState();
        }
        else if (value == 2) {
          adminApp.currentScreen.value = AdminAppScreen.xtranListScreen;
          adminApp.saveState();
        }
        else if (value == 3) {
          adminApp.currentScreen.value = AdminAppScreen.redeemPolicyListScreen;
          adminApp.saveState();
        }
      },
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.storefront),
            label: 'store.ui.bottomTab'.tr),
        BottomNavigationBarItem(
            icon: const Icon(Icons.group),
            label: 'user.ui.bottomTab'.tr),
        BottomNavigationBarItem(
            icon: const Icon(Icons.paid),
            label: 'xtran.ui.bottomTab'.tr),
        BottomNavigationBarItem(
            icon: const Icon(Icons.redeem),
            label: 'redeemPolicy.ui.bottomTab'.tr),
        // BottomNavigationBarItem(
        //     icon: const Icon(Icons.person),
        //     label: 'adminApp.guestList'.tr),
      ],
    );
  }

  int getCurrentIndex(AdminApp adminApp) {
    switch(adminApp.currentScreen.value) {
      case AdminAppScreen.userListScreen:
        return 1;
      case AdminAppScreen.storeListScreen:
        return 0;
      case AdminAppScreen.redeemPolicyListScreen:
        return 3;
      default:
        return 2;
    }

  }
}

class AdminAppWidget extends StatelessWidget {
  const AdminAppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(()=>getCurrentScreen());
  }

  Widget getCurrentScreen() {
    AdminApp adminApp = Get.find();
    switch(adminApp.currentScreen.value) {
      case AdminAppScreen.loginScreen:
        return const AdminLoginScreen();
      case AdminAppScreen.userListScreen:
        return const UserListScreen();
      case AdminAppScreen.storeListScreen:
        return const StoreListScreen();
      case AdminAppScreen.redeemPolicyListScreen:
        return const RedeemPolicyListScreen();
      case AdminAppScreen.xtranListScreen:
        return const TransactionListScreen();
    }
  }
}

class CollapsablePanel extends StatelessWidget {
  final RxBool expanded;
  final Color? color;
  final List<Widget> children;
  final Widget text;

  const CollapsablePanel({
    super.key,
    required this.expanded,
    this.color,
    required this.text,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    return Container(
        decoration: BoxDecoration(
            color: color,
            boxShadow: [BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 4,
                color: appSettings.appTheme.topPanelShadowColor
            )]
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Obx(()=>Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              expanded.value ? Padding(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: children
                ),
              ) : const Offstage(),
              expanded.value ? const SizedBox(height: 10) : const Offstage(),
              GestureDetector(
                onTap: () {
                  expanded.value = !expanded.value;
                },
                child: Row(
                  children: [
                    Icon(expanded.value ? Icons.expand_less : Icons.expand_more),
                    const SizedBox(width: 10),
                    Expanded(child: text),
                  ],
                ),
              ),
            ],
          ),
          ),
        )
    );
  }
}

class QueryPanel extends StatelessWidget {
  final List<Widget> queryFields;
  final QueryScreenState state;

  const QueryPanel({
    super.key,
    required this.state,
    required this.queryFields,
  });

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    return CollapsablePanel(
      expanded: state.expanded,
      color: appSettings.appTheme.queryPanelColor,
      text: Obx(()=>
        Text(state.numberOfRecords.value == -1 ?
          "gen.loading".tr :
          "adminApp.queryStatusLine".trParams({
            "num" : state.numberOfRecords.value.toString(),
            "seconds": state.timeElapsed.toString()
          }),
          softWrap: true
        ),
      ),
      children: [
        const Icon(Icons.filter_alt_outlined),
        ...queryFields,
      ],
    );
  }
}

class ManagingStorePanel extends StatelessWidget{
  const ManagingStorePanel({super.key});

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    AdminApp adminApp = Get.find();
    return Obx(()=>adminApp.managingStore.value == null ? const Offstage() : CollapsablePanel(
        expanded: adminApp.managingStoreExpanded,
        color: appSettings.appTheme.managingStoreColor,
        text: Text("store.ui.youAreManagingStore".trParams({"name": (adminApp.managingStore.value ?? GenStore.empty()).name})),
        children: [
          ElevatedButton(
              onPressed: () {
                adminApp.managingStore.value = null;
                adminApp.managingStoreExpanded.value = false;
              },
              child: Text("store.ui.stopManage".tr)
          )
        ]
      ),
    );
  }

}