/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:developer';

import '../app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:protocol/protocol.dart';

import '../fields_builder.dart';
import '../testing_keys.dart';
import '../ui_shared.dart';
import 'admin_app.dart';
import 'admin_app_ui.dart';

class RedeemPolicyFieldsBuilder extends FieldsBuilder {
  RedeemPolicyFieldsBuilder({
    required super.app,
  }) {
    sectionDefs = [
      FieldSectionDef(label: 'redeemPolicy.ui.appBar'.tr),
    ];
    fieldDefs = [
      FieldDef(
        tag: 'title',
        label: 'redeemPolicy.title'.tr,
        width: FieldsBuilder.normalWidth,
        required: true,
        loadValue: () => redeemPolicy!.title,
        saveValue: (value) => redeemPolicy!.title = value!,
        isQueryCriteria: true
      ),
      FieldDef(
        tag: 'description',
        label: 'gen.description'.tr,
        width: FieldsBuilder.shorterWidth,
        required: true,
        loadValue: () => redeemPolicy!.description,
        saveValue: (value) => redeemPolicy!.description = value!,
        isQueryCriteria: true,
        numberOfLines: 3,
      ),
      FieldDef(
        tag: 'pointsRequired',
        label: 'redeemPolicy.pointsRequired'.tr,
        width: FieldsBuilder.shorterWidth,
        required: true,
        loadValue: () => redeemPolicy!.pointsRequired.toString(),
        saveValue: (value) => redeemPolicy!.pointsRequired = int.parse(value!),
        isInteger: true,
        isPositiveOnly: true,
      ),
      FieldDef(
        tag: 'status',
        label: 'user.isSuspended'.tr,
        loadValue: () => redeemPolicy!.status == RedeemPolicyStatus.suspended ? 'yes' : 'no',
        saveValue: (value) => redeemPolicy!.status = value == 'yes' ? RedeemPolicyStatus.suspended : RedeemPolicyStatus.normal,
        detailed: true,
        useSwitch: true,
      ),
      FieldDef(
        tag: 'imageUrl',
        label: 'gen.imageUrl'.tr,
        width: FieldsBuilder.normalWidth,
        loadValue: () => redeemPolicy!.imageUrl,
        saveValue: (value) => redeemPolicy!.imageUrl = value,
        isImageUrl: true,
        allowSaveNull: true,
        numberOfLines: 3,
      ),
      FieldDef(
        tag: 'attr',
        label: 'user.attr'.tr,
        width: FieldsBuilder.shorterWidth,
        loadValue: () {
          var lst = [
            if (redeemPolicy!.status == RedeemPolicyStatus.suspended) 'user.attr.suspended'.tr
          ];
          if (lst.isEmpty) {
            return null;
          }
          else {
            return lst.join('gen.sep'.tr);
          }
        },
        listOnly: true,
      ),
    ];
  }

  GenRedeemPolicy? redeemPolicy;

  List<Widget> buildRedeemPolicyFields(GenRedeemPolicy rec) {
    redeemPolicy = rec;
    return buildFields();
  }

  List<Widget> buildRedeemPolicyQueryFields(GenRedeemPolicy rec, {Function()? onFilterUpdated}) {
    redeemPolicy = rec;
    return [...buildQueryFields(),
      ElevatedButton(
          onPressed: (){
            saveFieldValues(queryCriteriaOnly: true);
            if (onFilterUpdated != null) {
              onFilterUpdated();
            }
          },
          child: Text("adminApp.filter".tr)
      )
    ];
  }

  void saveToSelectedRedeemPolicy(AdminApp adminApp) {
    if (!isCreating) {
      redeemPolicy = GenRedeemPolicy.fromJson(adminApp.selectedRedeemPolicy!.toJson());
    }
    saveFieldValues();
    adminApp.selectedRedeemPolicy = redeemPolicy;
  }
}

