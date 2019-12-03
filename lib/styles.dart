import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'package:flutter_datetime_picker/src/datetime_picker_theme.dart';
import 'package:flutter/material.dart';

abstract class Styles {
  static const Color backgroundColor = Color(0xff0b031e);
  static const Color accentColor = Color(0xff6c92d8);
  static const Color accentColorShade = Color(0xff647ead);
  static const Color doYouWork = Color(0xff7353a3);
  
  static const Color textColor = Color(0xffe2e0e5);
  static const Color textColorShade = Color(0xff959499);
  

  static const Color jColor = Color(0xffe0b05e);
  static const Color iColor = Color(0xfff9ea77);
  static const Color eColor = Color(0xffbaf1fc);
  static const Color gColor = Color(0xfff9a977);
  static const Color cColor = Color(0xffbad0fc);

  static const segPadding = EdgeInsets.symmetric(horizontal: 10);

  static final pStyle = ui.ParagraphStyle(
    textDirection: TextDirection.ltr,
  );

  static final moonLabelStyle = ui.TextStyle(
    color: textColor,
    fontSize: 12,
    fontFamily: 'Roboto',
  );

  static final dateStyle = TextStyle(
    color: accentColor,
    fontSize: 28,
    fontFamily: 'Roboto',
  );

  static final datePickerTheme = DatePickerTheme(
    cancelStyle: const TextStyle(color: textColorShade, fontSize: 16),
    doneStyle: const TextStyle(color: accentColor, fontSize: 16),
    itemStyle: const TextStyle(color: textColor, fontSize: 18),
    backgroundColor: backgroundColor,
    containerHeight: 180.0,
    titleHeight: 44.0,
    itemHeight: 36.0,);
}