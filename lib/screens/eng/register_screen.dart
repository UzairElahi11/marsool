import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:petshow/controllers/auth_controller.dart';
import 'package:petshow/widgets/eng_button.dart';
import 'package:petshow/widgets/eng_icon_textfield.dart';
import 'package:petshow/widgets/eng_title.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/overlay_loader.dart';
import '../../widgets/space_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  String? selectedGender;
  final List<String> genders = ['Male', 'Female'];

  final AuthController _authController = Get.find();

  _register() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        selectedGender == null) {
      ConstantManager().showSnackbar(context, 'Please fill all fields');
      return;
    }

    if (password != confirmPassword) {
      ConstantManager().showSnackbar(context, 'Passwords do not match');
      return;
    }

    await _authController.register(name, email, phone, password, selectedGender!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => LoadingOverlay(
        progressIndicator: OverlayLoader(),
        isLoading: _authController.isLoading.value,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EnglishTitle('register.title'.tr),
              const Spacebar('h', space: 2.25),
              EnglishIconTextField(
                controller: nameController,
                hint: 'register.fullName'.tr,
                icon: Icons.person_outline,
                keyboardType: TextInputType.name,
              ),
              const Spacebar('h', space: 2),
              EnglishIconTextField(
                controller: emailController,
                hint: 'register.email'.tr,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const Spacebar('h', space: 2),
              EnglishIconTextField(
                controller: phoneController,
                hint: 'register.phone'.tr,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const Spacebar('h', space: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.black),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedGender,
                          hint: Text('register.gender'.tr),
                          isExpanded: true,
                          items: genders.map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedGender = newValue;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacebar('h', space: 2),
              EnglishIconTextField(
                controller: passwordController,
                obscureText: true,
                hint: 'register.password'.tr,
                icon: Icons.lock_outline,
              ),
              const Spacebar('h', space: 2),
              EnglishIconTextField(
                controller: confirmPasswordController,
                obscureText: true,
                hint: 'register.confirmPassword'.tr,
                icon: Icons.lock_outline,
              ),
              const Spacebar('h', space: 2.5),
              EnglishButton('register.register'.tr, ConstantManager.primaryColor, _register),
              const Spacebar('h', space: 2.5),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'register.already'.tr,
                      style: ConstantManager.kfont.copyWith(
                        color: Colors.black,
                        fontSize: SizeConfig.blockSizeHorizontal! * 3.5,
                      ),
                    ),
                    Text(
                      'register.login'.tr,
                      style: TextStyle(
                        color: ConstantManager.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
