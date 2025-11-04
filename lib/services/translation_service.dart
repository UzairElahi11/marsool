import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService extends Translations {
  static const String _englishFile = 'assets/translations/en.json';
  static const String _arabicFile = 'assets/translations/ar.json';

  static final Map<String, Map<String, String>> _translations = {};

  @override
  Map<String, Map<String, String>> get keys => _translations;

  static Future<void> loadTranslations() async {
    try {
      final enJson = await rootBundle.loadString(_englishFile);
      final enMap = Map<String, String>.from(json.decode(enJson));
      _translations['en'] = enMap;

      final arJson = await rootBundle.loadString(_arabicFile);
      final arMap = Map<String, String>.from(json.decode(arJson));
      _translations['ar'] = arMap;
    } catch (_) {
      _translations.addAll(_fallback());
    }
  }

  static Map<String, Map<String, String>> _fallback() {
    return {
      'en': {
        'common.ok': 'OK',
        'common.cancel': 'Cancel',
        'common.logout': 'Log out',
        'common.goBack': 'Go back',
        'common.continue': 'Continue',
        'common.confirm': 'Confirm',
        'common.back': 'Back',
        'common.copy': 'Copy',
        'common.next': 'Next',
        'common.currency': '£',
        'profile.myProfile': 'My Profile',
        'profile.address': 'Address',
        'profile.wallet': 'Wallet',
        'profile.orderHistory': 'Order History',
        'profile.paymentMethods': 'Payment Methods',
        'profile.helpSupport': 'Help & Support',
        'profile.logout': 'Logout',
        'profile.language': 'Language',
        'profile.language.english': 'English',
        'profile.language.arabic': 'Arabic',
        'logout.title': 'Logout Confirmation',
        'logout.message':
            'Are you sure you want to logout? This will clear all your data and you will need to login again.',
        'logout.cancel': 'Cancel',
        'logout.confirm': 'Logout',
      },
      'ar': {
        'common.ok': 'موافق',
        'common.cancel': 'إلغاء',
        'common.logout': 'تسجيل الخروج',
        'common.goBack': 'الرجوع',
        'common.continue': 'متابعة',
        'common.confirm': 'تأكيد',
        'common.back': 'رجوع',
        'common.copy': 'نسخ',
        'common.next': 'التالي',
        'common.currency': 'ر.س',
        'profile.myProfile': 'ملفي الشخصي',
        'profile.address': 'العنوان',
        'profile.wallet': 'المحفظة',
        'profile.orderHistory': 'تاريخ الطلبات',
        'profile.paymentMethods': 'طرق الدفع',
        'profile.helpSupport': 'المساعدة والدعم',
        'profile.logout': 'تسجيل الخروج',
        'profile.language': 'اللغة',
        'profile.language.english': 'الإنجليزية',
        'profile.language.arabic': 'العربية',
        'logout.title': 'تأكيد تسجيل الخروج',
        'logout.message':
            'هل أنت متأكد أنك تريد تسجيل الخروج؟ سيؤدي هذا إلى مسح جميع بياناتك وستحتاج إلى تسجيل الدخول مرة أخرى.',
        'logout.cancel': 'إلغاء',
        'logout.confirm': 'تسجيل الخروج',
      }
    };
  }

  static Future<void> changeLanguage(String code) async {
    Get.updateLocale(Locale(code));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
  }

  static Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language_code') ?? 'en';
  }

  // Future API support: accept your composite structure
  // {
  //   "configurations": [
  //     { "code": "en", "configurations": { "common.ok": "OK", ... } },
  //     { "code": "ar", "configurations": { "common.ok": "موافق", ... } }
  //   ],
  //   "languages": [ { "value": "en", "label": "English", "direction": "ltr" }, ... ]
  // }
  static void setFromComposite(Map<String, dynamic> payload) {
    final configs = payload['configurations'];
    if (configs is List) {
      for (final entry in configs) {
        final code = entry['code'];
        final map = entry['configurations'];
        if (code is String && map is Map) {
          _translations[code] = Map<String, String>.from(map);
        }
      }
    }
  }
}
