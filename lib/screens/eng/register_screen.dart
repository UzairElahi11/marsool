import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:petshow/controllers/auth_controller.dart';

import '../../utils/constants.dart';
import '../../utils/size_config.dart';
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

  // Added: form key + password visibility toggles
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Updated: stricter validation + clean submit
  _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (password != confirmPassword) {
      ConstantManager()
          .showSnackbar(context, 'register.validation.passwordMismatch'.tr);
      return;
    }

    await _authController.register(
        name, email, phone, password, selectedGender!);
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = (Get.locale?.languageCode == 'ar');

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text('register.title'.tr),
        ),
        backgroundColor: Colors.white,
        body: Obx(() => LoadingOverlay(
              progressIndicator: OverlayLoader(),
              isLoading: _authController.isLoading.value,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Name
                                TextFormField(
                                  controller: nameController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    labelText: 'register.fullName'.tr,
                                    prefixIcon:
                                        const Icon(Icons.person_outline),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'register.validation.name'.tr;
                                    }
                                    if (v.trim().length < 2) {
                                      return 'register.validation.name'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Email
                                TextFormField(
                                  controller: emailController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: 'register.email'.tr,
                                    prefixIcon:
                                        const Icon(Icons.email_outlined),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'register.validation.emailRequired'
                                          .tr;
                                    }
                                    if (!GetUtils.isEmail(v.trim())) {
                                      return 'register.validation.emailInvalid'
                                          .tr;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Phone
                                TextFormField(
                                  controller: phoneController,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'register.phone'.tr,
                                    prefixIcon:
                                        const Icon(Icons.phone_outlined),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'register.validation.phoneRequired'
                                          .tr;
                                    }
                                    final digitsOnly =
                                        v.replaceAll(RegExp(r'[^0-9]'), '');
                                    if (digitsOnly.length < 7) {
                                      return 'register.validation.phoneInvalid'
                                          .tr;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Gender
                                DropdownButtonFormField<String>(
                                  initialValue: selectedGender,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'register.gender'.tr,
                                    prefixIcon:
                                        const Icon(Icons.person_outline),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  items: genders.map((String gender) {
                                    return DropdownMenuItem<String>(
                                      value: gender,
                                      child: Text(gender == 'Male'
                                          ? 'register.gender.male'.tr
                                          : 'register.gender.female'.tr),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedGender = newValue;
                                    });
                                  },
                                  validator: (v) => v == null
                                      ? 'register.validation.genderRequired'.tr
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                // Password
                                TextFormField(
                                  controller: passwordController,
                                  textInputAction: TextInputAction.next,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'register.password'.tr,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'register.validation.passwordRequired'
                                          .tr;
                                    }
                                    if (v.length < 6) {
                                      return 'register.validation.passwordMin'
                                          .tr;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Confirm Password
                                TextFormField(
                                  controller: confirmPasswordController,
                                  textInputAction: TextInputAction.done,
                                  obscureText: _obscureConfirm,
                                  decoration: InputDecoration(
                                    labelText: 'register.confirmPassword'.tr,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureConfirm
                                          ? Icons.visibility_off
                                          : Icons.visibility),
                                      onPressed: () => setState(() =>
                                          _obscureConfirm = !_obscureConfirm),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'register.validation.confirmRequired'
                                          .tr;
                                    }
                                    if (v != passwordController.text) {
                                      return 'register.validation.passwordMismatch'
                                          .tr;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Submit
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          ConstantManager.primaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    child: Text(
                                      'register.register'.tr,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacebar('h', space: 2.5),
                      GestureDetector(
                        onTap: () => Get.back(),
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
                              style: const TextStyle(
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
              ),
            )),
      ),
    );
  }
}
