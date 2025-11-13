import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/utils/constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ConstantManager.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('settings.terms'.tr,
            style: ConstantManager.kfont.copyWith(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            style: ConstantManager.kfont,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}