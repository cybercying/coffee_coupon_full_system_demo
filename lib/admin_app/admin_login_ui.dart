/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'package:card_settings/card_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../card_settings_fixes.dart';
import '../testing_keys.dart';
import '../ui_shared.dart';
import 'admin_app.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AdminLoginScreenState();
  }
}

class _AdminLoginScreenState extends State<AdminLoginScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController controller;
  late AnimationController controller2;

  void onLoginPressed() async {
    AdminApp adminApp = Get.find();
    if (_formKey.currentState!.validate()) {
      if (!await adminApp.login()) {
        uiNotifyError('adminApp.loginFailed'.tr);
        controller2.forward(from: 0);
      }
    }
    else {
      controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    AdminApp adminApp = Get.find();
    controller = AnimationController(vsync: this);
    controller2 = AnimationController(vsync: this);
    return Scaffold(
       appBar: AppBar(
         actions: getAppbarActions()
       ),
      // floatingActionButton: FloatingActionButton(
      //   tooltip: "main.hintOpenDemoSetting".tr,
      //   onPressed: () {
      //     Get.to(()=>const DemoSettingScreen());
      //   },
      //   child: const Icon(Icons.build),
      // ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
              key: _formKey,
              child: CardSettings.sectioned(
                  showMaterialonIOS: true,
                  labelWidth: 150,
                  contentAlign: TextAlign.left,
                  margin: const EdgeInsets.all(20),
                  children: <CardSettingsSection>[
                    CardSettingsSection(
                      header: CardSettingsHeader(
                        label: 'adminApp.staffLogin'.tr,
                      ),
                      children: <CardSettingsWidget>[
                        CardSettingsEmail(
                          icon: const Icon(Icons.person),
                          label: 'gen.email'.tr,
                          initialValue: adminApp.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'adminApp.emailIsRequired'.tr;
                            if (!value.contains('@')) {
                              return 'adminApp.emailFormatError'.tr; // use regex in real application
                            }
                            return null;
                          },
                          onChanged: (value) => adminApp.email = value,
                        ),
                        CardSettingsPassword(
                          icon: const Icon(Icons.lock),
                          label: 'gen.password'.tr,
                          initialValue: adminApp.password,
                          validator: (value) {
                            if (value == null) return 'adminApp.passwordIsRequired'.tr;
                            return null;
                          },
                          onFieldSubmitted: (_) => onLoginPressed(),
                          onChanged: (value) => adminApp.password = value,
                        ),
                        CardFieldLayout2(<CardSettingsWidget>[
                          CardSettingsButton2(
                            key: TestingKeys.loginBtn,
                            label: 'adminApp.login'.tr,
                            backgroundColor: Colors.indigo,
                            onPressed: onLoginPressed,
                            bottomSpacing: 20,
                          ),
                        ])

                      ],
                    ),
                  ]
              )
          )
              .animate(autoPlay: false, controller: controller).shake()
              .animate(autoPlay: false, controller: controller2).shakeY(),
        ),
      ),
    );
  }
}

