import 'package:flutter/cupertino.dart';
// import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  // // This app is designed only to work vertically, so we limit
  // // orientations to portrait up and down.
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  return runApp(GalileanMoonsApp());
}

class GalileanMoonsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: MoonDisplay(),
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    );
  }
}
