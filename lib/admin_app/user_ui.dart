/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
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

class UserFieldsBuilder extends FieldsBuilder {
  GenStore? managingStore;
  List<GenStore>? linkedStores;
  UserFieldsBuilder({
    required super.app,
    this.managingStore,
    this.linkedStores,
  }) {
    sectionDefs = [
      FieldSectionDef(label: 'user.section.main'.tr),
      FieldSectionDef(label: 'user.section.informativeFields'.tr),
    ];
    fieldDefs = [
      FieldDef(
        key: TestingKeys.userFullNameEdit,
        tag: 'fullName',
        label: 'gen.fullName'.tr,
        width: FieldsBuilder.normalWidth,
        required: true,
        loadValue: () => user!.fullName,
        saveValue: (value) => user!.fullName = value!,
        isQueryCriteria: true
      ),
      FieldDef(
          key: TestingKeys.userEmailEdit,
          tag: 'email',
          label: 'gen.email'.tr,
          width: FieldsBuilder.normalWidth,
          required: true,
          loadValue: () => user!.email,
          saveValue: (value) => user!.email = value!,
          isEmail: true,
          isQueryCriteria: true
      ),
      FieldDef(
        key: TestingKeys.userPhoneEdit,
        tag: 'phone',
        label: 'gen.phone'.tr,
        width: FieldsBuilder.shorterWidth,
        required: true,
        loadValue: () => user!.phone,
        saveValue: (value) => user!.phone = value!,
        isPhoneNumber: true,
        isQueryCriteria: true
      ),
      FieldDef(
          tag: 'lastLoggedIn',
          label: 'user.lastLoggedIn'.tr,
          width: FieldsBuilder.dateWidth,
          loadValue: () => app.fmtDate(user!.lastLoggedIn),
          loadValueDetailed: () => app.fmtDate(user!.lastLoggedIn, detailed: true),
          section: 1
      ),
      FieldDef(
          tag: 'created',
          label: 'user.created'.tr,
          width: FieldsBuilder.dateWidth,
          loadValue: () => app.fmtDate(user!.created),
          loadValueDetailed: () => app.fmtDate(user!.created, detailed: true),
          section: 1
      ),
      FieldDef(
        tag: 'lastUpdated',
        label: 'user.lastUpdated'.tr,
        width: FieldsBuilder.dateWidth,
        loadValue: ()=>app.fmtDate(user!.lastUpdated),
        loadValueDetailed: () => app.fmtDate(user!.lastUpdated, detailed: true),
        section: 1,
      ),
      FieldDef(
        tag: 'fAdmin',
        label: 'user.fAdmin'.tr,
        loadValue: () => user!.fAdmin ? 'yes' : 'no',
        saveValue: (value) => user!.fAdmin = value == 'yes',
        detailed: true,
        useSwitch: true,
      ),
      FieldDef(
        tag: 'status',
        label: 'user.isSuspended'.tr,
        loadValue: () => user!.status == UserStatus.suspended ? 'yes' : 'no',
        saveValue: (value) => user!.status = value == 'yes' ? UserStatus.suspended : UserStatus.normal,
        detailed: true,
        useSwitch: true,
      ),
      FieldDef(
        tag: 'attr',
        label: 'user.attr'.tr,
        width: FieldsBuilder.shorterWidth,
        loadValue: () {
          var lst = [
            if (user!.fAdmin) 'user.attr.admin'.tr,
            if (user!.status == UserStatus.suspended) 'user.attr.suspended'.tr,
            if (managingStore != null &&
                managingStore!.users.where((su) => su.uid == user?.uid && su.role == UserRoleAtStore.manager).isNotEmpty) 'store.role.manager'.tr,
            if (managingStore != null &&
                managingStore!.users.where((su) => su.uid == user?.uid && su.role == UserRoleAtStore.staff).isNotEmpty) 'store.role.staff'.tr,
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
      FieldDef(
        tag: 'plainPassword',
        label: 'gen.password'.tr,
        width: FieldsBuilder.normalWidth,
        required: true,
        loadValue: () => user!.plainPassword,
        isEmail: true,
      ),
      FieldDef(
        tag: 'linkedStores',
        label: "user.linkedStores".tr,
        width: FieldsBuilder.normalWidth,
        loadValue: () {
          var lst = [];
          if (linkedStores != null) {
            for(var su in user!.stores) {
              var store = linkedStores!.firstWhereOrNull((element) => element.storeId == su.storeId);
              if (store != null) {
                lst.add("user.linkedStoreItem".trParams({
                  'name': store.name,
                  'role': 'store.role.${su.role.name}'.tr
                }));
              }
            }
          }
          return lst.join('gen.sep'.tr);
        },
        detailed: true,
        notForCreating: true,
      ),
    ];
  }

  GenUser? user;

  List<Widget> buildUserFields(GenUser rec) {
    user = rec;
    return buildFields();
  }

  List<Widget> buildUserQueryFields(GenUser rec, {Function()? onFilterUpdated}) {
    user = rec;
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

  void saveToSelectedUser(AdminApp adminApp) {
    if (!isCreating) {
      user = GenUser.fromJson(adminApp.selectedUser!.toJson());
    }
    saveFieldValues();
    adminApp.selectedUser = user;
  }
}

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

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
            adminApp.selectedUser = null;
            Get.to(()=>const UserDetailScreen());
          },
          child: const Icon(Icons.add)
        ),
        body: Column(
          children: [
            const ManagingStorePanel(),
            QueryPanel(
                state: adminApp.userQuery,
                queryFields: UserFieldsBuilder(app: appSettings).buildUserQueryFields(
                    adminApp.userQuery.queryCriteria,
                    onFilterUpdated: ()=> adminApp.queryUserList()
                )
            ),
            Expanded(
              child: Obx(()=>buildTestableListView(
                context: context,
                itemCount: adminApp.userQuery.result.length,
                itemBuilder: (context,index) {
                  var rec = adminApp.userQuery.result[index];
                  return UserItemCard(
                      key: Key(rec.email),
                      adminApp: adminApp,
                      rec: rec,
                      appSettings: appSettings);
                },
              )),
            ),
          ],
        )
    );
  }
}

