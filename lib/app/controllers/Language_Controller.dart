import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../utils/storage_service.dart';

class LanguageController extends GetxController {

  var locale = const Locale('de').obs;

  @override
  void onInit() {
    super.onInit();

    final savedLang = StorageService.getLanguage();

    if (savedLang != null && savedLang.isNotEmpty) {
      locale.value = Locale(savedLang);
      Get.updateLocale(locale.value);
    } else {
    }
  }


  void changeLocale(String languageCode, [String? countryCode]) {
    locale.value = Locale(languageCode, countryCode);
    Get.updateLocale(locale.value);

    StorageService.saveLanguage(languageCode);
  }


  void toggleGermanEnglish() {
    if (locale.value.languageCode == 'de') {
      changeLocale('en');
    } else {
      changeLocale('de');
    }
  }
}
