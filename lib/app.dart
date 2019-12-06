import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:galilean_moons/satellite_data.dart';
import 'package:galilean_moons/styles.dart';
import 'dart:ui' as ui;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class MoonDisplay extends StatefulWidget {
  @override
  _MoonsState createState() => _MoonsState();
}

class _MoonsState extends State<MoonDisplay> {
  DateTime selectedDate = DateTime.now();
  View selectedView = View.direct;
  bool dataLoaded = true;
  SatelliteData data = SatelliteData();
  bool nightMode = false;

  bool neg(bool value) {
    if (value == true) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dataLoaded == true) {
      return CupertinoPageScaffold(
          backgroundColor: Styles.backgroundColor,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  _viewChangerWidget(),
                  Spacer(),
                  _nightModeWidget(),
                ],
              ),
              _displayWidget(),
              Row(
                children: <Widget>[
                  _currentDateWidget(),
                  Spacer(),
                  _nowWidget(),
                ],
              ),
            ],
          ));
    } else {
      return CupertinoPageScaffold(
          backgroundColor: Styles.backgroundColor,
          child:
              Text('Loading...', style: Styles().getBigTextStyle(nightMode)));
    }
  }

  Expanded _displayWidget() {
    return Expanded(
        child: Center(
            child: CustomPaint(
      foregroundPainter: SatellitePainter(
          data.getCoords(selectedDate), selectedView, nightMode),
    )));
  }

  CupertinoSegmentedControl _viewChangerWidget() {
    return CupertinoSegmentedControl(
      children: const <View, Widget>{
        View.direct: Padding(child: Text('Direct'), padding: Styles.segPadding),
        View.inverted:
            Padding(child: Text('Inverted'), padding: Styles.segPadding),
        View.mirrored:
            Padding(child: Text('Mirrored'), padding: Styles.segPadding),
      },
      groupValue: selectedView,
      unselectedColor: Styles.backgroundColor,
      selectedColor: Styles().getPrimaryOrNight(nightMode),
      borderColor: Styles.backgroundColor,
      pressedColor: Styles.backgroundColor,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      onValueChanged: (input) {
        setState(() {
          selectedView = input;
        });
      },
    );
  }

  GestureDetector _nightModeWidget() {
    return GestureDetector(
      onTap: () {
        setState(() {
          nightMode = neg(nightMode);
        });
      },
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Icon(CupertinoIcons.eye_solid, color: Styles.nightColor)),
    );
  }

  FlatButton _currentDateWidget() {
    return FlatButton(
        onPressed: () {
          DatePicker.showDateTimePicker(context,
              showTitleActions: true,
              minTime: data.endDate,
              maxTime: data.startDate, onChanged: (date) {
            _setDate(date);
          }, onConfirm: (date) {
            _setDate(date);
          },
              currentTime: selectedDate,
              locale: LocaleType.en,
              theme: Styles().getPickerTheme(nightMode));
        },
        child: Text(
          dateToString(selectedDate),
          style: Styles().getBigTextStyle(nightMode),
        ));
  }

  void _setDate(date) {
    if (date.isBefore(data.startDate) || date.isAfter(data.endDate)) {
      // Todo: add some notification

    } else {
      setState(() {
        selectedDate = date;
      });
    }
  }

  GestureDetector _nowWidget() {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = DateTime.now();
        });
      },
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Icon(CupertinoIcons.refresh,
              color: Styles().getPrimaryOrNight(nightMode))),
    );
  }
}

class SatellitePainter extends CustomPainter {
  List<Offset> positions;
  double jDiam;
  final colors = [Styles.iColor, Styles.eColor, Styles.gColor, Styles.cColor];
  final widths = [10.0, 36.0, 56.0, 38.0];
  bool nightMode;

  SatellitePainter(DisplayInfo info, View view, bool nightMode) {
    Reflection ref = getReflection(view);

    Moon.values.forEach((moon) => info.moonOffsets[moon.index] = Offset(
        info.moonOffsets[moon.index].dx * ref.reflectX,
        info.moonOffsets[moon.index].dy * ref.reflectY));

    this.positions = info.moonOffsets;
    this.jDiam = info.jDiam;
    this.nightMode = nightMode;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(0, 0),
        jDiam,
        Paint()
          ..color = Styles.jColor
          ..style = PaintingStyle.fill);

    Moon.values.forEach((moon) => drawMoon(canvas, moon));
  }

  void drawMoon(Canvas canvas, Moon moon) {
    // draw the vertical line
    canvas.drawLine(
        positions[moon.index],
        Offset(positions[moon.index].dx,
            positions[moon.index].dy + (moon.index + 1) * 10),
        Paint()..color = Colors.grey);

    // draw the circle for the moon
    canvas.drawCircle(
        positions[moon.index],
        3,
        Paint()
          ..color = colors[moon.index]
          ..style = PaintingStyle.fill);

    // draw the letter to label the moon
    final paragraphBuilder = ui.ParagraphBuilder(Styles.pStyle)
      ..pushStyle(Styles().getMoonLabelStyle(nightMode))
      ..addText(getName(moon));
    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: widths[moon.index]));
    canvas.drawParagraph(
        paragraph,
        Offset(positions[moon.index].dx - widths[moon.index] / 2,
            positions[moon.index].dy + (moon.index + 1) * 10));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

enum View { direct, inverted, mirrored }

Reflection getReflection(View view) {
  switch (view) {
    case View.direct:
      return Reflection(1, 1);
    case View.inverted:
      return Reflection(-1, -1);
    case View.mirrored:
      return Reflection(-1, 1);
  }
  return Reflection(1, 1); // Todo: why need this
}

class Reflection {
  int reflectX;
  int reflectY;
  Reflection(this.reflectX, this.reflectY);
}

String dateToString(DateTime date) {
  String fullString = date.toString();
  int startInd = fullString.lastIndexOf(':');
  int lastInd = fullString.length;
  String dateString = fullString.replaceRange(startInd, lastInd, "");
  return dateString;
}
