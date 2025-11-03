import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:petshow/screens/eng/login_screen.dart';
import 'package:petshow/screens/eng/phone_number.dart';
import 'package:petshow/widgets/ar_button.dart';
import 'package:petshow/widgets/eng_button.dart';
import 'package:petshow/widgets/eng_title.dart';
import 'package:petshow/widgets/space_bar.dart';

import '../utils/constants.dart';
import '../utils/size_config.dart';
import '../widgets/app_logo.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: AppLogo(
                h: SizeConfig.blockSizeVertical! * 20.0,
                w: SizeConfig.blockSizeVertical! * 20.0),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockSizeVertical! * 3.5,
                horizontal: SizeConfig.blockSizeHorizontal! * 4.5,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const EnglishTitle('Select Your Language'),
                  const Spacebar('h', space: 2.25),
                  EnglishButton('English', ConstantManager.primaryColor, () {
                    Get.to(() => LoginScreen());
                  }),
                  const Spacebar('h', space: 1.5),
                  ArabicButton('العربية', ConstantManager.secondaryColor, () {
                    Get.to(() => PhoneNumberScreen());
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
