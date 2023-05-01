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

class StoreFieldsBuilder extends FieldsBuilder {
  List<GenUser>? linkedUsers;
  StoreFieldsBuilder({
    required super.app,
    this.linkedUsers
  }) {
    sectionDefs = [
      FieldSectionDef(label: 'store.section.main'.tr),
    ];
    fieldDefs = [
      FieldDef(
        tag: 'name',
        label: 'store.name'.tr,
        width: FieldsBuilder.normalWidth,
        required: true,
        loadValue: () => store!.name,
        saveValue: (value) => store!.name = value!,
        isQueryCriteria: true
      ),
      FieldDef(
          tag: 'address',
          label: 'gen.address'.tr,
          width: FieldsBuilder.normalWidth,
          required: true,
          loadValue: () => store!.address,
          saveValue: (value) => store!.address = value!,
          isQueryCriteria: true
      ),
      FieldDef(
        tag: 'phone',
        label: 'gen.phone'.tr,
        width: FieldsBuilder.shorterWidth,
        required: true,
        loadValue: () => store!.phone,
        saveValue: (value) => store!.phone = value!,
        isPhoneNumber: true,
        isQueryCriteria: true
      ),
      FieldDef(
        tag: 'status',
        label: 'user.isSuspended'.tr,
        loadValue: () => store!.status == StoreStatus.suspended ? 'yes' : 'no',
        saveValue: (value) => store!.status = value == 'yes' ? StoreStatus.suspended : StoreStatus.normal,
        detailed: true,
        useSwitch: true,
      ),
      FieldDef(
        tag: 'linkedUsers',
        label: "store.linkedUsers".tr,
        width: FieldsBuilder.normalWidth,
        loadValue: () {
          var lst = [];
          if (linkedUsers != null) {
            for(var su in store!.users) {
              var user = linkedUsers!.firstWhereOrNull((element) => element.uid == su.uid);
              if (user != null) {
                lst.add("store.linkedUserItem".trParams({
                  'fullName': user.fullName,
                  'role': 'store.role.${su.role.name}'.tr
                }));
              }
            }
          }
          return lst.join('gen.sep'.tr);
        },
        detailed: true,
        notForCreating: true,
        tapMessage: "store.ui.linkedUserHint".tr,
      ),
      FieldDef(
        tag: 'imageUrl',
        label: 'gen.imageUrl'.tr,
        width: FieldsBuilder.normalWidth,
        loadValue: () => store!.imageUrl,
        saveValue: (value) => store!.imageUrl = value,
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
            if (store!.status == StoreStatus.suspended) 'user.attr.suspended'.tr
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

  GenStore? store;

  List<Widget> buildStoreFields(GenStore rec) {
    store = rec;
    return buildFields();
  }

  List<Widget> buildStoreQueryFields(GenStore rec, {Function()? onFilterUpdated}) {
    store = rec;
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

  void saveToSelectedStore(AdminApp adminApp) {
    if (!isCreating) {
      store = GenStore.fromJson(adminApp.selectedStore!.toJson());
    }
    saveFieldValues();
    adminApp.selectedStore = store;
  }
}

class AddUserToStoreBuilder extends FieldsBuilder {
  String email = "";
  GenStore addToStore;
  UserRoleAtStore role;
  AddUserToStoreBuilder({
    required super.app,
    required this.addToStore,
    required this.role,
  }) {
    sectionDefs = [
      FieldSectionDef(label: "store.ui.addUser".tr),
    ];
    fieldDefs = [
      FieldDef(
          tag: 'email',
          label: 'gen.email'.tr,
          width: FieldsBuilder.normalWidth,
          required: true,
          loadValue: () => email,
          saveValue: (value) => email = value!,
          isEmail: true,
      ),
      FieldDef(
          tag: 'addToStore',
          label: "store.ui.addToStore".tr,
          width: FieldsBuilder.normalWidth,
          loadValue: () => addToStore.name,
      ),
      FieldDef(
          tag: 'role',
          label: 'store.role'.tr,
          width: FieldsBuilder.shorterWidth,
          required: true,
          loadValue: () => role.name,
          saveValue: (value) => role = UserRoleAtStore.values.byName(value!),
          useRadioPicker: true,
          getChoices: () => [
            Choice(UserRoleAtStore.staff.name, 'store.role.staff'.tr),
            Choice(UserRoleAtStore.manager.name, 'store.role.manager'.tr),
          ]
      ),
    ];
  }
}

class StoreListScreen extends StatelessWidget {
  const StoreListScreen({super.key});

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
            adminApp.selectedStore = null;
            Get.to(()=>const StoreDetailScreen());
          },
          child: const Icon(Icons.add)
        ),
        body: Column(
          children: [
            const ManagingStorePanel(),
            QueryPanel(
                state: adminApp.storeQuery,
                queryFields: StoreFieldsBuilder(app: appSettings).buildStoreQueryFields(
                    adminApp.storeQuery.queryCriteria,
                    onFilterUpdated: ()=> adminApp.queryStoreList()
                )
            ),
            Expanded(
              child: Obx(()=>buildTestableListView(
                context: context,
                itemCount: adminApp.storeQuery.result.length,
                itemBuilder: (context,index) {
                  var rec = adminApp.storeQuery.result[index];
                  return Obx(()=>AttributeCard(
                        color: adminApp.managingStore.value?.storeId == rec.storeId ? appSettings.appTheme.managingStoreColor : null,
                        onTap: () async {
                          await adminApp.selectStoreForEditing(rec);
                          Get.to(() => const StoreDetailScreen());
                        },
                        children: StoreFieldsBuilder(app: appSettings).buildStoreFields(rec)
                    ),
                  );
                },
              )),
            ),
          ],
        )
    );
  }
}

