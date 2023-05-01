/*
  Author: Cherng-Yann Ing

  If you find this project useful to you, please consider
  [sponsor me](https://fundrazr.com/flutter_full_demo). This will allow me to
  devote more time improving this project or create more projects like this.

  Do you want to add more features?
  [Reach me out](https://github.com/cybercying).
*/
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'language/en_us.dart' as en_us;
import 'language/ja_jp.dart' as ja_jp;
import 'language/ko_kr.dart' as ko_kr;
import 'language/zh_tw.dart' as zh_tw;
import 'language/es_es.dart' as es_es;
import 'package:get/get.dart';

class LanguageOption {
  Locale locale;
  String label;
  LanguageOption(this.locale, this.label);

  @override
  String toString() {
    return label;
  }
}

class Languages extends Translations {
  static final enUS = LanguageOption(const Locale('en', 'US'), 'English');
  static final zhTW = LanguageOption(const Locale('zh', 'TW'), '繁體中文');
  static final jaJP = LanguageOption(const Locale('ja', 'JP'), '日本語');
  static final koKR = LanguageOption(const Locale('ko', 'KR'), '한국어');
  static final esES = LanguageOption(const Locale('es', 'ES'), 'español');

  static final languageOptions = [
    enUS,
    zhTW,
    jaJP,
    koKR,
    esES,
  ];

  static final supportedLocales = [
    enUS.locale,
    zhTW.locale,
    jaJP.locale,
    koKR.locale,
    esES.locale,
  ];

  @override
  Map<String, Map<String, String>> get keys => {
    'ko_KR': ko_kr.translation,
    'ja_JP': ja_jp.translation,
    'en_US': en_us.translation,
    'zh_TW': zh_tw.translation,
    'es_ES': es_es.translation,
  };

  static LanguageOption? getLanguageOptionNull(String? locale) {
    if (locale != null) {
      int i = locale.indexOf('_');
      if (i != -1) {
        String langCode = locale.substring(0, i);
        String countryCode = locale.substring(i + 1);
        for (var l in Languages.languageOptions) {
          if (l.locale.languageCode == langCode && l.locale.countryCode == countryCode) {
            return l;
          }
        }
      }
    }
    return null;
  }

  static LanguageOption getLanguageOption(String? locale) {
    return getLanguageOptionNull(locale) ?? enUS;
  }

  void updateTranslationFiles({String? pathPrefix}) {
    var mKeys = keys;
    var baseTranslation = mKeys[enUS.locale.toString()]!;
    log('**********************************');
    log('*** Updating translation files ***');
    for(var l in supportedLocales) {
      var localeName = l.toString();
      var buffer = StringBuffer();
      var translation = mKeys[localeName]!;
      buffer.write('final Map<String,String> translation = {\n');
      var strKeys = baseTranslation.keys.toList();
      strKeys.sort();
      for(var k in strKeys) {
        var kStr = jsonEncode(k);
        var v = translation[k];
        if (v == null) {
          v = baseTranslation[k];
          var vStr = jsonEncode(v);
          buffer.write('//  $kStr: $vStr,\n');
        }
        else {
          var vStr = jsonEncode(v);
          buffer.write('  $kStr: $vStr,\n');
        }
      }
      buffer.write('};\n');
      var file = File('${pathPrefix ?? ''}lib/language/$localeName.dart');
      file.createSync();
      file.writeAsStringSync(buffer.toString());
    }
  }
}
