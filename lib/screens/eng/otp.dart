import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:petshow/controllers/auth_controller.dart';
import 'package:petshow/screens/user_info.dart';
import 'package:petshow/utils/constants.dart';
import 'package:petshow/utils/size_config.dart';
import 'package:petshow/widgets/eng_button.dart';
import 'package:petshow/widgets/space_bar.dart';

import '../../widgets/overlay_loader.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> otpControllers =
      List.generate(6, (_) => TextEditingController());

  final AuthController _authController = Get.find();

  void _verifyOtp() async {
    String otp = otpControllers.map((c) => c.text).join();

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the full 6-digit OTP")),
      );
      return;
    }

    debugPrint("OTP entered: $otp");
    await _authController.verifyOtp(widget.email, otp);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),
      body:Obx(() =>  LoadingOverlay(
        progressIndicator: OverlayLoader(),
        isLoading: _authController.isLoading.value,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal! * 6.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacebar('h', space: 7.5),
                Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: ConstantManager.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_outline,
                      size: 45, color: Colors.white),
                ),
                const Spacebar('h', space: 3.5),
                Text(
                  "Verify OTP",
                  style: ConstantManager.kfont.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * 6.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacebar('h', space: 1.0),
                Text(
                  "Code sent to ${widget.email}",
                  style: ConstantManager.kfont.copyWith(
                    fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
                    color: Colors.grey,
                  ),
                ),
                const Spacebar('h', space: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: otpControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.orange, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const Spacebar('h', space: 5.0),
                EnglishButton('Verify', ConstantManager.primaryColor, _verifyOtp),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("OTP resent")),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn’t receive code? ",
                        style: ConstantManager.kfont,
                      ),
                      Text(
                        "Resend",
                        style: ConstantManager.kfont.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