class RedeemPolicyListScreen extends StatelessWidget {
  const RedeemPolicyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    AdminApp adminApp = Get.find();
    return Scaffold(
        drawer: Drawer(
            child: getDrawerItems(context)
        ),
        appBar: AppBar(
          title: Text('adminApp.adminOf'.trParams({"fullName": adminApp.loggedInFullName.value})),
          actions: getAppbarActions(),
        ),
        bottomNavigationBar: const AdminAppNavigationBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            adminApp.selectedRedeemPolicy = null;
            Get.to(()=>const RedeemPolicyDetailScreen());
          },
          child: const Icon(Icons.add)
        ),
        body: Column(
          children: [
            QueryPanel(
                state: adminApp.redeemPolicyQuery,
                queryFields: RedeemPolicyFieldsBuilder(app: appSettings).buildRedeemPolicyQueryFields(
                    adminApp.redeemPolicyQuery.queryCriteria,
                    onFilterUpdated: ()=> adminApp.queryRedeemPolicyList()
                )
            ),
            Expanded(
              child: Obx(()=>buildTestableListView(
                context: context,
                itemCount: adminApp.redeemPolicyQuery.result.length,
                itemBuilder: (context,index) {
                  var rec = adminApp.redeemPolicyQuery.result[index];
                  return AttributeCard(
                      onTap: () {
                        adminApp.selectedRedeemPolicy = rec;
                        Get.to(() => const RedeemPolicyDetailScreen());
                      },
                      children: RedeemPolicyFieldsBuilder(app: appSettings).buildRedeemPolicyFields(rec)
                  );
                },
              )),
            ),
          ],
        )
    );
  }
}

class RedeemPolicyDetailScreen extends StatefulWidget {
  const RedeemPolicyDetailScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _RedeemPolicyDetailScreenState();
  }
}

class _RedeemPolicyDetailScreenState extends State<RedeemPolicyDetailScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey  = GlobalKey();
  late AdminApp adminApp;
  late RedeemPolicyFieldsBuilder fieldsBuilder;
  late AnimationController controller;

  Future<void> onSaveChanges() async {
    var formState = _formKey.currentState!;
    if (formState.validate()) {
      formState.save();
      fieldsBuilder.saveToSelectedRedeemPolicy(adminApp);
      guardUpdateOp(() async {
          await adminApp.updateSelectedRedeemPolicy();
          await adminApp.queryRedeemPolicyList();
        },
        successMessage: 'redeemPolicy.ui.updated'.trParams({'title': adminApp.selectedRedeemPolicy!.title}),
        controller: controller
      );
    }
    else {
      controller.forward(from: 0);
    }
  }

  Future<void> onDelete() async {
    if (await confirmDeleteDialog()) {
      guardUpdateOp(() async {
        await adminApp.deleteSelectedRedeemPolicy();
        await adminApp.queryRedeemPolicyList();
      }, successMessage: 'redeemPolicy.ui.deleted'.trParams({'title': adminApp.selectedRedeemPolicy!.title}));
    }
  }
  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    adminApp = Get.find();
    controller = AnimationController(vsync: this);
    fieldsBuilder = RedeemPolicyFieldsBuilder(app: appSettings);
    log('selectedRedeemPolicy: ${adminApp.selectedRedeemPolicy}');
    if (adminApp.selectedRedeemPolicy == null) { // we are creating record
      fieldsBuilder.redeemPolicy = GenRedeemPolicy.empty();
      fieldsBuilder.isCreating = true;
    }
    else {
      fieldsBuilder.redeemPolicy = adminApp.selectedRedeemPolicy;
    }
    return Scaffold(
        appBar: AppBar(
          title: fieldsBuilder.isCreating ? Text('redeemPolicy.ui.createNew'.tr) :  Text('redeemPolicy.ui.appBar'.tr),
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
                        key: TestingKeys.saveBtn,
                        onPressed: onSaveChanges,
                        icon: const Icon(Icons.save),
                        heroTag: 'save',
                        label: Text('gen.saveChanges'.tr),
                      ).animate(autoPlay: false, controller: controller).shakeX(),
                      if (!fieldsBuilder.isCreating) FloatingActionButton.extended(
                        key: TestingKeys.deleteBtn,
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
}

