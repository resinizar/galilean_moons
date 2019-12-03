import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:galilean_moons/satellite_data.dart';
import 'package:galilean_moons/styles.dart';
import 'dart:ui' as ui;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
// import 'package:flutter_picker/flutter_picker.dart';

class MoonDisplay extends StatefulWidget {
  @override
  _MoonsState createState() => _MoonsState();
}

class _MoonsState extends State<MoonDisplay> {
  DateTime selectedDate = DateTime.now();
  SatelliteData data = SatelliteData();
  View selectedView = View.direct;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: Styles.backgroundColor,
        child: Column(
          children: <Widget>[
            _viewChangerWidget(),
            Expanded(
                child: Center(
                    child: CustomPaint(
              foregroundPainter:
                  SatellitePainter(data.getCoords(selectedDate), selectedView),
            ))),
            _currentDateWidget()
          ],
        ));
  }

  CupertinoSegmentedControl _viewChangerWidget() {
    return CupertinoSegmentedControl(
      children: const <View, Widget>{
        View.direct:   Padding(child: Text('Direct'),   padding: Styles.segPadding),
        View.inverted: Padding(child: Text('Inverted'), padding: Styles.segPadding),
        View.mirrored: Padding(child: Text('Mirrored'), padding: Styles.segPadding),
      },
      groupValue: selectedView,
      unselectedColor: Styles.backgroundColor,
      selectedColor: Styles.accentColor,
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

  FlatButton _currentDateWidget() {
    return FlatButton(
        onPressed: () {
          DatePicker.showDateTimePicker(context,
              showTitleActions: true,
              minTime: data.endDate,
              maxTime: data.startDate, 
              onChanged: (date) {
                setState(() {
                  selectedDate = date;
                });
              }, 
              onConfirm: (date) {
                setState(() {
                  selectedDate = date;
                });
              },
              currentTime: DateTime.now(),
              locale: LocaleType.en,
              theme: Styles.datePickerTheme);
        },
        child: Text(
          dateToString(selectedDate),
          style: Styles.dateStyle,
        ));
  }
}

class SatellitePainter extends CustomPainter {
  List<Offset> positions;
  double jDiam;
  final colors = [Styles.iColor, Styles.eColor, Styles.gColor, Styles.cColor];
  final widths = [10.0, 36.0, 56.0, 38.0];

  SatellitePainter(DisplayInfo info, View view) {
    Reflection ref = getReflection(view);

    Moon.values.forEach((moon) => info.moonOffsets[moon.index] = Offset(
        info.moonOffsets[moon.index].dx * ref.reflectX,
        info.moonOffsets[moon.index].dy * ref.reflectY));

    this.positions = info.moonOffsets;
    this.jDiam = info.jDiam;
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
      ..pushStyle(Styles.moonLabelStyle)
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
