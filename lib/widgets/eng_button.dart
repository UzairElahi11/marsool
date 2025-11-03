import 'package:flutter/material.dart';
import 'package:petshow/utils/size_config.dart';

import '../utils/constants.dart';

class EnglishButton extends StatelessWidget {

  final text;
  final ontap;
  final color;

  const EnglishButton( this.text, this.color, this.ontap, {super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: ontap,
      child: Text(
        text,
        style: ConstantManager.kfont.copyWith(
            fontSize: SizeConfig.blockSizeHorizontal! * 4.0,
            color: Colors.white),
      ),
    );
  }
}
