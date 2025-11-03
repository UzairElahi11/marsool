import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/size_config.dart';

class EnglishTitle extends StatelessWidget {
  final title;

  const EnglishTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Text(
      title,
      style: ConstantManager.kfont.copyWith(
          fontSize: SizeConfig.blockSizeHorizontal! * 5.5,
          fontWeight: FontWeight.bold),
    );
  }
}
