import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;
import 'package:galilean_moons/satellite_data.dart';
import 'package:galilean_moons/styles.dart';


class SatellitePainter extends CustomPainter {
  List<Offset> positions;
  double jDiam;
  final colors = [Styles.iColor, Styles.eColor, Styles.gColor, Styles.cColor];
  final widths = [11.0, 40.0, 61.0, 42.0];
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
    // draw jupiter
    canvas.drawCircle(
        Offset(0, 0),
        jDiam,
        Paint()
          ..color = Styles.jColor
          ..style = PaintingStyle.fill);

    // draw each moon
    Moon.values.forEach((moon) => drawMoon(canvas, moon));
  }

  void drawMoon(Canvas canvas, Moon moon) {
    // draw the vertical line
    canvas.drawLine(
        positions[moon.index],
        Offset(positions[moon.index].dx,
            positions[moon.index].dy + (moon.index + 1) * 18),
        Paint()..color = Styles.moonLabelLineColor);

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
            positions[moon.index].dy + (moon.index + 1) * 18));
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