/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'package:get/get.dart';
import 'package:protocol/client_state.dart';

import '../app_settings.dart';

class WelcomeApp {
  final currentPageIndex = 0.obs;
  WelcomeAppSavedState saved = WelcomeAppSavedState();

  Future<void> bringUpApp() async {
    AppSettings appSettings = Get.find();
    saved = appSettings.loadWelcomeAppSavedState() ?? WelcomeAppSavedState();
    currentPageIndex.value = saved.currentPageIndex;
  }

  void saveState() {
    saved.currentPageIndex = currentPageIndex.value;
    AppSettings appSettings = Get.find();
    appSettings.saveWelcomeAppSavedState(saved);
  }
}

