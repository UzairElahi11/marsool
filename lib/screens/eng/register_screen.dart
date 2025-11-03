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
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
            () => LoadingOverlay(
          progressIndicator: OverlayLoader(),
          isLoading: _authController.isLoading.value,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 75,
                child: AppLogo(
                  h: SizeConfig.blockSizeVertical! * 13.0,
                  w: SizeConfig.blockSizeVertical! * 13.0,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const EnglishTitle('Create New Account'),
                        const Spacebar('h', space: 2.25),
                        EnglishIconTextField(
                          controller: nameController,
                          hint: 'Full Name',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                        ),
                        const Spacebar('h', space: 2),
                        EnglishIconTextField(
                          controller: emailController,
                          hint: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const Spacebar('h', space: 2),
                        EnglishIconTextField(
                          controller: phoneController,
                          hint: 'Phone Number',
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
                                    hint: const Text('Select Gender'),
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
                          hint: 'Password',
                          icon: Icons.lock_outline,
                        ),
                        const Spacebar('h', space: 2),
                        EnglishIconTextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          hint: 'Confirm Password',
                          icon: Icons.lock_outline,
                        ),
                        const Spacebar('h', space: 2.5),
                        EnglishButton('Register', ConstantManager.primaryColor,
                            _register),
                        const Spacebar('h', space: 2.5),
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: ConstantManager.kfont.copyWith(
                                  color: Colors.black,
                                  fontSize:
                                  SizeConfig.blockSizeHorizontal! * 3.5,
                                ),
                              ),
                              Text(
                                "Login",
                                style: TextStyle(
                                  color: ConstantManager.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                  SizeConfig.blockSizeHorizontal! * 3.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
