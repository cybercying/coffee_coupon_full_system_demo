/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:protocol/protocol.dart';

import '../app_settings.dart';
import '../fields_builder.dart';
import '../ui_shared.dart';
import 'guest_app.dart';

class XtranGuestFieldsBuilder extends FieldsBuilder {
  GenStore? managingStore;
  XtranGuestFieldsBuilder({
    required super.app,
    this.managingStore,
  }) {
    sectionDefs = [
      FieldSectionDef(label: "xtran.section.main".tr),
      FieldSectionDef(label: "xtran.section.linked".tr),
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
        tag: 'type2',
        label: "xtran.type".tr,
        width: FieldsBuilder.shorterWidth,
        required: true,
        loadValue: () => 'xtran.type.${transaction!.type.name}'.tr,
        listOnly: true,
      ),
      FieldDef(
        tag: 'points',
        width: FieldsBuilder.shorter2Width,
        label: "xtran.points".tr,
        loadValue: () => transaction!.points.toString(),
        saveValue: (value) => transaction!.points = int.parse(value!),
        isInteger: true,
        required: true,
        cannotBeZero: true,
      ),
      FieldDef(
        tag: 'linkedUser',
        width: FieldsBuilder.shorterWidth,
        label: "xtran.linkedUser".tr,
        loadValue: () => transaction?.linkedInfo?.user?.fullName,
        section: 1,
      ),
      FieldDef(
        tag: 'linkedStore',
        width: FieldsBuilder.shorterWidth,
        label: "xtran.linkedStore".tr,
        loadValue: () => transaction?.linkedInfo?.store?.name,
        section: 1,
      ),
      FieldDef(
        tag: 'linkedGuest',
        width: FieldsBuilder.shorterWidth,
        label: "xtran.linkedGuest".tr,
        loadValue: () => transaction?.linkedInfo?.guest?.fullName,
        section: 1,
      ),
      FieldDef(
        tag: 'linkedPolicy',
        width: FieldsBuilder.shorterWidth,
        label: "xtran.linkedPolicy".tr,
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

}

class XtranGuestListScreen extends StatelessWidget {
  const XtranGuestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppSettings appSettings = Get.find();
    GuestApp guestApp = Get.find();
    var fieldsBuilder = XtranGuestFieldsBuilder(app: appSettings);
    return Scaffold(
        appBar: AppBar(
          title: Text("xtran.ui.guestAppBar".tr),
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(()=>buildTestableListView(
                context: context,
                itemCount: guestApp.xtranQueryResult.length,
                itemBuilder: (context,index) {
                  var rec = guestApp.xtranQueryResult[index];
                  return AttributeCard(
                      children: fieldsBuilder.buildTransactionFields(rec),
                  );
                },
              )),
            ),
          ],
        )
    );
  }
}

