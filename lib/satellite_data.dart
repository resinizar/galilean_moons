import 'dart:ui';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

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

  SatelliteData() {    
    // load moon data
    Moon.values.forEach((m) {
      final content = _getFileContent(getName(m).toLowerCase());
      content.then((content) {
        moonData[m.index] = const CsvToListConverter().convert(content);
      });
    });

    // load jupiter data
    final content = _getFileContent('jupiter');
    content.then((content) {
      jData = const CsvToListConverter().convert(content);

      int numRows = jData.length;
      startDate = DateFormat('yyyy-MMM-dd hh:mm').parse(jData[1][0]);
      endDate = DateFormat('yyyy-MMM-dd hh:mm').parse(jData[numRows-1][0]);
      intervalTime = DateFormat('yyyy-MMM-dd hh:mm').parse(jData[2][0]).difference(startDate);
    });
  }

  Future<String> _getFileContent(String filename) async {
    return await rootBundle.loadString('data/$filename.csv');
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
          (moonCoords[moon.index].dec - jCoord.dec) * -1 // why do I need -1?
      ));

      // print('${relCoords[0].ra}, ${relCoords[0].dec}');
      // print('${relCoords[1].ra}, ${relCoords[1].dec}');
      // print('${relCoords[2].ra}, ${relCoords[2].dec}');
      // print('${relCoords[3].ra}, ${relCoords[3].dec}');
      // print(Offset(relCoords[0].ra, relCoords[0].dec));

      double jDiam = _getJupDiam(index);

      double f = 4200; //Todo: figure out what factor should be (currently fudged)

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
