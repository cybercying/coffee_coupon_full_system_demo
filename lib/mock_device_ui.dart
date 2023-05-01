/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:protocol/client_state.dart';
import 'admin_app/admin_app.dart';
import 'app_settings.dart';
import 'fields_builder.dart';
import 'ui_shared.dart';

class MockDeviceFieldsBuilder extends FieldsBuilder {
  bool isCreate = true;
  MockDevice mockDevice = MockDevice();

  MockDeviceFieldsBuilder({
    required super.app,
  }) {
    sectionDefs = [
      FieldSectionDef(label: 'mockDevice.information'.tr),
    ];
    fieldDefs = [
      FieldDef(
        tag: 'description',
        label: 'gen.description'.tr,
        width: FieldsBuilder.normalWidth,
        required: true,
        loadValue: () => mockDevice.description,
        saveValue: (value) => mockDevice.description = value,
      ),
      FieldDef(
        tag: 'email',
        label: 'gen.email'.tr,
        width: FieldsBuilder.normalWidth,
        loadValue: () => mockDevice.email,
        saveValue: (value) => mockDevice.email = value,
        allowSaveNull: true,
      ),
      FieldDef(
        tag: 'phone',
        label: 'gen.phone'.tr,
        width: FieldsBuilder.normalWidth,
        loadValue: () => mockDevice.phone,
        saveValue: (value) => mockDevice.phone = value,
        allowSaveNull: true,
        isPhoneNumber: true,
      ),
    ];
    if (app.selectedMockDevice != null) {
      mockDevice = MockDevice.fromJson(app.selectedMockDevice!.toJson()); // make a copy
      isCreate = false;
    }
  }

  Future<void> saveChanges() async {
    for(var field in fieldDefs) {
      if (field.saveValue != null) {
        field.saveValue!(values[field.tag]);
      }
    }
    await app.onMockDeviceChanged(mockDevice, isCreate: isCreate);
  }
}

class MockDeviceDetailScreen extends StatefulWidget {
  const MockDeviceDetailScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MockDeviceDetailScreenState();
  }
}

class _MockDeviceDetailScreenState extends State<MockDeviceDetailScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey  = GlobalKey();
  late AdminApp adminApp;
  late AppSettings appSettings;
  late MockDeviceFieldsBuilder fieldsBuilder;
  late AnimationController controller;

  Future<void> onSaveChanges() async {
    var formState = _formKey.currentState!;
    if (formState.validate()) {
      formState.save();
      guardUpdateOp(() async {
          await fieldsBuilder.saveChanges();
        },
        successMessage: 'mockDevice.ui.updated'.trParams({'description': fieldsBuilder.mockDevice.description ?? ''}),
        controller: controller
      );
    }
    else {
      controller.forward(from: 0);
    }
  }

  Future<void> onDelete() async {
    if (appSettings.isSelectedMockDeviceCurrentlyActive()) {
      await alertDialog('mockDevice.ui.cannotDeleteCurrentMockDevice'.tr);
    }
    else if (await confirmDeleteDialog()) {
      guardUpdateOp(() async {
          await appSettings.onMockDeviceChanged(appSettings.selectedMockDevice!, isDelete: true);
        },
        successMessage: 'mockDevice.ui.deleted'.trParams({'description': fieldsBuilder.mockDevice.description ?? ''})
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    adminApp = Get.find();
    appSettings = Get.find();
    controller = AnimationController(vsync: this);
    fieldsBuilder = MockDeviceFieldsBuilder(
        app: appSettings,
    );
    return Scaffold(
        appBar: AppBar(
          title: Text(fieldsBuilder.isCreate ? 'mockDevice.ui.createNew'.tr : 'mockDevice.ui.appBar'.tr),
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
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: onSaveChanges,
                        icon: const Icon(Icons.save),
                        heroTag: 'save',
                        label: Text(fieldsBuilder.isCreate ? 'gen.create'.tr : 'gen.saveChanges'.tr),
                      ).animate(autoPlay: false, controller: controller).shakeX(),
                      if (!fieldsBuilder.isCreate) const SizedBox(width: 20),
                      if (!fieldsBuilder.isCreate) FloatingActionButton.extended(
                        onPressed: onDelete,
                        backgroundColor: Colors.red,
                        icon: const Icon(Icons.lock_reset),
                        heroTag: 'delete',
                        label: Text('adminApp.delete'.tr),
                      )
                    ]
                )
              ],
            )
        )
    );
  }
}

