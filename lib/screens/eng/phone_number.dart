import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:petshow/screens/eng/otp.dart';
import 'package:petshow/widgets/eng_button.dart';
import 'package:petshow/widgets/eng_title.dart';

import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/space_bar.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  String selectedCountryCode = '+966';
  final TextEditingController phoneController = TextEditingController();

  final List<String> countryCodes = [
    '+973', // Bahrain
    '+965', // Kuwait
    '+968', // Oman
    '+974', // Qatar
    '+966', // Saudi Arabia
    '+971', // United Arab Emirates
    '+964', // Iraq
    '+962', // Jordan
    '+961', // Lebanon
    '+963', // Syria
    '+967', // Yemen
  ];

  _submit(){
    String fullNumber = '$selectedCountryCode${phoneController.text.trim()}';
    if (phoneController.text.isEmpty) {
      ConstantManager().showSnackbar(context, 'Please enter your phone number');

      return;
    }

    debugPrint("Full Number: $fullNumber");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: AppLogo(
                h: SizeConfig.blockSizeVertical! * 25.5,
                w: SizeConfig.blockSizeVertical! * 25.5),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  const EnglishTitle('Enter Your Phone Number'),
                  const Spacebar('h', space: 2.25),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCountryCode,
                            items: countryCodes
                                .map((code) => DropdownMenuItem(
                                      value: code,
                                      child: Text(code),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCountryCode = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      const Spacebar('w', space: 2.25),
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Enter phone number",
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade400),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacebar('h', space: 2.5),
                  EnglishButton('Continue', ConstantManager.primaryColor, _submit),
                  const Spacebar('h', space: 2.5),
                  _tC(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tC(){
    return RichText(
      text: TextSpan(
        text: "By using this app, you accept to ",
        style: ConstantManager.kfont.copyWith(
          color: Colors.black,
          fontSize: SizeConfig.blockSizeHorizontal! * 3.35,
        ),
        children: [
          TextSpan(
            text: "Terms & Conditions",
            style: TextStyle(
              color: ConstantManager.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: SizeConfig.blockSizeHorizontal! * 3.35,
            ),
          ),
        ],
      ),
    );
  }
}
