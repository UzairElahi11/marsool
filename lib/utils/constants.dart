import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ConstantManager{

  static const APP_ICON_PATH = 'assets/logo2.png';

  final blueColor = '#282f5a';
  final orangeColor = '#e7712b';

  static const primaryColor = Color(0xffe7712b);
  static const secondaryColor = Color(0xff282f5a);

  static var kfont = GoogleFonts.ubuntu();

  showSnackbar(context, msg){
    ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(msg)),
    );
  }

}