import 'dart:io';
import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'dart:math';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:path_provider/path_provider.dart';

enum Moon { io, europa, ganymede, callisto }

String getName(Moon moon) {
  switch (moon) {
    case Moon.io:
      return 'Io';
    case Moon.europa:
      return 'Europa';
    case Moon.ganymede:
      return 'Ganymede';
    case Moon.callisto:
      return 'Callisto';
  }
  return ''; // to fix error
}

class SatelliteData {
  String fullPath = '/Users/appa/2019_Fall/UX/galilean_moons/';
  List<List<dynamic>> jData;
  List<List<List<dynamic>>> moonData = List(4);
  DateTime endDate;
  DateTime startDate;
  Duration intervalTime;

  // SatelliteData() {
  //   Moon.values.forEach((m) => _readMoonFile(m));
  //   Future<String> content = rootBundle.loadString('assets/data.json');

  //   // File(fullPath + 'data/jupiter.csv').readAsString();
  //   content.then((content) {
  //     jData = const CsvToListConverter().convert(content);

  //     // int numRows = jData.length;
  //     // startDate = DateTime.parse(jData[1][0]);
  //     startDate = DateTime.parse("2019-11-07 00:00");
  //     // endDate = DateTime.parse(jData[numRows-1][0]);
  //     endDate = DateTime.parse("2020-01-07 00:00");
  //     // intervalTime = DateTime.parse(jData[2][0]).difference(startDate);
  //     intervalTime = DateTime.parse("2019-11-07 03:00").difference(startDate);
  //   });
  // }

  // Future<String> get _localPath async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   return directory.path;
  // }

  // void _readMoonFile(Moon m) {
  //   final file = await _localFile;
  //   Future<String> content =
  //       File(fullPath + 'data/${getName(m).toLowerCase()}.csv').readAsString();
  //   content.then((content) =>
  //       moonData[m.index] = const CsvToListConverter().convert(content));
  // }

  SatelliteData() {
    jData = _parseCSV(fullPath + 'data/jupiter.csv');

    Moon.values.forEach((m) => moonData[m.index] =
        _parseCSV(fullPath + 'data/${getName(m).toLowerCase()}.csv'));

    int numRows = jData.length;
    startDate = DateFormat('yyyy-MMM-dd hh:mm').parse(jData[1][0]);
    endDate = DateFormat('yyyy-MMM-dd hh:mm').parse(jData[numRows-1][0]);
    intervalTime = DateFormat('yyyy-MMM-dd hh:mm').parse(jData[2][0]).difference(startDate);
  }

  List<List<dynamic>> _parseCSV(String path) {
    String content = File(path).readAsStringSync();
    List<List<dynamic>> data = const CsvToListConverter().convert(content);
    return data;
  }

  DisplayInfo getCoords(DateTime date) {
    if (intervalTime != null && moonData[Moon.callisto.index] != null) {
      double hourDiff = date.difference(startDate).inSeconds / 3600;
      int index = hourDiff ~/ intervalTime.inHours;
      double amountBetween = hourDiff % (intervalTime.inSeconds / 3600);

      List<SpaceCoord> moonCoords = new List(4);
      Moon.values.forEach((moon) =>
          moonCoords[moon.index] = _interpolate(moon, index, amountBetween));

      SpaceCoord jCoord = _interpolateJup(index, amountBetween);

      // print('${jCoord.ra}, ${jCoord.dec}');
      // print('${moonCoords[0].ra}, ${moonCoords[0].dec}');
      // print('${moonCoords[1].ra}, ${moonCoords[1].dec}');
      // print('${moonCoords[2].ra}, ${moonCoords[2].dec}');
      // print('${moonCoords[3].ra}, ${moonCoords[3].dec}');

      List<SpaceCoord> relCoords = new List(4);
      Moon.values.forEach((moon) => relCoords[moon.index] = SpaceCoord(
          (moonCoords[moon.index].ra - jCoord.ra) * cos(jCoord.dec) * 15,
          (moonCoords[moon.index].dec - jCoord.dec) 
      ));

      // print('${relCoords[0].ra}, ${relCoords[0].dec}');
      // print('${relCoords[1].ra}, ${relCoords[1].dec}');
      // print('${relCoords[2].ra}, ${relCoords[2].dec}');
      // print('${relCoords[3].ra}, ${relCoords[3].dec}');
      // print(Offset(relCoords[0].ra, relCoords[0].dec));

      double jDiam = _getJupDiam(index);

      double f = 4500; //Todo: figure out what factor should be (currently fudged)

      List<Offset> offsets = new List(4);
      Moon.values.forEach((moon) => offsets[moon.index] =
          Offset(relCoords[moon.index].ra * f, relCoords[moon.index].dec * f));

      return DisplayInfo(offsets, jDiam);
    } else {
      return DisplayInfo(
          [Offset(0, 0), Offset(0, 0), Offset(0, 0), Offset(0, 0)],
          _getJupDiam(0));
    }
  }

  SpaceCoord _interpolate(Moon moon, int i, double between) {
    if (between == 0) {
      double ra = moonData[moon.index][i + 1][1];
      double dec = moonData[moon.index][i + 1][2];
      return SpaceCoord(ra, dec);
    }

    double beforeRA = moonData[moon.index][i + 1][1];
    double afterRA = moonData[moon.index][i + 2][1];
    double beforeDec = moonData[moon.index][i + 1][2];
    double afterDec = moonData[moon.index][i + 2][2];
    double estimatedRA = (afterRA - beforeRA) * between + beforeRA;
    double estimatedDec = (afterDec - beforeDec) * between + beforeDec;
    return SpaceCoord(estimatedRA, estimatedDec);
  }

  SpaceCoord _interpolateJup(int i, double between) {
    if (between == 0) {
      double ra = jData[i + 1][1];
      double dec = jData[i + 1][2];
      return SpaceCoord(ra, dec);
    }

    double beforeRA = jData[i + 1][1];
    double afterRA = jData[i + 2][1];
    double beforeDec = jData[i + 1][2];
    double afterDec = jData[i + 2][2];
    double estimatedRA = (afterRA - beforeRA) * between + beforeRA;
    double estimatedDec = (afterDec - beforeDec) * between + beforeDec;
    return SpaceCoord(estimatedRA, estimatedDec);
  }

  double _getJupDiam(int i) {
    return 12.0;
  }
}

class DisplayInfo {
  List<Offset> moonOffsets;
  double jDiam;
  DisplayInfo(this.moonOffsets, this.jDiam);
}

class SpaceCoord {
  double ra;
  double dec;
  SpaceCoord(this.ra, this.dec);
}
