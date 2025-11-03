import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/screens/language_selection.dart';
import 'package:petshow/utils/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/app_logo.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    debugPrint(token.toString());

    if (token != null && token.isNotEmpty) {
      // Token exists → go to main app
      Get.offAll(() => const PetShopApp());
    } else {
      // No token → go to language selection
      Get.offAll(() => const LanguageSelectionScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AppLogo(
          h: SizeConfig.blockSizeVertical! * 25.5,
          w: SizeConfig.blockSizeVertical! * 25.5,
        ),
      ),
    );
  }
}
