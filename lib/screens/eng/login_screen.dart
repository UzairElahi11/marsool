import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:petshow/controllers/auth_controller.dart';
import 'package:petshow/screens/eng/register_screen.dart';
import 'package:petshow/widgets/eng_button.dart';
import 'package:petshow/widgets/eng_title.dart';

import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/eng_icon_textfield.dart';
import '../../widgets/overlay_loader.dart';
import '../../widgets/space_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.find();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ConstantManager().showSnackbar(context, 'Please fill all fields');
      return;
    }

    await _authController.login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() => LoadingOverlay(
            progressIndicator: OverlayLoader(),
            isLoading: _authController.isLoading.value,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 150,
                  child: AppLogo(
                    h: SizeConfig.blockSizeVertical! * 20.0,
                    w: SizeConfig.blockSizeVertical! * 20.0,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        EnglishTitle('login.title'.tr),
                        const Spacebar('h', space: 2.25),

                        EnglishIconTextField(
                          controller: emailController,
                          hint: 'login.emailHint'.tr,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const Spacebar('h', space: 2),
                        EnglishIconTextField(
                          controller: passwordController,
                          obscureText: true,
                          hint: 'login.passwordHint'.tr,
                          icon: Icons.lock_outline,
                        ),
                        const Spacebar('h', space: 2.5),

                        EnglishButton('login.login'.tr,
                            ConstantManager.primaryColor, _login),

                        const Spacebar('h', space: 2.5),

                        GestureDetector(
                          onTap: () {
                            Get.to(() => const RegisterScreen());
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'login.noAccount'.tr,
                                style: ConstantManager.kfont.copyWith(
                                  color: Colors.black,
                                  fontSize:
                                      SizeConfig.blockSizeHorizontal! * 3.5,
                                ),
                              ),
                              Text(
                                'login.signup'.tr,
                                style: const TextStyle(
                                  color: ConstantManager.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // const Spacebar('h', space: 2),
                        // _tC(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
