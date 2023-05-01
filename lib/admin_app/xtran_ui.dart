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

class TransactionFieldsBuilder extends FieldsBuilder {
  GenStore? managingStore;
  TransactionFieldsBuilder({
    required super.app,
    this.managingStore,
  }) {
    sectionDefs = [
      FieldSectionDef(label: 'xtran.section.main'.tr),
      FieldSectionDef(label: 'xtran.section.linked'.tr),
    ];
    fieldDefs = [
      FieldDef(
        tag: 'description',
        label: 'gen.description'.tr,
        width: FieldsBuilder.normalWidth,
        required: false,
        loadValue: () => transaction!.description,
        saveValue: (value) => transaction!.description = value,
        isQueryCriteria: true,
        allowSaveNull:  true,
      ),
      FieldDef(
        tag: 'time',
        label: 'gen.time'.tr,
        width: FieldsBuilder.dateWidth,
        loadValue: () => app.fmtDate(transaction!.time),
        loadValueDetailed: () => app.fmtDate(transaction!.time, detailed: true),
      ),
      FieldDef(
        tag: 'type',
        label: 'xtran.type'.tr,
        width: FieldsBuilder.shorterWidth,
        required: true,
        loadValue: () => transaction!.type.name,
        saveValue: (value) => transaction!.type = TransactionType.values.byName(value!),
        useRadioPicker: true,
        getChoices: () => [
          Choice(TransactionType.orderCompleted.name, 'xtran.type.orderCompleted'.tr),
          Choice(TransactionType.storeGift.name, 'xtran.type.storeGift'.tr),
          Choice(TransactionType.pointsRedeem.name, 'xtran.type.pointsRedeem'.tr),
        ],
        detailed: true,
      ),
      FieldDef(
        tag: 'type2',
        label: 'xtran.type'.tr,
        width: FieldsBuilder.shorterWidth,
        required: true,
        loadValue: () => 'xtran.type.${transaction!.type.name}'.tr,
        listOnly: true,
      ),
      FieldDef(
        tag: 'points',
        width: FieldsBuilder.shorter2Width,
        label: 'xtran.points'.tr,
        loadValue: () => transaction!.points.toString(),
        saveValue: (value) => transaction!.points = int.parse(value!),
        isInteger: true,
        required: true,
        cannotBeZero: true,
      ),
      FieldDef(
        tag: 'linkedUser',
        width: FieldsBuilder.shorterWidth,
        label: 'xtran.linkedUser'.tr,
        loadValue: () => transaction?.linkedInfo?.user?.fullName,
        section: 1,
      ),
      FieldDef(
        tag: 'linkedStore',
        width: FieldsBuilder.shorterWidth,
        label: 'xtran.linkedStore'.tr,
        loadValue: () => transaction?.linkedInfo?.store?.name,
        section: 1,
      ),
      FieldDef(
        tag: 'linkedGuest',
        width: FieldsBuilder.shorterWidth,
        label: 'xtran.linkedGuest'.tr,
        loadValue: () => transaction?.linkedInfo?.guest?.fullName,
        section: 1,
      ),
      FieldDef(
        tag: 'linkedPolicy',
        width: FieldsBuilder.shorterWidth,
        label: 'xtran.linkedPolicy'.tr,
        loadValue: () => transaction?.linkedInfo?.redeemPolicy?.title,
        section: 1,
      ),
    ];
  }

  GenTransaction? transaction;

  List<Widget> buildTransactionFields(GenTransaction rec) {
    transaction = rec;
    return buildFields();
  }

