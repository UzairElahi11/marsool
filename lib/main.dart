import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/controllers/auth_controller.dart';
import 'package:petshow/screens/splash.dart';
import 'package:petshow/services/translation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TranslationService.loadTranslations();
  final savedLang = await TranslationService.getSavedLanguage();
  runApp(MyApp(initialLocale: Locale(savedLang)));
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.initialLocale});

  final Locale initialLocale;
  final AuthController _authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pet Show',
      translations: TranslationService(),
      locale: initialLocale,
      fallbackLocale: const Locale('en'),
      theme: ThemeData(
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFFFFAF0),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
