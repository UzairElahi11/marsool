import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petshow/controllers/auth_controller.dart';
import 'package:petshow/utils/constants.dart';
import 'package:petshow/widgets/eng_icon_textfield.dart';
import 'package:petshow/widgets/eng_button.dart';
import 'package:petshow/widgets/eng_title.dart';
import 'package:petshow/widgets/space_bar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthController _authController = Get.find();

  final TextEditingController currentController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void _submit() async {
    final current = currentController.text.trim();
    final next = newController.text.trim();
    final confirm = confirmController.text.trim();

    await _authController.changePassword(current, next, confirm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('changePassword.title'.tr),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              EnglishTitle('changePassword.title'.tr),
              const Spacebar('h', space: 2.0),
              EnglishIconTextField(
                controller: currentController,
                obscureText: true,
                hint: 'changePassword.current'.tr,
                icon: Icons.lock_outline,
              ),
              const Spacebar('h', space: 1.5),
              EnglishIconTextField(
                controller: newController,
                obscureText: true,
                hint: 'changePassword.new'.tr,
                icon: Icons.lock_outline,
              ),
              const Spacebar('h', space: 1.5),
              EnglishIconTextField(
                controller: confirmController,
                obscureText: true,
                hint: 'changePassword.confirm'.tr,
                icon: Icons.lock_outline,
              ),
              const Spacebar('h', space: 2.0),
              Obx(() {
                final loading = _authController.isLoading.value;
                return EnglishButton(
                  loading ? 'common.continue'.tr : 'changePassword.submit'.tr,
                  loading ? Colors.grey : ConstantManager.primaryColor,
                  loading ? null : _submit,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