  List<Widget> buildTransactionQueryFields(GenTransaction rec, {Function()? onFilterUpdated}) {
    transaction = rec;
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

  void saveToSelectedTransaction(AdminApp adminApp) {
    if (!isCreating) {
      transaction = GenTransaction.fromJson(adminApp.selectedXtran!.toJson());
    }
    saveFieldValues();
    adminApp.selectedXtran = transaction;
  }
}

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

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
          onPressed: () async {
            adminApp.selectedXtran = null;
            if (adminApp.managingStore.value == null) {
              await alertDialog('xtran.ui.requireManagingStore'.tr);
            }
            else {
              Get.to(() => const TransactionDetailScreen());
            }
          },
          child: const Icon(Icons.add)
        ),
        body: Column(
          children: [
            const ManagingStorePanel(),
            QueryPanel(
                state: adminApp.xtranQuery,
                queryFields: TransactionFieldsBuilder(app: appSettings).buildTransactionQueryFields(
                    adminApp.xtranQuery.queryCriteria,
                    onFilterUpdated: ()=> adminApp.queryXtranList()
                )
            ),
            Expanded(
              child: Obx(()=>buildTestableListView(
                context: context,
                itemCount: adminApp.xtranQuery.result.length,
                itemBuilder: (context,index) {
                  var rec = adminApp.xtranQuery.result[index];
                  return TransactionItemCard(
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

class TransactionItemCard extends StatelessWidget {
  final GenTransaction rec;
  final AppSettings appSettings;
  final Widget? icon;
  final AdminApp adminApp;
  const TransactionItemCard({
    super.key,
    required this.rec,
    required this.appSettings,
    required this.adminApp,
    this.icon,
  });

  Future<void> onTap() async {
    await adminApp.selectXtranForEditing(rec);
    Get.to(()=>const TransactionDetailScreen());
  }

  @override
  Widget build(BuildContext context) {
    return AttributeCard(
        icon: icon,
        onTap: onTap,
        children: TransactionFieldsBuilder(app: appSettings, managingStore: adminApp.managingStore.value).buildTransactionFields(rec)
    );
  }
}

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _TransactionDetailScreenState();
  }
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey  = GlobalKey();
  late AdminApp adminApp;
  late TransactionFieldsBuilder fieldsBuilder;
  late AnimationController controller;
  late AnimationController controller2;

  Future<void> onSaveChanges() async {
    var formState = _formKey.currentState!;
    if (formState.validate()) {
      formState.save();
      fieldsBuilder.saveToSelectedTransaction(adminApp);
      guardUpdateOp(() async {
          await adminApp.updateSelectedXtran();
          await adminApp.queryXtranList();
        },
        controller: controller
      );
    }
    else {
      controller.forward(from: 0);
    }
  }

  Future<void> onDelete() async {
    if (await confirmDeleteDialog(content: adminApp.managingStore.value == null ? null: "transaction.ui.areYouSureToRemoveFromStore".tr)) {
      guardUpdateOp(() async {
        await adminApp.deleteSelectedXtran();
        await adminApp.queryXtranList();
      }, successMessage: 'xtran.ui.deleted'.tr
      );
    }
  }

  Future<void> onLinkToGuest() async {
    var formState = _formKey.currentState!;
    if (formState.validate()) {
      formState.save();
    }
    else {
      controller2.forward(from: 0);
      return;
    }
    uiSimpleDialog('xtran.ui.howToLinkToGuest'.tr, <OptionAndPressed>[
      OptionAndPressed("xtran.ui.selectGuestMockDevice".tr, () async {
        await alertDialog("gen.featureNotImplementedYet".tr);
      }),
      OptionAndPressed("xtran.ui.selectFromAQuickList".tr, () async {
        var resp = await adminApp.sendServerCommand(ServerCommand(
            queryGuestCommand: QueryGuestCommand(
            )
        ));
        uiSimpleDialog("xtran.ui.pleaseSelectAGuest".tr, <OptionAndPressed>[
          for(var guest in resp.queryGuestResponse!.result)
            OptionAndPressed('${guest.fullName} (${guest.phone})', () async {
              fieldsBuilder.saveToSelectedTransaction(adminApp);
              adminApp.selectedXtran!.guestId = guest.guestId;
              guardUpdateOp(() async {
                await adminApp.updateSelectedXtran();
                await adminApp.queryXtranList();
              },
                  controller: controller2
              );
            })
        ]);
      }),
      OptionAndPressed("xtran.ui.scanBarcodeByCamera".tr, () async {
        await alertDialog("gen.featureNotImplementedYet".tr);
      }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    adminApp = Get.find();
    controller = AnimationController(vsync: this);
    controller2 = AnimationController(vsync: this);
    fieldsBuilder = TransactionFieldsBuilder(
        app: appSettings,
    );
    if (adminApp.selectedXtran == null) { // we are creating record
      fieldsBuilder.transaction = GenTransaction.empty(storeId: adminApp.managingStore.value?.storeId);
      fieldsBuilder.isCreating = true;
    }
    else {
      fieldsBuilder.transaction = adminApp.selectedXtran;
    }
    return Scaffold(
        appBar: AppBar(
          title: fieldsBuilder.isCreating ? Text("xtran.ui.createNew".tr) :  Text('xtran.ui.appBar'.tr),
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
                      FloatingActionButton.extended(
                        key: TestingKeys.saveBtn,
                        onPressed: onLinkToGuest,
                        heroTag: 'linkToGuest',
                        label: Text("xtran.ui.linkToGuestBtn".tr),
                      ).animate(autoPlay: false, controller: controller2).shakeX(),
                      if (!fieldsBuilder.isCreating) FloatingActionButton.extended(
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

