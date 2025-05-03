// Diese Datei dient nur als Referenz und wird nicht direkt ausgeführt.
// Für ein professionelles App-Icon erstellen Sie ein 1024x1024 PNG-Bild
// mit einem Bildbearbeitungsprogramm wie Photoshop, GIMP oder Canva.

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

/// Beispiel für die programmatische Erstellung eines App-Icons.
/// In der Praxis sollten Sie ein professionelles Icon erstellen.
Future<void> createAppIcon() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(1024, 1024);
  final paint = Paint();

  // Hintergrund
  paint.color = const Color(0xFF5C6BC0); // Indigo-Farbe
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

  // Zeichne eine Kapsel
  paint.color = Colors.white;
  final capsuleRect = Rect.fromLTWH(
    size.width * 0.15,
    size.height * 0.15,
    size.width * 0.7,
    size.height * 0.7,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(capsuleRect, Radius.circular(size.width * 0.1)),
    paint,
  );

  // Zeichne ein Uhrensymbol in der Kapsel
  paint.color = const Color(0xFF5C6BC0);
  paint.style = PaintingStyle.stroke;
  paint.strokeWidth = size.width * 0.05;
  final clockCenter = Offset(size.width * 0.5, size.height * 0.5);
  final clockRadius = size.width * 0.25;
  canvas.drawCircle(clockCenter, clockRadius, paint);

  // Stundenzeiger
  paint.strokeWidth = size.width * 0.03;
  canvas.drawLine(
    clockCenter,
    Offset(
      clockCenter.dx + clockRadius * 0.5 * math.cos(2 * math.pi * 0.75),
      clockCenter.dy + clockRadius * 0.5 * math.sin(2 * math.pi * 0.75),
    ),
    paint,
  );

  // Minutenzeiger
  canvas.drawLine(
    clockCenter,
    Offset(
      clockCenter.dx + clockRadius * 0.7 * math.cos(2 * math.pi * 0.2),
      clockCenter.dy + clockRadius * 0.7 * math.sin(2 * math.pi * 0.2),
    ),
    paint,
  );

  final picture = recorder.endRecording();
  final img = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  final buffer = byteData!.buffer.asUint8List();

  // Speichern des Icons
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/app_icon.png';
  final iconFile = File(filePath);
  await iconFile.writeAsBytes(buffer);

  print('Icon gespeichert in: $filePath');
}

double cos(double radians) => math.cos(radians);
double sin(double radians) => math.sin(radians);