class StoreDetailScreen extends StatefulWidget {
  const StoreDetailScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _StoreDetailScreenState();
  }
}

class _StoreDetailScreenState extends State<StoreDetailScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey  = GlobalKey();
  late AdminApp adminApp;
  late StoreFieldsBuilder fieldsBuilder;
  late AnimationController controller;
  bool dirty = false;

  Future<void> onSaveChanges() async {
    var formState = _formKey.currentState!;
    if (formState.validate()) {
      formState.save();
      fieldsBuilder.saveToSelectedStore(adminApp);
      guardUpdateOp(() async {
          await adminApp.updateSelectedStore();
          await adminApp.queryStoreList();
        },
        successMessage: 'store.ui.updated'.trParams({'name': adminApp.selectedStore!.name}),
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
        await adminApp.deleteSelectedStore();
        await adminApp.queryStoreList();
      }, successMessage: 'store.ui.deleted'.trParams({'name': adminApp.selectedStore!.name}));
    }
  }

  Future<void> onManage() async {
    adminApp.managingStore.value = adminApp.selectedStore;
    adminApp.saved.managingStoreId = adminApp.selectedStore?.storeId;
    adminApp.saveState();
    uiNotifyUpdateSuccess("store.ui.thisStoreIsActivatedForManaging".tr, "store.ui.managingStore".tr);
  }

  Future<void> onStopManage() async {
    adminApp.managingStore.value = null;
  }

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    adminApp = Get.find();
    controller = AnimationController(vsync: this);
    fieldsBuilder = StoreFieldsBuilder(
        app: appSettings,
        linkedUsers: adminApp.selectedStoreUsers,
    );
    log('selectedStore: ${adminApp.selectedStore}');
    if (adminApp.selectedStore == null) { // we are creating record
      fieldsBuilder.store = GenStore.empty();
      fieldsBuilder.isCreating = true;
    }
    else {
      fieldsBuilder.store = adminApp.selectedStore;
    }
    return Scaffold(
        appBar: AppBar(
          title: fieldsBuilder.isCreating ? Text('store.ui.createNew'.tr) :  Text('store.ui.appBar'.tr),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const ManagingStorePanel(),
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Form(
                        key: _formKey,
                        onChanged: () {
                          dirty = true;
                        },
                        child: fieldsBuilder.buildCardSettings(onSubmitted: onSaveChanges),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(()=>Wrap(
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
                        onPressed: () async{
                          if (dirty) {
                            if (!await confirmDialog(content: "gen.discardChangePrompt".tr)) {
                              return;
                            }
                          }
                          Get.off(()=>AddUserToStoreScreen(addToStore: adminApp.selectedStore!));
                        },
                        heroTag: 'addUser',
                        label: Text("store.ui.addUserBtn".tr),
                      ),
                      if (adminApp.managingStore.value != adminApp.selectedStore && !fieldsBuilder.isCreating) FloatingActionButton.extended(
                        onPressed: onManage,
                        heroTag: 'manage',
                        label: Text("store.ui.manage".tr),
                      ),
                      if (!fieldsBuilder.isCreating) FloatingActionButton.extended(
                        key: TestingKeys.deleteBtn,
                        onPressed: onDelete,
                        backgroundColor: Colors.red,
                        icon: const Icon(Icons.delete),
                        heroTag: 'delete',
                        label: Text('adminApp.delete'.tr),
                      ),
                    ]
                  ),
                )
              ],
            )
        )
    );
  }
}

class AddUserToStoreScreen extends StatefulWidget {
  final GenStore addToStore;
  const AddUserToStoreScreen({super.key, required this.addToStore});

  @override
  State<AddUserToStoreScreen> createState() => _AddUserToStoreScreenState();
}

class _AddUserToStoreScreenState extends State<AddUserToStoreScreen> with TickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  late AnimationController controller;
  late AddUserToStoreBuilder fieldsBuilder;

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    controller = AnimationController(vsync: this);
    fieldsBuilder = AddUserToStoreBuilder(app: appSettings, addToStore: widget.addToStore, role: UserRoleAtStore.staff);
    return Scaffold(
        appBar: AppBar(
          title: Text("store.ui.addUser".tr),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const ManagingStorePanel(),
                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Form(
                        key: formKey,
                        child: fieldsBuilder.buildCardSettings(onSubmitted: onAddUserSubmit),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        key: TestingKeys.saveBtn,
                        onPressed: onAddUserSubmit,
                        icon: const Icon(Icons.add),
                        heroTag: 'add',
                        label: Text("store.ui.addToStoreBtn".tr),
                      ).animate(autoPlay: false, controller: controller).shakeX()
                    ]
                ),
              ],
            )
        )
    );
  }

  Future<void> onAddUserSubmit() async {
    var formState = formKey.currentState!;
    if (formState.validate()) {
      formState.save();
      fieldsBuilder.saveFieldValues();
      await guardUpdateOp(() async {
        AdminApp adminApp = Get.find();
        await adminApp.addUserToStore(
            fieldsBuilder.email, fieldsBuilder.addToStore, fieldsBuilder.role);
        await adminApp.queryStoreList();
      }, controller: controller);
    }
    else {
      controller.forward(from: 0);
    }
  }
}