import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppLogo extends StatelessWidget {

  final double h;
  final double w;

  AppLogo({this.h = 100.0, this.w = 100.0});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ConstantManager.APP_ICON_PATH,
      height: h,
      width: w,
    );
  }
}