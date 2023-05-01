/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:developer';

import 'package:coffee_coupon_full_system_demo/ui_shared.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:protocol/protocol.dart';

import '../fields_builder.dart';
import 'admin_app.dart';

class MockMessageFieldsBuilder extends FieldsBuilder {
  MockMessage? mockMessage;
  MockMessageFieldsBuilder({
    required super.app,
  }) {
    sectionDefs = [
      FieldSectionDef(label: "mockMessage.section.main".tr),
    ];
    fieldDefs = [
      FieldDef(
        tag: 'time',
        label: 'gen.time'.tr,
        width: FieldsBuilder.dateTimeWidth,
        loadValue: () => app.fmtDate(mockMessage!.time, detailed: true),
      ),
      FieldDef(
        tag: 'email',
        label: 'gen.email'.tr,
        width: FieldsBuilder.normalWidth,
        loadValue: () => mockMessage!.email,
      ),
      FieldDef(
        tag: 'phone',
        label: 'gen.phone'.tr,
        width: FieldsBuilder.shorterWidth,
        loadValue: () => mockMessage!.phone,
      ),
      FieldDef(
        tag: 'content',
        label: 'gen.content'.tr,
        width: 400,
        loadValue: () => mockMessage!.content,
      ),
    ];
  }

  List<Widget> buildMockMessageFields(MockMessage mockMessage) {
    this.mockMessage = mockMessage;
    return buildFields();
  }
}

class MockMessageServerListScreen extends StatelessWidget {
  const MockMessageServerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    AdminApp adminApp = Get.find();
    return Scaffold(
        appBar: AppBar(
          title: Text('mockMessage.ui.list.appBar'.tr),
        ),
        body: Obx(()=>buildTestableListView(
            context: context,
            itemCount: adminApp.mockMessageQueryResult.length,
            itemBuilder: (context,index) {
              var rec = adminApp.mockMessageQueryResult[index];
              return AttributeCard(
                  children: MockMessageFieldsBuilder(app: appSettings).buildMockMessageFields(rec)
              );
            },
         ),
       )
    );
  }
}

class MockMessageListScreen extends StatelessWidget {
  final MockNotificationListener mockListener;
  const MockMessageListScreen({
    super.key,
    required this.mockListener
  });

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    return Scaffold(
        appBar: AppBar(
          title: Text("mockMessage.ui.inboxOf".trParams(
              {'name': mockListener.receiver.description ?? ''})),
        ),
        body: Obx(()=>buildTestableListView(
            context: context,
            itemCount: mockListener.inbox.length,
            itemBuilder: (context,index) {
              var rec = mockListener.inbox[index];
              return AttributeCard(
                  icon: getIconForType(rec.type),
                  onTap: () {
                    Get.to(()=>MockMessageDetailScreen(mockListener: mockListener, mockMessage: rec));
                  },
                  children: MockMessageFieldsBuilder(app: appSettings).buildMockMessageFields(rec)
              );
            },
          ),
        )
    );
  }

  Icon getIconForType(MockMessageType type) {
    switch(type) {
      case MockMessageType.sms:
        return const Icon(Icons.sms_outlined);
      case MockMessageType.email:
        return const Icon(Icons.email_outlined);
    }
  }
}

class MockMessageDetailScreen extends StatefulWidget {
  final MockNotificationListener mockListener;
  final MockMessage mockMessage;
  const MockMessageDetailScreen({
    super.key,
    required this.mockListener,
    required this.mockMessage
  });
  @override
  State<MockMessageDetailScreen> createState() => _MockMessageDetailScreenState();
}

