import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LanguageController extends GetxController {
  // لغة التطبيق الحالية (افتراضي: الإنجليزية)
  var locale = Locale('de').obs;

  /// يغيّر لغة التطبيق حسب الكود المرسل
  void changeLocale(String languageCode, [String? countryCode]) {
    locale.value = Locale(languageCode, countryCode);
    Get.updateLocale(locale.value);
  }

  /// يبدّل بين الإنجليزية والألمانية بسهولة
  void toggleGermanEnglish() {
    if (locale.value.languageCode == 'de') {
      changeLocale('en'); // التبديل للإنجليزية
    } else {
      changeLocale('de'); // التبديل للألمانية
    }
  }
}
