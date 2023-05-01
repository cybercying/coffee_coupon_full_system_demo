/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:developer';
import 'dart:io';
import '../app_settings.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protocol/data_tester.dart';
import 'package:server/db_util.dart';

Future<void> initServer({Directory? dir}) async {
  if (dir == null && !kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    }
  }
  if (dir != null && !await dir.exists()) {
    await dir.create(recursive: true);
  }
  log('workingDirectory: ${dir?.path}');

  await DbUtil.staticInit(isWeb: kIsWeb, dir: dir);
  final du = DbUtil();
  Get.put(du);
  await du.checkData();
  du.info('Initializing...');
  var localCon = LocalServerConnection(du: du);
  DataTester tester = DataTester(localCon);
  await tester.checkSetup();
}

Future<void> performServerTest() async {
  DbUtil du = Get.find();
  var localCon = LocalServerConnection(du: du);
  DataTester tester = DataTester(localCon);
  await tester.checkSetup();
  await tester.inputDataSet4();
}

Future<void> resetServerDatabase({String? defaultLocale}) async {
  DbUtil du = Get.find();
  await du.resetDatabase();
  var localCon = LocalServerConnection(du: du);
  DataTester tester = DataTester(localCon);
  await tester.checkSetup(purge: true);
  log('resetServerDatabase(): completed');
  AppSettings appSettings = Get.find();
  await appSettings.reInit(defaultLocale: defaultLocale);
}