class _MockMessageDetailScreenState extends State<MockMessageDetailScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey  = GlobalKey();
  late AppSettings appSettings;
  late MockMessageFieldsBuilder fieldsBuilder;
  late AnimationController controller;

  void onSaveChanges() {

  }

  Future<void> onDelete() async {
    if (await confirmDeleteDialog()) {
      Get.back();
      await widget.mockListener.conn.sendServerCommand(ServerCommand(
        updateMockMessageCommand: UpdateMockMessageCommand(
          idToDelete: widget.mockMessage.id!
        )
      ));
      widget.mockListener.queryMockMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    appSettings = Get.find();
    controller = AnimationController(vsync: this);
    fieldsBuilder = MockMessageFieldsBuilder(
      app: appSettings
    );
    fieldsBuilder.mockMessage = widget.mockMessage;
    return Scaffold(
        appBar: AppBar(
          title: Text("mockMessage.ui.appBar".tr),
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
                        child: fieldsBuilder.buildCardSettings(onSubmitted: onSaveChanges),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       if (widget.mockMessage.authKey != null)
                       FloatingActionButton.extended(
                        onPressed: onResetPassword,
                        backgroundColor: Colors.brown,
                        icon: const Icon(Icons.lock_reset),
                        heroTag: 'resetPassword',
                        label: Text('adminApp.resetPassword'.tr),
                      ),
                      FloatingActionButton.extended(
                        onPressed: onDelete,
                        backgroundColor: Colors.red,
                        icon: const Icon(Icons.delete),
                        heroTag: 'delete',
                        label: Text('adminApp.delete'.tr),
                      ),
                    ]
                )
              ],
            )
        )
    );
  }

  void onResetPassword() {
    Get.to(()=>ResetPasswordScreen(mockListener: widget.mockListener, mockMessage: widget.mockMessage));
  }
}

class ResetPasswordFieldsBuilder extends FieldsBuilder {
  String password = '';
  String retypePassword = '';
  ResetPasswordFieldsBuilder({
    required super.app,
  }) {
    sectionDefs = [
      FieldSectionDef(label: "adminApp.resetPassword".tr),
    ];
    fieldDefs = [
      FieldDef(
        tag: 'password',
        label: 'gen.password'.tr,
        width: FieldsBuilder.normalWidth,
        required: true,
        loadValue: () => password,
        saveValue: (value) => password = value!,
      ),
      FieldDef(
        tag: 'retypePassword',
        label: "gen.retypePassword".tr,
        width: FieldsBuilder.normalWidth,
        required: true,
        loadValue: () => retypePassword,
        saveValue: (value) => retypePassword = value!,
      ),
    ];
  }
}

class ResetPasswordScreen extends StatefulWidget {
  final MockNotificationListener mockListener;
  final MockMessage mockMessage;
  const ResetPasswordScreen({super.key, required this.mockListener, required this.mockMessage});

  @override
  State<StatefulWidget> createState() {
    return _ResetPasswordScreenState();
  }
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey  = GlobalKey();
  late AdminApp adminApp;
  late ResetPasswordFieldsBuilder fieldsBuilder;
  late AnimationController controller;

  Future<void> onSaveChanges() async {
    _formKey.currentState!.save();
    fieldsBuilder.saveFieldValues();
    log('password: ${fieldsBuilder.password}, retype: ${fieldsBuilder.retypePassword}');
    if (fieldsBuilder.password != fieldsBuilder.retypePassword) {
      controller.forward(from: 0);
      await alertErrorDialog("gen.passwordMismatch".tr);
      return;
    }
    try {
      var conn = widget.mockListener.conn.createAnotherConnection();
      var resp = await conn.sendServerCommand(ServerCommand(
          resetPasswordCommand: ResetPasswordCommand(
              enteredAuthKey: widget.mockMessage.authKey
          )
      ));
      var generatedPassword = resp.resetPasswordResponse!.generatedPassword!;
      var hashedPassword = SharedApi.encryptedDigest(generatedPassword);
      var email = widget.mockMessage.email!;
      DateTime time = DateTime.now();
      await conn.login(LoginCommand(
          email: email,
          actuatedHashedPassword: SharedApi.actuatedHashedPassword(
              email,
              hashedPassword, time
          ),
          time: time
      ));
      await conn.sendServerCommand(ServerCommand(
          changePasswordCommand: ChangePasswordCommand(
              hashedPassword,
              SharedApi.encryptedDigest(fieldsBuilder.password)
          )
      ));
      await alertDialog('adminApp.operationSuccess'.tr);
      Get.back();
    }
    on ServerException catch(e, st) {
      controller.forward(from: 0);
      log('resetPassword: $e, $st');
      await alertServerError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    adminApp = Get.find();
    controller = AnimationController(vsync: this);
    fieldsBuilder = ResetPasswordFieldsBuilder(
      app: appSettings,
    );
    return Scaffold(
        appBar: AppBar(
          title: fieldsBuilder.isCreating ? Text('user.ui.createNew'.tr) :  Text('user.ui.appBar'.tr),
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
                        child: fieldsBuilder.buildCardSettings(onSubmitted: onSaveChanges),
                      ),
                    ),
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

