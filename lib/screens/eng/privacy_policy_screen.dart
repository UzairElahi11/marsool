import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/utils/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstantManager.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('settings.privacy'.tr,
            style: ConstantManager.kfont.copyWith(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Privacy policy content will be available soon.',
            style: ConstantManager.kfont,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}