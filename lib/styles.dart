import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;
import 'package:flutter_datetime_picker/src/datetime_picker_theme.dart'; // HACK
import 'package:flutter/material.dart';

class Styles {
  static const Color backgroundColor = Color(0xff0b031e);
  static const Color primaryColor = Color(0xff6c92d8);
  static const Color nightColor = Color(0xff964b65);
  static const Color textColor = Color(0xffe2e0e5);
  static const Color textColorShade = Color(0xff959499);

  static const Color jColor = Color(0xffe0b05e);
  static const Color iColor = Color(0xfff9ea77);
  static const Color eColor = Color(0xffbaf1fc);
  static const Color gColor = Color(0xfff9a977);
  static const Color cColor = Color(0xffbad0fc);

    Color getPrimaryOrNight(bool nightMode) {
    if (nightMode == true) {
      return nightColor;
    } else {
      return primaryColor;
    }
  }

  Color getTextOrNight(bool nightMode) {
    if (nightMode == true) {
      return nightColor;
    } else {
      return textColor;
    }
  }

  static const segPadding = EdgeInsets.symmetric(horizontal: 10);

  static final pStyle = ui.ParagraphStyle(
    textDirection: TextDirection.ltr,
  );

  ui.TextStyle getMoonLabelStyle(nightMode) {
    return ui.TextStyle(
      color: getTextOrNight(nightMode),
      fontSize: 12,
      fontFamily: 'Roboto',
    );
  }

  TextStyle getBigTextStyle(nightMode) {
    return TextStyle(
        color: getPrimaryOrNight(nightMode), 
        fontSize: 24, 
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w300,
    );
  }

  DatePickerTheme getPickerTheme(nightMode) {
    return DatePickerTheme(
      cancelStyle: TextStyle(color: textColorShade, fontSize: 16),
      doneStyle: TextStyle(color: getPrimaryOrNight(nightMode), fontSize: 16),
      itemStyle: TextStyle(color: textColor, fontSize: 18),
      backgroundColor: backgroundColor,
      containerHeight: 180.0,
      titleHeight: 44.0,
      itemHeight: 36.0,
    );
  }
}
