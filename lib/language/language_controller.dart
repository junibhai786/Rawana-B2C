import 'dart:developer';
import 'dart:ui';

import 'package:moonbnd/language/localization.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  var storage = GetStorage();
  var langLocal = eng;

  @override
  void onInit() async {
    super.onInit();

    langLocal = await getLanguage;
  }

  void saveLanguage(String lang) async {
    // ignore: unnecessary_null_comparison
    if (lang == null) {
      await storage.write('lang', languagedefault);
    } else {
      await storage.write('lang', lang);
    }
  }

  Future<String> get getLanguage async {
    if (storage.read("lang") == null) {
      await storage.write('lang', languagedefault);
    }
    print(storage.read("lang"));
    return await storage.read("lang");
  }

  void changeLanguage(String typeLang) async {
    saveLanguage(typeLang);
    if (langLocal == typeLang) {
      return;
    }
    if (typeLang == eng) {
      langLocal = eng;
      saveLanguage(eng);
      lang('english');
    } else if (typeLang == ara) {
      langLocal = ara;
      saveLanguage('arabic');
      lang('arabic');
    } else {
      langLocal = eng;

      saveLanguage(eng);
    }
    await Get.updateLocale(Locale(langLocal));
    log("${Get.locale?.languageCode} anguageeee");
    update();
  }
}

void lang(String langs) async {
  // final tok = await SharedP.Get('tok');
  // if (tok != null) {
  //   // await ApiLang.edite(langs);
  // } else {
  //   print('no token');
  // }
}
