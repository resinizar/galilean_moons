import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:galilean_moons/satellite_data.dart';
import 'package:galilean_moons/styles.dart';
import 'satellite_painter.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class MoonDisplay extends StatefulWidget {
  @override
  _MoonsState createState() => _MoonsState();
}

class _MoonsState extends State<MoonDisplay> {
  DateTime selectedDate = DateTime.now();
  View selectedView = View.direct;
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
    return CupertinoPageScaffold(
        backgroundColor: Styles.backgroundColor,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: _viewChangerWidget()),
                // Spacer(),
                _nightModeWidget(),
              ],
            ),
            _displayWidget(),
            Row(
              children: <Widget>[
                Expanded(child: _currentDateWidget()),
                // Spacer(),
                _nowWidget(),
              ],
            ),
          ],
        ));
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
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      onValueChanged: (input) {
        setState(() {
          selectedView = input;
        });
      },
    );
  }

  FlatButton _nightModeWidget() {
    return FlatButton(
      child: Icon(CupertinoIcons.eye_solid, color: Styles.nightColor),
      onPressed: () {
        setState(() => nightMode = neg(nightMode));
      },
    );
  }

  GestureDetector _currentDateWidget() {
    return GestureDetector(
      child: Padding(
        child: Text(_dateToString(selectedDate),
          style: Styles().getBigTextStyle(nightMode),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10)
      ),
      onTap: () {
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
    );
  }

  void _setDate(date) {
    if (date.isBefore(data.startDate)) {
      showAlertDialog(
          'Please pick a date after ${_dateToString(data.startDate)}',
          data.startDate);
    } else if (date.isAfter(data.endDate)) {
      showAlertDialog(
          'Please pick a date before ${_dateToString(data.endDate)}',
          data.endDate);
    } else {
      setState(() {
        selectedDate = date;
      });
    }
  }

  void showAlertDialog(String message, DateTime resetDate) {
    showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Date Limit Exceeded'),
            content: Align(
              child: Text(message),
              alignment: Alignment.centerLeft,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text('Dismiss'),
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context, 'Dismiss');
                    Navigator.pop(context);
                    setState(() {
                      selectedDate = resetDate;
                    });
                  })
            ],
          );
        });
  }

  FlatButton _nowWidget() {
    return FlatButton(
      child: Icon(CupertinoIcons.refresh,
          color: Styles().getPrimaryOrNight(nightMode)),
      onPressed: () {
        setState(() => selectedDate = DateTime.now());
      },
    );
  }

  String _dateToString(DateTime date) {
    return DateFormat.yMMMd().add_jm().format(date);
  }
}
