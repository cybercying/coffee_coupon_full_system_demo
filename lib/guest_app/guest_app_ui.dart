/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';

import '../guest_app/guest_account_ui.dart';
import 'package:protocol/client_state.dart';

import '../testing_keys.dart';
import '../ui_shared.dart';
import 'coupon_list_screen.dart';
import 'guest_app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class GuestAppWidget extends StatelessWidget {
  const GuestAppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(()=>getCurrentScreen());
  }

  Widget getCurrentScreen() {
    GuestApp guestApp = Get.find();
    switch(guestApp.currentScreen.value) {
      case GuestAppScreen.bindScreen:
        return BindGuestScreen();
      case GuestAppScreen.otpCodeVerifyScreen:
        return OtpCodeVerifyScreen();
      case GuestAppScreen.updateGuestAccount:
        return const GuestAccountDetailScreen(registerMode: true);
      case GuestAppScreen.guestAccount:
        return const GuestAccountScreen();
      case GuestAppScreen.stores:
        return const StoreListScreen();
      case GuestAppScreen.coupons:
        return const CouponListScreen(isFavoriteList: false);
      case GuestAppScreen.favoriteCoupons:
        return const CouponListScreen(isFavoriteList: true);
    }
  }
}

class BindGuestScreen extends StatelessWidget {
  final controller = PageController();

  BindGuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    GuestApp guestApp = Get.find();
    var phoneFormatter = getPhoneInputFormatter();
    return Scaffold(
      appBar: AppBar(
        actions: getAppbarActions(),
      ),
      body: Container(
        decoration: BoxDecoration(
            color: Colors.brown[900]!,
            image: const DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider("https://images.unsplash.com/photo-1585952811918-2f09788d9c4d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80")
            )
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Column(
            children: [
              const Spacer(
                flex: 2,
              ),
              Text("guestApp.enterYourPhoneNumber".tr,
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    backgroundColor: Colors.black.withOpacity(0.5)
                )
              ),
              const SizedBox(height: 20, width: double.infinity),
              SizedBox(
                width: 400,
                child: TextField(
                  key: TestingKeys.guestRegisterPhoneNumberEdit,
                  autofocus: true,
                  controller: guestApp.registeringPhone,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300]!.withOpacity(0.8)
                  ),
                  style: const TextStyle(
                    fontSize: 50
                  ),
                  inputFormatters: [phoneFormatter],
                  onChanged: (str) {
                    guestApp.isRegisterPhoneValid.value = phoneFormatter.isFilled;
                  },
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap:() async {
                  if (guestApp.isRegisterPhoneValid.value) {
                    await guestApp.enteredPhoneNumber();
                  }
                },
                child: Obx(()=>Container(
                  margin: const EdgeInsets.only(left: 30, right: 30),
                  alignment: Alignment.center,
                  height: 60,
                  width: double.infinity,
                  decoration: guestApp.isRegisterPhoneValid.value ?
                      BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(30)) : null,
                  child: guestApp.isRegisterPhoneValid.value ?
                      Text("guestApp.getStartedBtn".tr,
                          style: const TextStyle(
                              color: AppTheme.whiteColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 25)
                      ): null,
                )),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpCodeVerifyScreen extends StatelessWidget {
  final controller = PageController();

  OtpCodeVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    GuestApp guestApp = Get.find();
    var otpFormatter = MaskedInputFormatter('000000');
    return Scaffold(
      appBar: AppBar(
        actions: getAppbarActions(),
      ),
      body: Container(
        decoration: BoxDecoration(
            color: Colors.brown[900]!,
            image: const DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider("https://images.unsplash.com/photo-1585952811918-2f09788d9c4d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80")
            )
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Column(
            children: [
              const Spacer(
                flex: 2,
              ),
              Text("guestApp.enterOtpCode".tr,
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      backgroundColor: Colors.black.withOpacity(0.5)
                  )
              ),
              const SizedBox(height: 20, width: double.infinity),
              SizedBox(
                width: 300,
                child: TextField(
                  key: TestingKeys.guestRegisterPinCodeEdit,
                  autofocus: true,
                  controller: guestApp.enteringOtpCode,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[300]!.withOpacity(0.8)
                  ),
                  style: const TextStyle(
                      fontSize: 80
                  ),
                  inputFormatters: [otpFormatter],
                  onChanged: (str) {
                    guestApp.isOtpCodeValid.value = otpFormatter.isFilled;
                  },
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap:() async {
                  if (guestApp.isRegisterPhoneValid.value) {
                    await guestApp.enteredOtpCode();
                  }
                },
                child: Obx(()=>Container(
                  margin: const EdgeInsets.only(left: 30, right: 30),
                  alignment: Alignment.center,
                  height: 60,
                  width: double.infinity,
                  decoration: guestApp.isOtpCodeValid.value ?
                  BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(30)) : null,
                  child: guestApp.isOtpCodeValid.value ?
                  Text("guestApp.verifyBtn".tr,
                      style: const TextStyle(
                          color: AppTheme.whiteColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 25)
                  ): null,
                )),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class GuestAppNavigationBar extends StatelessWidget {
  final int currentIndex;
  const GuestAppNavigationBar({
    super.key, required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    GuestApp guestApp = Get.find();
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      //selectedItemColor: AppTheme.primaryColor,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      currentIndex: currentIndex,
      onTap: (value) async {
        if (value == 0) {
          guestApp.currentScreen.value = GuestAppScreen.coupons;
          guestApp.saveState();
        }
        else if (value == 1) {
          guestApp.currentScreen.value = GuestAppScreen.favoriteCoupons;
          guestApp.saveState();
        }
        else if (value == 2) {
          guestApp.currentScreen.value = GuestAppScreen.stores;
          guestApp.saveState();
        }
        else if (value == 3) {
          guestApp.currentScreen.value = GuestAppScreen.guestAccount;
          guestApp.saveState();
        }
      },
      items: [
        BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'guestApp.coupons'.tr),
        BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: 'guestApp.favorite'.tr),
        BottomNavigationBarItem(
            icon: const Icon(Icons.store),
            label: 'guestApp.stores'.tr),
        BottomNavigationBarItem(
            icon: const Icon(Icons.verified_user),
            label: 'guestApp.account'.tr),
      ],
    );
  }
}