class UserItemCard extends StatelessWidget {
  final GenUser rec;
  final AppSettings appSettings;
  final Widget? icon;
  final AdminApp adminApp;
  const UserItemCard({
    super.key,
    required this.rec,
    required this.appSettings,
    required this.adminApp,
    this.icon,
  });

  Future<void> onTap() async {
    await adminApp.selectUserForEditing(rec);
    Get.to(()=>const UserDetailScreen());
  }

  @override
  Widget build(BuildContext context) {
    return AttributeCard(
        icon: icon,
        onTap: onTap,
        children: UserFieldsBuilder(app: appSettings, managingStore: adminApp.managingStore.value).buildUserFields(rec)
    );
  }
}

class UserDetailScreen extends StatefulWidget {
  const UserDetailScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserDetailScreenState();
  }
}

class _UserDetailScreenState extends State<UserDetailScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey  = GlobalKey();
  late AdminApp adminApp;
  late UserFieldsBuilder fieldsBuilder;
  late AnimationController controller;

  bool isCurrentlyLoggedInUserSelected() {
    return adminApp.loginResponse!.loggedInUser!.uid == adminApp.selectedUser!.uid;
  }

  Future<void> onResetPassword() async {
    if (isCurrentlyLoggedInUserSelected()) {
      if (!await confirmDialog(content: 'adminApp.warnModifyCurrentUser'.tr, key: TestingKeys.warnModifyCurrentUser)) {
        return;
      }
    }
    uiSimpleDialog('adminApp.resetPasswordDialogTitle'.tr, [
      // OptionAndPressed('adminApp.resetPasswordByPhone'.tr, () async {
      //   if (await confirmDialog(content: 'adminApp.confirmResetPasswordByPhone'.trParams({'phone': adminApp.selectedUser!.phone}))) {
      //     await adminApp.conn.sendServerCommand(ServerCommand(
      //         resetPasswordCommand: ResetPasswordCommand(
      //             passwordReassignment: PasswordReassignmentRec(
      //               identityType: IdentityType.user,
      //               resetPasswordType: ResetPasswordType.phone,
      //               phone: adminApp.selectedUser!.phone,
      //             )
      //         )
      //     ));
      //     Get.back();
      //     await uiNotifyUpdateSuccess();
      //   }
      // }),
      OptionAndPressed('adminApp.resetPasswordByEmail'.tr, () {
        confirmDialog(content: 'adminApp.confirmResetPasswordByEmail'.trParams({'email': adminApp.selectedUser!.email}), onPressed: () async {
          await adminApp.conn.sendServerCommand(ServerCommand(
              resetPasswordCommand: ResetPasswordCommand(
                  passwordReassignment: PasswordReassignmentRec(
                    identityType: IdentityType.user,
                    resetPasswordType: ResetPasswordType.email,
                    email: adminApp.selectedUser!.email,
                  )
              )
          ));
          Get.back();
          await uiNotifyUpdateSuccess();
        });
      }),
      // OptionAndPressed('adminApp.directlyAssign'.tr, () {
      // }),
    ]);
  }

  Future<void> onSaveChanges() async {
    var formState = _formKey.currentState!;
    if (formState.validate()) {
      if (!fieldsBuilder.isCreating && isCurrentlyLoggedInUserSelected()) {
        if (!await confirmDialog(content: 'adminApp.warnModifyCurrentUser'.tr, key: TestingKeys.warnModifyCurrentUser)) {
          return;
        }
      }
      formState.save();
      fieldsBuilder.saveToSelectedUser(adminApp);
      guardUpdateOp(() async {
          await adminApp.updateSelectedUser();
          await adminApp.queryUserList();
        },
        successMessage: 'user.ui.updated'.trParams({'email': adminApp.selectedUser!.email}),
        controller: controller
      );
    }
    else {
      controller.forward(from: 0);
    }
  }

  Future<void> onDelete() async {
    if (await confirmDeleteDialog(content: adminApp.managingStore.value == null ? null: "user.ui.areYouSureToRemoveFromStore".tr)) {
      guardUpdateOp(() async {
        await adminApp.deleteSelectedUser();
        await adminApp.queryUserList();
      }, successMessage: adminApp.managingStore.value != null ?
        'user.ui.removedFromStore'.trParams({'email': adminApp.selectedUser!.email}) :
        'user.ui.deleted'.trParams({'email': adminApp.selectedUser!.email})
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    adminApp = Get.find();
    controller = AnimationController(vsync: this);
    fieldsBuilder = UserFieldsBuilder(
        app: appSettings,
        linkedStores: adminApp.selectedUserStores,
    );
    if (adminApp.selectedUser == null) { // we are creating record
      fieldsBuilder.user = GenUser(email: '', fullName: '', phone: '');
      fieldsBuilder.isCreating = true;
    }
    else {
      fieldsBuilder.user = adminApp.selectedUser;
    }
    return Scaffold(
        appBar: AppBar(
          title: fieldsBuilder.isCreating ? Text('user.ui.createNew'.tr) :  Text('user.ui.appBar'.tr),
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
                        onPressed: onResetPassword,
                        backgroundColor: Colors.brown,
                        icon: const Icon(Icons.lock_reset),
                        heroTag: 'resetPassword',
                        label: Text('adminApp.resetPassword'.tr),
                      ),
                      if (!fieldsBuilder.isCreating) Obx(()=>FloatingActionButton.extended(
                          key: TestingKeys.deleteBtn,
                          onPressed: onDelete,
                          backgroundColor: Colors.red,
                          icon: const Icon(Icons.delete),
                          heroTag: 'delete',
                          label: Text(adminApp.managingStore.value == null ? 'adminApp.delete'.tr : "user.ui.removeFromStore".tr),
                        ),
                      ),
                    ]
                )
              ],
            )
        )
    );
  }
}

