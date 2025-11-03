import 'package:flutter/material.dart';

import '../utils/size_config.dart';

class Spacebar extends StatelessWidget {
  final String d;
  final double space;

  const Spacebar(this.d, {super.key, required this.space});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    if (d == 'h') {
      return  SizedBox(height: SizeConfig.blockSizeVertical! * space);
    } else {
      return  SizedBox(width: SizeConfig.blockSizeHorizontal! * space);
    }
  }
}