/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';

import '../app_settings.dart';
import '../testing_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:protocol/protocol.dart';

import '../fields_builder.dart';
import '../ui_shared.dart';
import 'guest_app.dart';
import 'guest_app_ui.dart';
import 'guest_xtran_ui.dart';

class GuestFieldsBuilder extends FieldsBuilder {
  GenGuest? guest;

  GuestFieldsBuilder({
    required super.app,
  }) {
    sectionDefs = [
      FieldSectionDef(label: "guestApp.guest.information".tr),
    ];
    fieldDefs = [
      FieldDef(
        key: TestingKeys.fullNameEdit,
        tag: 'fullName',
        label: 'gen.fullName'.tr,
        width: FieldsBuilder.normalWidth,
        required: true,
        loadValue: () => guest!.fullName,
        saveValue: (value) => guest!.fullName = value!,
      ),
      FieldDef(
        key: TestingKeys.emailEdit,
        tag: 'email',
        label: 'gen.email'.tr,
        width: FieldsBuilder.normalWidth,
        required: true,
        loadValue: () => guest!.email,
        saveValue: (value) => guest!.email = value!
      ),
      FieldDef(
        tag: 'phone',
        label: 'gen.phone'.tr,
        width: FieldsBuilder.shorterWidth,
//        required: true,
        loadValue: () => guest!.phone,
//        saveValue: (value) => guest!.phone = value!,
//        isPhoneNumber: true,
      ),
      FieldDef(
        tag: 'gender',
        label: 'gen.gender'.tr,
        width: FieldsBuilder.shorterWidth,
        required: true,
        loadValue: () => guest!.gender.name,
        saveValue: (value) => guest!.gender = Gender.values.byName(value!),
        useRadioPicker: true,
        getChoices: () => [
          Choice(Gender.male.name, 'gen.gender.male'.tr),
          Choice(Gender.female.name, 'gen.gender.female'.tr),
          Choice(Gender.unspecified.name, 'gen.gender.unspecified'.tr),
        ]
      ),
      FieldDef(
        tag: 'birthday',
        label: 'gen.birthday'.tr,
        width: FieldsBuilder.dateWidth,
        required: true,
        loadValue: () => app.fmtDate(guest!.birthday),
        useDatePicker: true,
        loadDateTime: () => guest!.birthday,
        saveDateTime: (value) => guest!.birthday = value
      ),
      FieldDef(
          tag: 'plainPassword',
          label: 'gen.password'.tr,
          width: FieldsBuilder.shorterWidth,
          loadValue: () => guest!.plainPassword
      ),
    ];
  }

  List<Widget> buildGuestFields(GenGuest rec) {
    guest = rec;
    return buildFields();
  }

  void saveToGuestAccount(GuestApp guestApp) {
    log('saveToGuestAccount(): $values');
    guest = GenGuest.fromJson(guestApp.guestAccount.toJson());
    for(var field in fieldDefs) {
      if (field.saveValue != null && !field.useDatePicker) {
        field.saveValue!(values[field.tag]);
      }
    }
    guestApp.guestAccount.value = guest!;
  }
}

class GuestAccountDetailScreen extends StatefulWidget {
  final bool registerMode;
  const GuestAccountDetailScreen({super.key, required this.registerMode});

  @override
  State<StatefulWidget> createState() {
    return _GuestAccountDetailScreenState();
  }
}

class _GuestAccountDetailScreenState extends State<GuestAccountDetailScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey  = GlobalKey();
  late GuestApp guestApp;
  late GuestFieldsBuilder fieldsBuilder;
  late AnimationController controller;

  Future<void> onSaveChanges() async {
    var formState = _formKey.currentState!;
    String? err = 'validate';
    if (formState.validate()) {
      err = null;
      formState.save();
      fieldsBuilder.saveToGuestAccount(guestApp);
      try {
        //log('updateSelectedUser: ${adminApp.selectedUser!.toJson()}');
        if (widget.registerMode) {
          await guestApp.updateGuestAccount();
        }
        else {
          await guestApp.updateGuestAccountAfterLogin();
        }
      }
      on ServerException catch(e) {
        if (e.type == ServerResponseType.error) {
          err = 'serverCode.${e.code!.name}'.tr;
        }
      }
      catch(e, s) {
        if (kDebugMode) print(s);
        err = e.toString();
      }
      if (err == null) {
        Get.back();
      }
      else {
        uiNotifyError(err);
      }
    }
    if (err != null) {
      controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    guestApp = Get.find();
    controller = AnimationController(vsync: this);
    fieldsBuilder = GuestFieldsBuilder(
        app: appSettings,
    );
    fieldsBuilder.guest = guestApp.guestAccount.value;
    return Scaffold(
        appBar: AppBar(
          title: Text("guestApp.guestAccountUpdate".tr),
        ),
        bottomNavigationBar: widget.registerMode ? null : const GuestAppNavigationBar(currentIndex: 3),
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
                        child: fieldsBuilder.buildCardSettings(onSubmitted: onSaveChanges),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                    spacing: 10,
                    children: [
                      FloatingActionButton.extended(
                        key: TestingKeys.saveBtn,
                        onPressed: onSaveChanges,
                        icon: const Icon(Icons.save),
                        heroTag: 'save',
                        label: Text('gen.saveChanges'.tr),
                      ).animate(autoPlay: false, controller: controller).shakeX(),
                    ]
                )
              ],
            )
        )
    );
  }
}

String getImageForGender(Gender gender) {
  switch(gender) {
    case Gender.male:
      return 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=640&q=80';
    case Gender.female:
      return 'https://images.unsplash.com/photo-1474978528675-4a50a4508dc3?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=640&q=80';
    case Gender.unspecified:
      return 'https://images.unsplash.com/photo-1594850598343-a5b0a83c237d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=640&q=80';
  }

}

class GuestAccountScreen extends StatelessWidget {
  const GuestAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    GuestApp guestApp = Get.find();
    return Scaffold(
      //backgroundColor: const Color(0xffF9F9F9),
      bottomNavigationBar: const GuestAppNavigationBar(currentIndex: 3),
      body: SingleChildScrollView(
        child: Padding(
          padding:
          const EdgeInsets.only(left: 16.0, right: 16.0, top: kToolbarHeight),
          child: Column(
            children: <Widget>[
              Obx(()=>CircleAvatar(
                  maxRadius: 48,
                  backgroundImage: CachedNetworkImageProvider(getImageForGender(guestApp.guestAccount.value.gender)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(()=>Text(
                    guestApp.guestAccount.value.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: appSettings.appTheme.pointsIndicatorBackgroundColor,
                  borderRadius: BorderRadius.circular(8),

                ),
                child: Obx(()=>Text(
                    "redeem.pointsAvailable".trParams({'points': guestApp.pointsRemaining.value.toString()}),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              const Divider(),
              ListTile(
                title: Text("guestApp.updateAccountInfo".tr),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Get.to(()=>const GuestAccountDetailScreen(registerMode: false));
                },
              ),
              const Divider(),
              ListTile(
                title: Text("guestApp.viewTransactionHistory".tr),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await guestApp.queryXtranGuest();
                  Get.to(()=>const XtranGuestListScreen());
                }
              ),
              const Divider(),
              ListTile(
                title: Text('gen.logout'.tr),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  if (await confirmDialog()) {
                    guestApp.logout();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}