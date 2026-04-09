import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'model/gmss_stone_model.dart';

//Round
class RoundTopViewPainter extends CustomPainter {
  final GmssStone stone;
  RoundTopViewPainter({required this.stone});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final infoPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) * 0.26;
    canvas.drawCircle(center, radius, paint);
    final double tableRadius = radius * 0.48;
    List<Offset> tablePoints = [];
    for (int i = 0; i < 8; i++) {
      double angle = (i * 45 + 22.5) * math.pi / 180;
      tablePoints.add(
        Offset(
          center.dx + tableRadius * math.cos(angle),
          center.dy + tableRadius * math.sin(angle),
        ),
      );
    }
    final double middleRadius = radius * 0.75;
    List<Offset> outerPoints = [];
    for (int i = 0; i < 16; i++) {
      double angle = (i * 22.5 + 22.5) * math.pi / 180;
      outerPoints.add(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
      );
    }
    canvas.drawPath(Path()..addPolygon(tablePoints, true), paint);
    for (int i = 0; i < 8; i++) {
      double starAngle = (i * 45 + 45 + 22.5) * math.pi / 180;
      Offset starMid = Offset(
        center.dx + middleRadius * math.cos(starAngle - (22.5 * math.pi / 180)),
        center.dy + middleRadius * math.sin(starAngle - (22.5 * math.pi / 180)),
      );
      canvas.drawLine(tablePoints[i], starMid, paint);
      canvas.drawLine(tablePoints[(i + 1) % 8], starMid, paint);
      canvas.drawLine(tablePoints[i], outerPoints[i * 2], paint);
      canvas.drawLine(starMid, outerPoints[i * 2], paint);
      canvas.drawLine(starMid, outerPoints[(i * 2 + 1) % 16], paint);
      canvas.drawLine(starMid, outerPoints[(i * 2 + 2) % 16], paint);
    }
    _drawDimensions(canvas, center, radius, infoPaint, guidePaint);
  }

  void _drawDimensions(
    Canvas canvas,
    Offset center,
    double radius,
    Paint infoPaint,
    Paint guidePaint,
  ) {
    final double spacing = radius * 0.4;
    final double textPadding = radius * 0.12;
    double widthY = center.dy - radius - spacing;
    Offset startW = Offset(center.dx - radius, widthY);
    Offset endW = Offset(center.dx + radius, widthY);
    _drawDashedLine(
      canvas,
      Offset(startW.dx, startW.dy + 5),
      Offset(startW.dx, center.dy - radius),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(endW.dx, endW.dy + 5),
      Offset(endW.dx, center.dy - radius),
      guidePaint,
    );
    canvas.drawLine(startW, endW, infoPaint);
    _drawArrowHead(canvas, startW, 0, infoPaint);
    _drawArrowHead(canvas, endW, 180, infoPaint);
    _drawText(
      canvas,
      "Width: ${stone.width.toStringAsFixed(2)} mm",
      Offset(center.dx, widthY - textPadding),
    );
    double lengthX = center.dx + radius + spacing;
    Offset topL = Offset(lengthX, center.dy - radius);
    Offset bottomL = Offset(lengthX, center.dy + radius);
    _drawDashedLine(
      canvas,
      Offset(topL.dx - 5, topL.dy),
      Offset(center.dx + radius, topL.dy),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(bottomL.dx - 5, bottomL.dy),
      Offset(center.dx + radius, bottomL.dy),
      guidePaint,
    );
    canvas.drawLine(topL, bottomL, infoPaint);
    _drawArrowHead(canvas, topL, 90, infoPaint);
    _drawArrowHead(canvas, bottomL, 270, infoPaint);
    _drawText(
      canvas,
      "Length: ${stone.length.toStringAsFixed(2)} mm",
      Offset(lengthX + 55, center.dy),
    );
    _drawText(
      canvas,
      "Length to Width: ${stone.ratio.toStringAsFixed(2)} to 1",
      Offset(center.dx, center.dy + radius + 45),
      isGrey: true,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4;
    double distance = (p2 - p1).distance;
    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(
          p1.dx + (p2.dx - p1.dx) * i / distance,
          p1.dy + (p2.dy - p1.dy) * i / distance,
        ),
        Offset(
          p1.dx + (p2.dx - p1.dx) * (i + dashWidth) / distance,
          p1.dy + (p2.dy - p1.dy) * (i + dashWidth) / distance,
        ),
        paint,
      );
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset point,
    double angleDegrees,
    Paint paint,
  ) {
    final double arrowSize = 6.0;
    final double angle = angleDegrees * (3.14159 / 180);
    Path path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle - 0.5),
        point.dy + arrowSize * math.sin(angle - 0.5),
      )
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle + 0.5),
        point.dy + arrowSize * math.sin(angle + 0.5),
      );
    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool isGrey = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isGrey ? Colors.grey.shade700 : const Color(0xFF008080),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//Princess
class PrincessTopViewPainter extends CustomPainter {
  final GmssStone stone;
  PrincessTopViewPainter({required this.stone});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final infoPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    final double side = size.width * 0.4;
    Rect outer = Rect.fromCenter(center: center, width: side, height: side);
    canvas.drawRect(outer, paint);
    final double tableSide = side * 0.58;
    Rect table = Rect.fromCenter(
      center: center,
      width: tableSide,
      height: tableSide,
    );
    canvas.drawRect(table, paint);
    canvas.drawLine(outer.topLeft, table.topLeft, paint);
    canvas.drawLine(outer.topRight, table.topRight, paint);
    canvas.drawLine(outer.bottomLeft, table.bottomLeft, paint);
    canvas.drawLine(outer.bottomRight, table.bottomRight, paint);
    Offset topMid = Offset(center.dx, outer.top);
    canvas.drawLine(table.topLeft, topMid, paint);
    canvas.drawLine(table.topRight, topMid, paint);
    Offset bottomMid = Offset(center.dx, outer.bottom);
    canvas.drawLine(table.bottomLeft, bottomMid, paint);
    canvas.drawLine(table.bottomRight, bottomMid, paint);
    Offset leftMid = Offset(outer.left, center.dy);
    canvas.drawLine(table.topLeft, leftMid, paint);
    canvas.drawLine(table.bottomLeft, leftMid, paint);
    Offset rightMid = Offset(outer.right, center.dy);
    canvas.drawLine(table.topRight, rightMid, paint);
    canvas.drawLine(table.bottomRight, rightMid, paint);
    canvas.drawLine(topMid, Offset(center.dx, table.top), paint);
    canvas.drawLine(bottomMid, Offset(center.dx, table.bottom), paint);
    canvas.drawLine(leftMid, Offset(table.left, center.dy), paint);
    canvas.drawLine(rightMid, Offset(table.right, center.dy), paint);
    _drawDimensions(canvas, center, side, side, infoPaint, guidePaint);
  }

  void _drawDimensions(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    Paint infoPaint,
    Paint guidePaint,
  ) {
    double spacing = w * 0.4;
    double widthY = center.dy - h / 2 - spacing;
    Offset startW = Offset(center.dx - w / 2, widthY);
    Offset endW = Offset(center.dx + w / 2, widthY);
    _drawDashedLine(
      canvas,
      Offset(startW.dx, startW.dy + 5),
      Offset(startW.dx, center.dy - h / 2),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(endW.dx, endW.dy + 5),
      Offset(endW.dx, center.dy - h / 2),
      guidePaint,
    );
    canvas.drawLine(startW, endW, infoPaint);
    _drawArrowHead(canvas, startW, 0, infoPaint);
    _drawArrowHead(canvas, endW, 180, infoPaint);
    _drawText(
      canvas,
      "Width: ${stone.width.toStringAsFixed(2)} mm",
      Offset(center.dx, widthY - 10),
    );
    double lengthX = center.dx + w / 2 + spacing;
    Offset topL = Offset(lengthX, center.dy - h / 2);
    Offset bottomL = Offset(lengthX, center.dy + h / 2);
    _drawDashedLine(
      canvas,
      Offset(topL.dx - 5, topL.dy),
      Offset(center.dx + w / 2, topL.dy),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(bottomL.dx - 5, bottomL.dy),
      Offset(center.dx + w / 2, bottomL.dy),
      guidePaint,
    );
    canvas.drawLine(topL, bottomL, infoPaint);
    _drawArrowHead(canvas, topL, 90, infoPaint);
    _drawArrowHead(canvas, bottomL, 270, infoPaint);
    _drawText(
      canvas,
      "Length: ${stone.length.toStringAsFixed(2)} mm",
      Offset(lengthX + 50, center.dy),
    );
    _drawText(
      canvas,
      "Length to Width: ${stone.ratio.toStringAsFixed(2)} to 1",
      Offset(center.dx, center.dy + h / 2 + spacing + 10),
      isGrey: true,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4;
    double distance = (p2 - p1).distance;
    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(
          p1.dx + (p2.dx - p1.dx) * i / distance,
          p1.dy + (p2.dy - p1.dy) * i / distance,
        ),
        Offset(
          p1.dx + (p2.dx - p1.dx) * (i + dashWidth) / distance,
          p1.dy + (p2.dy - p1.dy) * (i + dashWidth) / distance,
        ),
        paint,
      );
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset point,
    double angleDegrees,
    Paint paint,
  ) {
    final double arrowSize = 6.0;
    final double angle = angleDegrees * (3.14159 / 180);
    Path path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle - 0.5),
        point.dy + arrowSize * math.sin(angle - 0.5),
      )
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle + 0.5),
        point.dy + arrowSize * math.sin(angle + 0.5),
      );
    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool isGrey = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isGrey ? Colors.grey.shade700 : const Color(0xFF008080),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//Emerald
class EmeraldTopViewPainter extends CustomPainter {
  final GmssStone stone;
  EmeraldTopViewPainter({required this.stone});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final infoPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    final double outerW = size.width * 0.35;
    final double outerH = size.height * 0.55;
    List<double> scales = [1.0, 0.84, 0.68, 0.48];
    List<List<Offset>> layers = [];
    for (var scale in scales) {
      double w = outerW * scale;
      double h = outerH * scale;
      double c = 8.0 * scale;
      List<Offset> points = [
        Offset(center.dx - w / 2 + c, center.dy - h / 2),
        Offset(center.dx + w / 2 - c, center.dy - h / 2),
        Offset(center.dx + w / 2, center.dy - h / 2 + c),
        Offset(center.dx + w / 2, center.dy + h / 2 - c),
        Offset(center.dx + w / 2 - c, center.dy + h / 2),
        Offset(center.dx - w / 2 + c, center.dy + h / 2),
        Offset(center.dx - w / 2, center.dy + h / 2 - c),
        Offset(center.dx - w / 2, center.dy - h / 2 + c),
      ];
      layers.add(points);
      canvas.drawPath(Path()..addPolygon(points, true), paint);
    }
    for (int i = 0; i < layers.length - 1; i++) {
      for (int j = 0; j < 8; j++) {
        canvas.drawLine(layers[i][j], layers[i + 1][j], paint);
      }
    }
    _drawDimensions(canvas, center, outerW, outerH, infoPaint, guidePaint);
  }

  void _drawDimensions(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    Paint infoPaint,
    Paint guidePaint,
  ) {
    double spacing = h * 0.25;
    double widthY = center.dy - h / 2 - spacing;
    Offset startW = Offset(center.dx - w / 2, widthY);
    Offset endW = Offset(center.dx + w / 2, widthY);
    _drawDashedLine(
      canvas,
      Offset(startW.dx, startW.dy + 5),
      Offset(startW.dx, center.dy - h / 2),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(endW.dx, endW.dy + 5),
      Offset(endW.dx, center.dy - h / 2),
      guidePaint,
    );
    canvas.drawLine(startW, endW, infoPaint);
    _drawArrowHead(canvas, startW, 0, infoPaint);
    _drawArrowHead(canvas, endW, 180, infoPaint);
    _drawText(
      canvas,
      "Width: ${stone.width.toStringAsFixed(2)} mm",
      Offset(center.dx, widthY - 10),
    );
    double lengthX = center.dx + w / 2 + spacing;
    Offset topL = Offset(lengthX, center.dy - h / 2);
    Offset bottomL = Offset(lengthX, center.dy + h / 2);
    _drawDashedLine(
      canvas,
      Offset(topL.dx - 5, topL.dy),
      Offset(center.dx + w / 2, topL.dy),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(bottomL.dx - 5, bottomL.dy),
      Offset(center.dx + w / 2, bottomL.dy),
      guidePaint,
    );
    canvas.drawLine(topL, bottomL, infoPaint);
    _drawArrowHead(canvas, topL, 90, infoPaint);
    _drawArrowHead(canvas, bottomL, 270, infoPaint);
    _drawText(
      canvas,
      "Length: ${stone.length.toStringAsFixed(2)} mm",
      Offset(lengthX + 55, center.dy),
    );
    _drawText(
      canvas,
      "Length to Width: ${stone.ratio.toStringAsFixed(2)} to 1",
      Offset(center.dx, center.dy + h / 2 + spacing + 10),
      isGrey: true,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4;
    double distance = (p2 - p1).distance;
    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(
          p1.dx + (p2.dx - p1.dx) * i / distance,
          p1.dy + (p2.dy - p1.dy) * i / distance,
        ),
        Offset(
          p1.dx + (p2.dx - p1.dx) * (i + dashWidth) / distance,
          p1.dy + (p2.dy - p1.dy) * (i + dashWidth) / distance,
        ),
        paint,
      );
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset point,
    double angleDegrees,
    Paint paint,
  ) {
    final double arrowSize = 6.0;
    final double angle = angleDegrees * (3.14159 / 180);
    Path path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle - 0.5),
        point.dy + arrowSize * math.sin(angle - 0.5),
      )
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle + 0.5),
        point.dy + arrowSize * math.sin(angle + 0.5),
      );
    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool isGrey = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isGrey ? Colors.grey.shade700 : const Color(0xFF008080),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//Cushion
class CushionTopViewPainter extends CustomPainter {
  final GmssStone stone;
  CushionTopViewPainter({required this.stone});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final infoPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    final double h = size.height * 0.55;
    final double w = h * 0.95;
    RRect outerRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: w, height: h),
      const Radius.circular(20),
    );
    canvas.drawRRect(outerRRect, paint);
    final double tableW = w * 0.55;
    final double tableH = h * 0.55;
    RRect tableRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: tableW, height: tableH),
      const Radius.circular(8),
    );
    canvas.drawRRect(tableRRect, paint);
    const double cornerOffset = 10.0;
    canvas.drawLine(
      Offset(outerRRect.left + cornerOffset, outerRRect.top + cornerOffset),
      Offset(tableRRect.left, tableRRect.top),
      paint,
    );
    canvas.drawLine(
      Offset(outerRRect.right - cornerOffset, outerRRect.top + cornerOffset),
      Offset(tableRRect.right, tableRRect.top),
      paint,
    );
    canvas.drawLine(
      Offset(outerRRect.left + cornerOffset, outerRRect.bottom - cornerOffset),
      Offset(tableRRect.left, tableRRect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(outerRRect.right - cornerOffset, outerRRect.bottom - cornerOffset),
      Offset(tableRRect.right, tableRRect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, outerRRect.top),
      Offset(center.dx, tableRRect.top),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, outerRRect.bottom),
      Offset(center.dx, tableRRect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(outerRRect.left, center.dy),
      Offset(tableRRect.left, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(outerRRect.right, center.dy),
      Offset(tableRRect.right, center.dy),
      paint,
    );
    _drawDimensions(canvas, center, w, h, infoPaint, guidePaint);
  }

  void _drawDimensions(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    Paint infoPaint,
    Paint guidePaint,
  ) {
    double spacing = h * 0.3;
    double widthY = center.dy - h / 2 - spacing;
    Offset startW = Offset(center.dx - w / 2, widthY);
    Offset endW = Offset(center.dx + w / 2, widthY);
    _drawDashedLine(
      canvas,
      Offset(startW.dx, startW.dy + 5),
      Offset(startW.dx, center.dy - h / 2),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(endW.dx, endW.dy + 5),
      Offset(endW.dx, center.dy - h / 2),
      guidePaint,
    );
    canvas.drawLine(startW, endW, infoPaint);
    _drawArrowHead(canvas, startW, 0, infoPaint);
    _drawArrowHead(canvas, endW, 180, infoPaint);
    _drawText(
      canvas,
      "Width: ${stone.width.toStringAsFixed(2)} mm",
      Offset(center.dx, widthY - 10),
    );
    double lengthX = center.dx + w / 2 + spacing;
    Offset topL = Offset(lengthX, center.dy - h / 2);
    Offset bottomL = Offset(lengthX, center.dy + h / 2);
    _drawDashedLine(
      canvas,
      Offset(topL.dx - 5, topL.dy),
      Offset(center.dx + w / 2, topL.dy),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(bottomL.dx - 5, bottomL.dy),
      Offset(center.dx + w / 2, bottomL.dy),
      guidePaint,
    );
    canvas.drawLine(topL, bottomL, infoPaint);
    _drawArrowHead(canvas, topL, 90, infoPaint);
    _drawArrowHead(canvas, bottomL, 270, infoPaint);
    _drawText(
      canvas,
      "Length: ${stone.length.toStringAsFixed(2)} mm",
      Offset(lengthX + 50, center.dy),
    );
    _drawText(
      canvas,
      "Length to Width: ${stone.ratio.toStringAsFixed(2)} to 1",
      Offset(center.dx, center.dy + h / 2 + spacing + 10),
      isGrey: true,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4;
    double distance = (p2 - p1).distance;
    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(
          p1.dx + (p2.dx - p1.dx) * i / distance,
          p1.dy + (p2.dy - p1.dy) * i / distance,
        ),
        Offset(
          p1.dx + (p2.dx - p1.dx) * (i + dashWidth) / distance,
          p1.dy + (p2.dy - p1.dy) * (i + dashWidth) / distance,
        ),
        paint,
      );
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset point,
    double angleDegrees,
    Paint paint,
  ) {
    final double arrowSize = 6.0;
    final double angle = angleDegrees * (3.14159 / 180);
    Path path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle - 0.5),
        point.dy + arrowSize * math.sin(angle - 0.5),
      )
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle + 0.5),
        point.dy + arrowSize * math.sin(angle + 0.5),
      );
    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool isGrey = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isGrey ? Colors.grey.shade700 : const Color(0xFF008080),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//Radiant
class RadiantTopViewPainter extends CustomPainter {
  final GmssStone stone;
  RadiantTopViewPainter({required this.stone});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final infoPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    const double visualH = 180.0;
    const double visualW = 130.0;
    final Path outerPath = _getRadiantPath(center, visualW, visualH, 15);
    canvas.drawPath(outerPath, paint);
    final double tableW = visualW * 0.5;
    final double tableH = visualH * 0.5;
    final Path tablePath = _getRadiantPath(center, tableW, tableH, 8);
    canvas.drawPath(tablePath, paint);
    _drawRadiantFacets(canvas, center, visualW, visualH, tableW, tableH, paint);
    _drawDimensions(canvas, center, visualW, visualH, infoPaint, guidePaint);
  }

  Path _getRadiantPath(Offset center, double w, double h, double crop) {
    return Path()
      ..moveTo(center.dx - w / 2 + crop, center.dy - h / 2)
      ..lineTo(center.dx + w / 2 - crop, center.dy - h / 2)
      ..lineTo(center.dx + w / 2, center.dy - h / 2 + crop)
      ..lineTo(center.dx + w / 2, center.dy + h / 2 - crop)
      ..lineTo(center.dx + w / 2 - crop, center.dy + h / 2)
      ..lineTo(center.dx - w / 2 + crop, center.dy + h / 2)
      ..lineTo(center.dx - w / 2, center.dy + h / 2 - crop)
      ..lineTo(center.dx - w / 2, center.dy - h / 2 + crop)
      ..close();
  }

  void _drawRadiantFacets(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    double tw,
    double th,
    Paint paint,
  ) {
    canvas.drawLine(
      Offset(center.dx - w / 2 + 15, center.dy - h / 2),
      Offset(center.dx - tw / 2 + 8, center.dy - th / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + w / 2 - 15, center.dy - h / 2),
      Offset(center.dx + tw / 2 - 8, center.dy - th / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - w / 2 + 15, center.dy + h / 2),
      Offset(center.dx - tw / 2 + 8, center.dy + th / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + w / 2 - 15, center.dy + h / 2),
      Offset(center.dx + tw / 2 - 8, center.dy + th / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - w / 2, center.dy),
      Offset(center.dx - tw / 2, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + w / 2, center.dy),
      Offset(center.dx + tw / 2, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - h / 2),
      Offset(center.dx, center.dy - th / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + h / 2),
      Offset(center.dx, center.dy + th / 2),
      paint,
    );
  }

  void _drawDimensions(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    Paint infoPaint,
    Paint guidePaint,
  ) {
    double widthY = center.dy - h / 2 - 35;
    Offset startW = Offset(center.dx - w / 2, widthY);
    Offset endW = Offset(center.dx + w / 2, widthY);
    _drawDashedLine(
      canvas,
      Offset(startW.dx, startW.dy + 5),
      Offset(startW.dx, center.dy - h / 2),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(endW.dx, endW.dy + 5),
      Offset(endW.dx, center.dy - h / 2),
      guidePaint,
    );
    canvas.drawLine(startW, endW, infoPaint);
    _drawArrowHead(canvas, startW, 0, infoPaint);
    _drawArrowHead(canvas, endW, 180, infoPaint);
    _drawText(
      canvas,
      "Width: ${stone.width.toStringAsFixed(2)} mm",
      Offset(center.dx, widthY - 10),
    );
    double lengthX = center.dx + w / 2 + 35;
    Offset topL = Offset(lengthX, center.dy - h / 2);
    Offset bottomL = Offset(lengthX, center.dy + h / 2);
    _drawDashedLine(
      canvas,
      Offset(topL.dx - 5, topL.dy),
      Offset(center.dx + w / 2, topL.dy),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(bottomL.dx - 5, bottomL.dy),
      Offset(center.dx + w / 2, bottomL.dy),
      guidePaint,
    );
    canvas.drawLine(topL, bottomL, infoPaint);
    _drawArrowHead(canvas, topL, 90, infoPaint);
    _drawArrowHead(canvas, bottomL, 270, infoPaint);
    _drawText(
      canvas,
      "Length: ${stone.length.toStringAsFixed(2)} mm",
      Offset(lengthX + 55, center.dy),
    );
    _drawText(
      canvas,
      "Length to Width: ${stone.ratio.toStringAsFixed(2)} to 1",
      Offset(center.dx, center.dy + h / 2 + 45),
      isGrey: true,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4;
    double distance = (p2 - p1).distance;
    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(
          p1.dx + (p2.dx - p1.dx) * i / distance,
          p1.dy + (p2.dy - p1.dy) * i / distance,
        ),
        Offset(
          p1.dx + (p2.dx - p1.dx) * (i + dashWidth) / distance,
          p1.dy + (p2.dy - p1.dy) * (i + dashWidth) / distance,
        ),
        paint,
      );
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset point,
    double angleDegrees,
    Paint paint,
  ) {
    final double arrowSize = 6.0;
    final double angle = angleDegrees * (3.14159 / 180);
    Path path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle - 0.5),
        point.dy + arrowSize * math.sin(angle - 0.5),
      )
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle + 0.5),
        point.dy + arrowSize * math.sin(angle + 0.5),
      );
    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool isGrey = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isGrey ? Colors.grey.shade700 : const Color(0xFF008080),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//Marquise
class MarquiseTopViewPainter extends CustomPainter {
  final GmssStone stone;
  MarquiseTopViewPainter({required this.stone});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final infoPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    const double visualH = 220.0;
    const double visualW = 110.0;
    final Path outerPath = Path();
    outerPath.moveTo(center.dx, center.dy - visualH / 2);
    outerPath.quadraticBezierTo(
      center.dx + visualW,
      center.dy,
      center.dx,
      center.dy + visualH / 2,
    );
    outerPath.quadraticBezierTo(
      center.dx - visualW,
      center.dy,
      center.dx,
      center.dy - visualH / 2,
    );
    canvas.drawPath(outerPath, paint);
    final double tableW = visualW * 0.4;
    final double tableH = visualH * 0.4;
    final Path tablePath = Path();
    tablePath.moveTo(center.dx, center.dy - tableH / 2);
    tablePath.lineTo(center.dx + tableW / 2, center.dy);
    tablePath.lineTo(center.dx, center.dy + tableH / 2);
    tablePath.lineTo(center.dx - tableW / 2, center.dy);
    tablePath.close();
    canvas.drawPath(tablePath, paint);
    _drawMarquiseFacets(
      canvas,
      center,
      visualW,
      visualH,
      tableW,
      tableH,
      paint,
    );
    _drawMarquiseBrilliantFacets(canvas, center, visualW, visualH, paint);
    _drawDimensions(canvas, center, visualW, visualH, infoPaint, guidePaint);
  }

  void _drawMarquiseBrilliantFacets(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    Paint paint,
  ) {
    double tw = w * 0.45;
    double th = h * 0.45;
    final Path tablePath = Path();
    tablePath.moveTo(center.dx, center.dy - th / 2);
    tablePath.lineTo(center.dx + tw / 2, center.dy);
    tablePath.lineTo(center.dx, center.dy + th / 2);
    tablePath.lineTo(center.dx - tw / 2, center.dy);
    tablePath.close();
    canvas.drawPath(tablePath, paint);
    canvas.drawLine(
      Offset(center.dx, center.dy - h / 2),
      Offset(center.dx, center.dy - th / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + h / 2),
      Offset(center.dx, center.dy + th / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + tw / 2, center.dy),
      Offset(center.dx + w / 2 * 0.9, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - tw / 2, center.dy),
      Offset(center.dx - w / 2 * 0.9, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - tw / 4, center.dy - th / 4),
      Offset(center.dx - w / 2 * 0.6, center.dy - h / 4),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + tw / 4, center.dy - th / 4),
      Offset(center.dx + w / 2 * 0.6, center.dy - h / 4),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - tw / 4, center.dy + th / 4),
      Offset(center.dx - w / 2 * 0.6, center.dy + h / 4),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + tw / 4, center.dy + th / 4),
      Offset(center.dx + w / 2 * 0.6, center.dy + h / 4),
      paint,
    );
  }

  void _drawMarquiseFacets(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    double tw,
    double th,
    Paint paint,
  ) {
    canvas.drawLine(
      Offset(center.dx, center.dy - h / 2),
      Offset(center.dx, center.dy - th / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + h / 2),
      Offset(center.dx, center.dy + th / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + tw / 2, center.dy),
      Offset(center.dx + w / 2, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - tw / 2, center.dy),
      Offset(center.dx - w / 2, center.dy),
      paint,
    );
  }

  void _drawDimensions(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    Paint infoPaint,
    Paint guidePaint,
  ) {
    double widthY = center.dy - h / 2 - 35;
    Offset startW = Offset(center.dx - w / 2 * 0.8, widthY);
    Offset endW = Offset(center.dx + w / 2 * 0.8, widthY);
    _drawDashedLine(
      canvas,
      Offset(startW.dx, startW.dy + 5),
      Offset(startW.dx, center.dy - h * 0.15),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(endW.dx, endW.dy + 5),
      Offset(endW.dx, center.dy - h * 0.15),
      guidePaint,
    );
    canvas.drawLine(startW, endW, infoPaint);
    _drawArrowHead(canvas, startW, 0, infoPaint);
    _drawArrowHead(canvas, endW, 180, infoPaint);
    _drawText(
      canvas,
      "Width: ${stone.width.toStringAsFixed(2)} mm",
      Offset(center.dx, widthY - 10),
    );
    double lengthX = center.dx + w / 2 + 35;
    Offset topL = Offset(lengthX, center.dy - h / 2);
    Offset bottomL = Offset(lengthX, center.dy + h / 2);
    _drawDashedLine(
      canvas,
      Offset(topL.dx - 5, topL.dy),
      Offset(center.dx, topL.dy),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(bottomL.dx - 5, bottomL.dy),
      Offset(center.dx, bottomL.dy),
      guidePaint,
    );
    canvas.drawLine(topL, bottomL, infoPaint);
    _drawArrowHead(canvas, topL, 90, infoPaint);
    _drawArrowHead(canvas, bottomL, 270, infoPaint);
    _drawText(
      canvas,
      "Length: ${stone.length.toStringAsFixed(2)} mm",
      Offset(lengthX + 55, center.dy),
    );
    _drawText(
      canvas,
      "Length to Width: ${stone.ratio.toStringAsFixed(2)} to 1",
      Offset(center.dx, center.dy + h / 2 + 45),
      isGrey: true,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4;
    double distance = (p2 - p1).distance;
    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(
          p1.dx + (p2.dx - p1.dx) * i / distance,
          p1.dy + (p2.dy - p1.dy) * i / distance,
        ),
        Offset(
          p1.dx + (p2.dx - p1.dx) * (i + dashWidth) / distance,
          p1.dy + (p2.dy - p1.dy) * (i + dashWidth) / distance,
        ),
        paint,
      );
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset point,
    double angleDegrees,
    Paint paint,
  ) {
    final double arrowSize = 6.0;
    final double angle = angleDegrees * (3.14159 / 180);
    Path path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle - 0.5),
        point.dy + arrowSize * math.sin(angle - 0.5),
      )
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle + 0.5),
        point.dy + arrowSize * math.sin(angle + 0.5),
      );
    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool isGrey = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isGrey ? Colors.grey.shade700 : const Color(0xFF008080),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//Pear
class PearTopViewPainter extends CustomPainter {
  final GmssStone stone;
  PearTopViewPainter({required this.stone});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final infoPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    final double h = size.height * 0.6;
    final double w = h * 0.65;
    final double topY = center.dy - h * 0.45;
    final double bottomY = center.dy + h * 0.45;
    final Path girdle = Path();
    girdle.moveTo(center.dx, topY);
    girdle.cubicTo(
      center.dx + w * 0.5,
      topY + h * 0.3,
      center.dx + w * 0.6,
      bottomY,
      center.dx,
      bottomY,
    );
    girdle.cubicTo(
      center.dx - w * 0.6,
      bottomY,
      center.dx - w * 0.5,
      topY + h * 0.3,
      center.dx,
      topY,
    );
    canvas.drawPath(girdle, paint);
    final double tw = w * 0.35;
    final double th = h * 0.4;
    final double tTopY = topY + h * 0.25;
    final double tBottomY = tTopY + th;
    final Offset tableTop = Offset(center.dx, tTopY);
    final Offset tableBottom = Offset(center.dx, tBottomY);
    final Offset tableRight = Offset(
      center.dx + tw * 0.45,
      center.dy + h * 0.05,
    );
    final Offset tableLeft = Offset(
      center.dx - tw * 0.45,
      center.dy + h * 0.05,
    );
    final Offset girdleMidRight = Offset(
      center.dx + w * 0.38,
      center.dy + h * 0.05,
    );
    final Offset girdleMidLeft = Offset(
      center.dx - w * 0.38,
      center.dy + h * 0.05,
    );
    final Offset girdleBottomRight = Offset(
      center.dx + w * 0.25,
      bottomY - h * 0.1,
    );
    final Offset girdleBottomLeft = Offset(
      center.dx - w * 0.25,
      bottomY - h * 0.1,
    );
    final Path tablePath = Path();
    tablePath.moveTo(tableTop.dx, tableTop.dy);
    tablePath.quadraticBezierTo(
      tableRight.dx + 5,
      tableTop.dy + th * 0.5,
      tableBottom.dx,
      tableBottom.dy,
    );
    tablePath.quadraticBezierTo(
      tableLeft.dx - 5,
      tableTop.dy + th * 0.5,
      tableTop.dx,
      tableTop.dy,
    );
    canvas.drawPath(tablePath, paint);
    canvas.drawLine(tableTop, Offset(center.dx, topY), paint);
    canvas.drawLine(tableBottom, Offset(center.dx, bottomY), paint);
    canvas.drawLine(
      tableTop,
      Offset(center.dx + w * 0.2, topY + h * 0.15),
      paint,
    );
    canvas.drawLine(
      tableTop,
      Offset(center.dx - w * 0.2, topY + h * 0.15),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + w * 0.2, topY + h * 0.15),
      tableRight,
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - w * 0.2, topY + h * 0.15),
      tableLeft,
      paint,
    );
    canvas.drawLine(tableRight, girdleMidRight, paint);
    canvas.drawLine(tableLeft, girdleMidLeft, paint);
    canvas.drawLine(tableRight, girdleBottomRight, paint);
    canvas.drawLine(tableLeft, girdleBottomLeft, paint);
    canvas.drawLine(tableBottom, girdleBottomRight, paint);
    canvas.drawLine(tableBottom, girdleBottomLeft, paint);
    _drawDimensions(canvas, center, w, h, infoPaint, guidePaint);
  }

  void _drawDimensions(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    Paint infoPaint,
    Paint guidePaint,
  ) {
    double spacing = h * 0.2;
    double widthY = center.dy - h * 0.45 - spacing;
    Offset startW = Offset(center.dx - w * 0.5, widthY);
    Offset endW = Offset(center.dx + w * 0.5, widthY);
    _drawDashedLine(
      canvas,
      Offset(startW.dx, startW.dy + 5),
      Offset(startW.dx, center.dy - h * 0.3),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(endW.dx, endW.dy + 5),
      Offset(endW.dx, center.dy - h * 0.3),
      guidePaint,
    );
    canvas.drawLine(startW, endW, infoPaint);
    _drawArrowHead(canvas, startW, 0, infoPaint);
    _drawArrowHead(canvas, endW, 180, infoPaint);
    _drawText(
      canvas,
      "Width: ${stone.width.toStringAsFixed(2)} mm",
      Offset(center.dx, widthY - 10),
    );
    double lengthX = center.dx + w * 0.5 + spacing;
    Offset topL = Offset(lengthX, center.dy - h * 0.45);
    Offset bottomL = Offset(lengthX, center.dy + h * 0.45);
    _drawDashedLine(
      canvas,
      Offset(topL.dx - 5, topL.dy),
      Offset(center.dx, topL.dy),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(bottomL.dx - 5, bottomL.dy),
      Offset(center.dx, bottomL.dy),
      guidePaint,
    );
    canvas.drawLine(topL, bottomL, infoPaint);
    _drawArrowHead(canvas, topL, 90, infoPaint);
    _drawArrowHead(canvas, bottomL, 270, infoPaint);
    _drawText(
      canvas,
      "Length: ${stone.length.toStringAsFixed(2)} mm",
      Offset(lengthX + 55, center.dy),
    );
    _drawText(
      canvas,
      "Length to Width: ${stone.ratio.toStringAsFixed(2)} to 1",
      Offset(center.dx, center.dy + h * 0.45 + 40),
      isGrey: true,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4;
    double distance = (p2 - p1).distance;
    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(
          p1.dx + (p2.dx - p1.dx) * i / distance,
          p1.dy + (p2.dy - p1.dy) * i / distance,
        ),
        Offset(
          p1.dx + (p2.dx - p1.dx) * (i + dashWidth) / distance,
          p1.dy + (p2.dy - p1.dy) * (i + dashWidth) / distance,
        ),
        paint,
      );
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset point,
    double angleDegrees,
    Paint paint,
  ) {
    final double arrowSize = 6.0;
    final double angle = angleDegrees * (math.pi / 180);
    Path path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle - 0.5),
        point.dy + arrowSize * math.sin(angle - 0.5),
      )
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle + 0.5),
        point.dy + arrowSize * math.sin(angle + 0.5),
      );
    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool isGrey = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isGrey ? Colors.grey.shade700 : const Color(0xFF008080),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//Oval
class OvalTopViewPainter extends CustomPainter {
  final GmssStone stone;
  OvalTopViewPainter({required this.stone});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final infoPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    final double h = size.height * 0.58;
    final double w = h * 0.7;
    final Rect outerRect = Rect.fromCenter(center: center, width: w, height: h);
    final Rect tableRect = Rect.fromCenter(
      center: center,
      width: w * 0.45,
      height: h * 0.55,
    );
    canvas.drawOval(outerRect, paint);
    canvas.drawOval(tableRect, paint);
    List<Offset> girdlePts = [];
    List<Offset> tablePts = [];
    List<Offset> starPts = [];
    for (int i = 0; i < 8; i++) {
      double angle = (i * 45 - 90) * math.pi / 180;
      girdlePts.add(
        Offset(
          center.dx + (w / 2) * math.cos(angle),
          center.dy + (h / 2) * math.sin(angle),
        ),
      );
      tablePts.add(
        Offset(
          center.dx + (tableRect.width / 2) * math.cos(angle),
          center.dy + (tableRect.height / 2) * math.sin(angle),
        ),
      );
      double midAngle = (i * 45 - 67.5) * math.pi / 180;
      starPts.add(
        Offset(
          center.dx + (w * 0.42) * math.cos(midAngle),
          center.dy + (h * 0.42) * math.sin(midAngle),
        ),
      );
    }
    for (int i = 0; i < 8; i++) {
      int next = (i + 1) % 8;
      canvas.drawLine(tablePts[i], girdlePts[i], paint);
      canvas.drawLine(girdlePts[i], starPts[i], paint);
      canvas.drawLine(girdlePts[next], starPts[i], paint);
      canvas.drawLine(tablePts[i], starPts[i], paint);
      canvas.drawLine(tablePts[next], starPts[i], paint);
    }
    _drawDimensions(canvas, center, w, h, infoPaint, guidePaint);
  }

  void _drawDimensions(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    Paint infoPaint,
    Paint guidePaint,
  ) {
    double spacing = h * 0.25;
    double widthY = center.dy - h / 2 - spacing;
    Offset startW = Offset(center.dx - w / 2, widthY);
    Offset endW = Offset(center.dx + w / 2, widthY);
    _drawDashedLine(
      canvas,
      Offset(startW.dx, startW.dy + 5),
      Offset(startW.dx, center.dy - h / 3),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(endW.dx, endW.dy + 5),
      Offset(endW.dx, center.dy - h / 3),
      guidePaint,
    );
    canvas.drawLine(startW, endW, infoPaint);
    _drawArrowHead(canvas, startW, 0, infoPaint);
    _drawArrowHead(canvas, endW, 180, infoPaint);
    _drawText(
      canvas,
      "Width: ${stone.width.toStringAsFixed(2)} mm",
      Offset(center.dx, widthY - 10),
    );
    double lengthX = center.dx + w / 2 + spacing;
    Offset topL = Offset(lengthX, center.dy - h / 2);
    Offset bottomL = Offset(lengthX, center.dy + h / 2);
    _drawDashedLine(
      canvas,
      Offset(topL.dx - 5, topL.dy),
      Offset(center.dx + w / 3, topL.dy),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(bottomL.dx - 5, bottomL.dy),
      Offset(center.dx + w / 3, bottomL.dy),
      guidePaint,
    );
    canvas.drawLine(topL, bottomL, infoPaint);
    _drawArrowHead(canvas, topL, 90, infoPaint);
    _drawArrowHead(canvas, bottomL, 270, infoPaint);
    _drawText(
      canvas,
      "Length: ${stone.length.toStringAsFixed(2)} mm",
      Offset(lengthX + 55, center.dy),
    );
    _drawText(
      canvas,
      "Length to Width: ${stone.ratio.toStringAsFixed(2)} to 1",
      Offset(center.dx, center.dy + h / 2 + 45),
      isGrey: true,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4;
    double distance = (p2 - p1).distance;
    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(
          p1.dx + (p2.dx - p1.dx) * i / distance,
          p1.dy + (p2.dy - p1.dy) * i / distance,
        ),
        Offset(
          p1.dx + (p2.dx - p1.dx) * (i + dashWidth) / distance,
          p1.dy + (p2.dy - p1.dy) * (i + dashWidth) / distance,
        ),
        paint,
      );
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset point,
    double angleDegrees,
    Paint paint,
  ) {
    final double arrowSize = 6.0;
    final double angle = angleDegrees * (3.14159 / 180);
    Path path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle - 0.5),
        point.dy + arrowSize * math.sin(angle - 0.5),
      )
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle + 0.5),
        point.dy + arrowSize * math.sin(angle + 0.5),
      );
    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool isGrey = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isGrey ? Colors.grey.shade700 : const Color(0xFF008080),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

//Heart
class HeartTopViewPainter extends CustomPainter {
  final GmssStone stone;
  HeartTopViewPainter({required this.stone});
  @override
  void paint(Canvas canvas, Size size) {
    final facetPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final dimensionPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    const double visualH = 170.0;
    const double visualW = 180.0;
    double cleftY = center.dy - visualH * 0.18;
    double bottomY = center.dy + visualH * 0.45;
    double lobeTopY = center.dy - visualH * 0.5;
    final Path heartPath = Path();
    heartPath.moveTo(center.dx, cleftY);
    heartPath.cubicTo(
      center.dx - visualW * 0.5,
      lobeTopY,
      center.dx - visualW * 0.65,
      center.dy + visualH * 0.1,
      center.dx,
      bottomY,
    );
    heartPath.moveTo(center.dx, cleftY);
    heartPath.cubicTo(
      center.dx + visualW * 0.5,
      lobeTopY,
      center.dx + visualW * 0.65,
      center.dy + visualH * 0.1,
      center.dx,
      bottomY,
    );
    canvas.drawPath(heartPath, facetPaint);
    _drawHeartBrilliance(
      canvas,
      center,
      visualW,
      visualH,
      cleftY,
      bottomY,
      facetPaint,
    );
    _drawDimensions(
      canvas,
      center,
      visualW,
      visualH,
      dimensionPaint,
      guidePaint,
    );
  }

  void _drawHeartBrilliance(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    double cleftY,
    double bottomY,
    Paint paint,
  ) {
    final double tw = w * 0.4;
    final double th = h * 0.35;
    final Path table = Path();
    table.moveTo(center.dx, center.dy - th * 0.45);
    table.lineTo(center.dx + tw * 0.5, center.dy - th * 0.1);
    table.lineTo(center.dx, center.dy + th * 0.65);
    table.lineTo(center.dx - tw * 0.5, center.dy - th * 0.1);
    table.close();
    canvas.drawPath(table, paint);
    canvas.drawLine(
      Offset(center.dx, cleftY),
      Offset(center.dx, center.dy - th * 0.45),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, bottomY),
      Offset(center.dx, center.dy + th * 0.65),
      paint,
    );
  }

  void _drawDimensions(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    Paint infoPaint,
    Paint guidePaint,
  ) {
    double widthY = center.dy - h * 0.45 - 35;
    Offset startW = Offset(center.dx - w * 0.45, widthY);
    Offset endW = Offset(center.dx + w * 0.45, widthY);
    _drawDashedLine(
      canvas,
      Offset(startW.dx, startW.dy + 5),
      Offset(startW.dx, center.dy - h * 0.1),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(endW.dx, endW.dy + 5),
      Offset(endW.dx, center.dy - h * 0.1),
      guidePaint,
    );
    canvas.drawLine(startW, endW, infoPaint);
    _drawArrowHead(canvas, startW, 0, infoPaint);
    _drawArrowHead(canvas, endW, 180, infoPaint);
    _drawText(
      canvas,
      "Width: ${stone.width.toStringAsFixed(2)} mm",
      Offset(center.dx, widthY - 10),
    );
    double lengthX = center.dx + w * 0.5 + 35;
    Offset topL = Offset(lengthX, center.dy - h * 0.45);
    Offset bottomL = Offset(lengthX, center.dy + h * 0.45);
    _drawDashedLine(
      canvas,
      Offset(topL.dx - 5, topL.dy),
      Offset(center.dx, topL.dy),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      Offset(bottomL.dx - 5, bottomL.dy),
      Offset(center.dx, bottomL.dy),
      guidePaint,
    );
    canvas.drawLine(topL, bottomL, infoPaint);
    _drawArrowHead(canvas, topL, 90, infoPaint);
    _drawArrowHead(canvas, bottomL, 270, infoPaint);
    _drawText(
      canvas,
      "Length: ${stone.length.toStringAsFixed(2)} mm",
      Offset(lengthX + 55, center.dy),
    );
    _drawText(
      canvas,
      "Length to Width: ${stone.ratio.toStringAsFixed(2)} to 1",
      Offset(center.dx, center.dy + h * 0.45 + 40),
      isGrey: true,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4;
    double distance = (p2 - p1).distance;
    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(
          p1.dx + (p2.dx - p1.dx) * i / distance,
          p1.dy + (p2.dy - p1.dy) * i / distance,
        ),
        Offset(
          p1.dx + (p2.dx - p1.dx) * (i + dashWidth) / distance,
          p1.dy + (p2.dy - p1.dy) * (i + dashWidth) / distance,
        ),
        paint,
      );
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset point,
    double angleDegrees,
    Paint paint,
  ) {
    final double arrowSize = 6.0;
    final double angle = angleDegrees * math.pi / 180;
    Path path = Path();
    path.moveTo(point.dx, point.dy);
    path.lineTo(
      point.dx + arrowSize * math.cos(angle - 0.5),
      point.dy + arrowSize * math.sin(angle - 0.5),
    );
    path.moveTo(point.dx, point.dy);
    path.lineTo(
      point.dx + arrowSize * math.cos(angle + 0.5),
      point.dy + arrowSize * math.sin(angle + 0.5),
    );
    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool isGrey = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isGrey ? Colors.grey.shade700 : const Color(0xFF008080),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

//Triangular (Trillion)
class TriangularTopViewPainter extends CustomPainter {
  final GmssStone stone;
  TriangularTopViewPainter({required this.stone});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final infoPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    final double side = size.width * 0.45;
    final double triangleHeight = (math.sqrt(3) / 2) * side;
    final double topY = center.dy - (triangleHeight * 0.4);
    final double bottomY = center.dy + (triangleHeight * 0.6);
    final List<Offset> girdle = [
      Offset(center.dx - side / 2, topY),
      Offset(center.dx + side / 2, topY),
      Offset(center.dx, bottomY),
    ];
    canvas.drawPath(Path()..addPolygon(girdle, true), paint);
    final double tw = side * 0.45;
    final double th = triangleHeight * 0.45;
    final double tableTopY = center.dy - (th * 0.2);
    final List<Offset> table = [
      Offset(center.dx - tw / 2, tableTopY),
      Offset(center.dx + tw / 2, tableTopY),
      Offset(center.dx, tableTopY + th),
    ];
    canvas.drawPath(Path()..addPolygon(table, true), paint);
    canvas.drawLine(table as Offset, girdle as Offset, paint);
    canvas.drawLine(table as Offset, girdle as Offset, paint);
    canvas.drawLine(table as Offset, girdle as Offset, paint);
    final Offset topMid = Offset(center.dx, topY);
    final Offset leftMid = Offset(
      center.dx - side * 0.25,
      center.dy + triangleHeight * 0.1,
    );
    final Offset rightMid = Offset(
      center.dx + side * 0.25,
      center.dy + triangleHeight * 0.1,
    );
    canvas.drawLine(table as Offset, topMid, paint);
    canvas.drawLine(table as Offset, topMid, paint);
    canvas.drawLine(table as Offset, leftMid, paint);
    canvas.drawLine(table as Offset, leftMid, paint);
    canvas.drawLine(table as Offset, rightMid, paint);
    canvas.drawLine(table as Offset, rightMid, paint);
    canvas.drawLine(table as Offset, center, paint);
    canvas.drawLine(table as Offset, center, paint);
    canvas.drawLine(table as Offset, center, paint);
    _drawDimensions(
      canvas,
      center,
      side,
      triangleHeight,
      infoPaint,
      guidePaint,
    );
  }

  void _drawDimensions(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    Paint infoPaint,
    Paint guidePaint,
  ) {
    final double spacing = w * 0.25;
    double widthY = center.dy - h * 0.6;
    Offset startW = Offset(center.dx - w / 2, widthY);
    Offset endW = Offset(center.dx + w / 2, widthY);
    _drawDashedLine(
      canvas,
      startW,
      Offset(startW.dx, center.dy - h * 0.4),
      guidePaint,
    );
    _drawDashedLine(
      canvas,
      endW,
      Offset(endW.dx, center.dy - h * 0.4),
      guidePaint,
    );
    canvas.drawLine(startW, endW, infoPaint);
    _drawArrowHead(canvas, startW, 0, infoPaint);
    _drawArrowHead(canvas, endW, 180, infoPaint);
    _drawText(
      canvas,
      "Width: ${stone.width.toStringAsFixed(2)} mm",
      Offset(center.dx, widthY - 15),
    );
    double lengthX = center.dx + w / 2 + spacing;
    Offset topL = Offset(lengthX, center.dy - h * 0.4);
    Offset bottomL = Offset(lengthX, center.dy + h * 0.6);
    _drawDashedLine(canvas, topL, Offset(center.dx, topL.dy), guidePaint);
    _drawDashedLine(canvas, bottomL, Offset(center.dx, bottomL.dy), guidePaint);
    canvas.drawLine(topL, bottomL, infoPaint);
    _drawArrowHead(canvas, topL, 90, infoPaint);
    _drawArrowHead(canvas, bottomL, 270, infoPaint);
    _drawText(
      canvas,
      "Length: ${stone.length.toStringAsFixed(2)} mm",
      Offset(lengthX + 55, center.dy),
    );
    _drawText(
      canvas,
      "Length to Width: ${stone.ratio.toStringAsFixed(2)} to 1",
      Offset(center.dx, center.dy + h * 0.8),
      isGrey: true,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    double dashWidth = 4, dashSpace = 4;
    double distance = (p2 - p1).distance;
    if (distance <= 0) return;
    for (double i = 0; i < distance; i += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(
          p1.dx + (p2.dx - p1.dx) * i / distance,
          p1.dy + (p2.dy - p1.dy) * i / distance,
        ),
        Offset(
          p1.dx + (p2.dx - p1.dx) * (i + dashWidth) / distance,
          p1.dy + (p2.dy - p1.dy) * (i + dashWidth) / distance,
        ),
        paint,
      );
    }
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset point,
    double angleDegrees,
    Paint paint,
  ) {
    final double arrowSize = 6.0;
    final double angle = angleDegrees * (math.pi / 180);
    Path path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle - 0.5),
        point.dy + arrowSize * math.sin(angle - 0.5),
      )
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + arrowSize * math.cos(angle + 0.5),
        point.dy + arrowSize * math.sin(angle + 0.5),
      );
    canvas.drawPath(path, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool isGrey = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isGrey ? Colors.grey.shade700 : const Color(0xFF008080),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BaguetteTopViewPainter extends CustomPainter {
  final GmssStone stone;
  BaguetteTopViewPainter({required this.stone});
  @override
  void paint(Canvas canvas, Size size) {
    final facetPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final filledPaint = Paint()
      ..color = const Color(0xFF008080).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    final dimensionPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final guidePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width * 0.45) / 2;
    final double h = radius * 2;
    final double w = h / (stone.ratio > 0 ? stone.ratio : 1.0);
    _drawDashedBoundary(canvas, center, w, h, guidePaint);
    List<Offset> outerPoints = [];
    for (int i = 0; i < 6; i++) {
      double angle = (i * 60) * math.pi / 180;
      outerPoints.add(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
      );
    }
    final double tableRadius = radius * 0.45;
    List<Offset> tablePoints = [];
    for (int i = 0; i < 6; i++) {
      double angle = (i * 60) * math.pi / 180;
      tablePoints.add(
        Offset(
          center.dx + tableRadius * math.cos(angle),
          center.dy + tableRadius * math.sin(angle),
        ),
      );
    }
    final Path hexPath = Path()..addPolygon(outerPoints, true);
    canvas.drawPath(hexPath, filledPaint);
    canvas.drawPath(hexPath, facetPaint);
    canvas.drawPath(Path()..addPolygon(tablePoints, true), facetPaint);
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(tablePoints[i], outerPoints[i], facetPaint);
      double midAngle = (i * 60 + 30) * math.pi / 180;
      Offset girdleMid = Offset(
        center.dx + (radius * 0.866) * math.cos(midAngle),
        center.dy + (radius * 0.866) * math.sin(midAngle),
      );
      canvas.drawLine(tablePoints[i], girdleMid, facetPaint);
      canvas.drawLine(tablePoints[(i + 1) % 6], girdleMid, facetPaint);
      canvas.drawLine(center, tablePoints[i], facetPaint);
    }
    _drawDimensions(canvas, center, radius, dimensionPaint);
  }

  void _drawDashedBoundary(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    Paint paint,
  ) {
    final double top = center.dy - h / 2;
    final double bottom = center.dy + h / 2;
    final double left = center.dx - w / 2;
    final double right = center.dx + w / 2;
    const double ext = 15.0;
    void drawLine(Offset p1, Offset p2) {
      double dist = (p2 - p1).distance;
      for (double i = 0; i < dist; i += 8) {
        canvas.drawLine(
          Offset(
            p1.dx + (p2.dx - p1.dx) * i / dist,
            p1.dy + (p2.dy - p1.dy) * i / dist,
          ),
          Offset(
            p1.dx + (p2.dx - p1.dx) * (i + 4) / dist,
            p1.dy + (p2.dy - p1.dy) * (i + 4) / dist,
          ),
          paint,
        );
      }
    }

    drawLine(Offset(left - ext, top), Offset(left, top));
    drawLine(Offset(left, top - ext), Offset(left, top));
    drawLine(Offset(right, top), Offset(right + ext, top));
    drawLine(Offset(right, top - ext), Offset(right, top));
    drawLine(Offset(left - ext, bottom), Offset(left, bottom));
    drawLine(Offset(left, bottom), Offset(left, bottom + ext));
    drawLine(Offset(right, bottom), Offset(right + ext, bottom));
    drawLine(Offset(right, bottom), Offset(right, bottom + ext));
  }

  void _drawDimensions(
    Canvas canvas,
    Offset center,
    double radius,
    Paint infoPaint,
  ) {
    double widthY = center.dy - radius - 35;
    canvas.drawLine(
      Offset(center.dx - radius, widthY),
      Offset(center.dx + radius, widthY),
      infoPaint,
    );
    _drawArrow(canvas, Offset(center.dx - radius, widthY), 0, infoPaint);
    _drawArrow(canvas, Offset(center.dx + radius, widthY), 180, infoPaint);
    _drawText(
      canvas,
      "Width: ${stone.width} mm",
      Offset(center.dx, widthY - 15),
    );
    double lengthX = center.dx + radius + 35;
    canvas.drawLine(
      Offset(lengthX, center.dy - radius),
      Offset(lengthX, center.dy + radius),
      infoPaint,
    );
    _drawArrow(canvas, Offset(lengthX, center.dy - radius), 90, infoPaint);
    _drawArrow(canvas, Offset(lengthX, center.dy + radius), 270, infoPaint);
    _drawText(
      canvas,
      "Length: ${stone.length} mm",
      Offset(lengthX + 55, center.dy),
    );
    _drawText(
      canvas,
      "Ratio: ${stone.ratio.toStringAsFixed(2)} to 1",
      Offset(center.dx, center.dy + radius + 45),
      isGrey: true,
    );
  }

  void _drawArrow(Canvas canvas, Offset point, double angleDeg, Paint paint) {
    double angle = angleDeg * math.pi / 180;
    Path p = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + 6 * math.cos(angle - 0.5),
        point.dy + 6 * math.sin(angle - 0.5),
      )
      ..moveTo(point.dx, point.dy)
      ..lineTo(
        point.dx + 6 * math.cos(angle + 0.5),
        point.dy + 6 * math.sin(angle + 0.5),
      );
    canvas.drawPath(p, paint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos, {
    bool isGrey = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: isGrey ? Colors.grey.shade700 : const Color(0xFF008080),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

//Diamonds
class DiamondProfilePainter extends CustomPainter {
  final GmssStone stone;
  DiamondProfilePainter({required this.stone});
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final infoPaint = Paint()
      ..color = const Color(0xFF008080)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final dashedPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    const double visualWidth = 200.0;
    const double visualTotalHeight = 130.0;
    final double centerX = size.width / 2;
    final double startY = 100.0;
    final double drawTableWidth = visualWidth * 0.55;
    final double drawCrownHeight = visualTotalHeight * 0.25;
    final double width = size.width * 0.55;
    final double tableWidth = width * (stone.table / 100);
    final double totalHeight = width * (stone.depth / 100);
    final double crownHeight = totalHeight * 0.25;
    _drawDashedRect(
      canvas,
      centerX,
      visualWidth,
      startY,
      visualTotalHeight,
      dashedPaint,
    );
    final Path path = Path();
    path.moveTo(centerX - drawTableWidth / 2, startY);
    path.lineTo(centerX + drawTableWidth / 2, startY);
    path.lineTo(centerX + visualWidth / 2, startY + drawCrownHeight);
    path.lineTo(centerX + visualWidth / 2, startY + drawCrownHeight + 4);
    path.lineTo(centerX, startY + visualTotalHeight);
    path.lineTo(centerX - visualWidth / 2, startY + drawCrownHeight + 4);
    path.lineTo(centerX - visualWidth / 2, startY + drawCrownHeight);
    path.close();
    canvas.drawPath(path, linePaint);
    double tableLineY = startY - 15;
    canvas.drawLine(
      Offset(centerX - tableWidth / 2, tableLineY),
      Offset(centerX + tableWidth / 2, tableLineY),
      infoPaint,
    );
    _drawArrowHead(
      canvas,
      Offset(centerX - tableWidth / 2, tableLineY),
      0,
      infoPaint,
    );
    _drawArrowHead(
      canvas,
      Offset(centerX + tableWidth / 2, tableLineY),
      180,
      infoPaint,
    );
    _drawText(
      canvas,
      "Table %: ${stone.table.toInt()}%",
      Offset(centerX, tableLineY - 15),
    );
    double depthX = centerX + width / 2 + 35;
    canvas.drawLine(
      Offset(depthX, startY),
      Offset(depthX, startY + totalHeight),
      infoPaint,
    );
    _drawArrowHead(canvas, Offset(depthX, startY), 90, infoPaint);
    _drawArrowHead(
      canvas,
      Offset(depthX, startY + totalHeight),
      270,
      infoPaint,
    );
    _drawText(
      canvas,
      "Depth %: ${stone.depth}%",
      Offset(depthX + 45, startY + totalHeight / 2 - 10),
    );
    _drawText(
      canvas,
      "Depth: ${stone.length} mm",
      Offset(depthX + 45, startY + totalHeight / 2 + 10),
    );
    _drawIndicator(
      canvas,
      Offset(centerX + width / 4, startY + crownHeight + 2),
      "Girdle: ${stone.gridle_condition}",
      infoPaint,
      true,
    );
    _drawIndicator(
      canvas,
      Offset(centerX - 5, startY + totalHeight - 5),
      "Culet: ${stone.culet_size}",
      infoPaint,
      false,
    );
  }

  void _drawDashedRect(
    Canvas canvas,
    double cx,
    double w,
    double sy,
    double h,
    Paint paint,
  ) {
    double dashWidth = 4, dashSpace = 4;
    for (
      double i = cx + w / 2;
      i < cx + w / 2 + 35;
      i += dashWidth + dashSpace
    ) {
      canvas.drawLine(Offset(i, sy), Offset(i + dashWidth, sy), paint);
    }
    for (double i = cx; i < cx + w / 2 + 35; i += dashWidth + dashSpace) {
      canvas.drawLine(Offset(i, sy + h), Offset(i + dashWidth, sy + h), paint);
    }
  }

  void _drawIndicator(
    Canvas canvas,
    Offset point,
    String text,
    Paint paint,
    bool isGirdle,
  ) {
    canvas.drawCircle(point, 12, paint);
    Offset endPoint = isGirdle
        ? Offset(point.dx + 20, point.dy + 80)
        : Offset(point.dx - 40, point.dy + 40);
    canvas.drawLine(point, endPoint, paint);
    _drawText(canvas, text, Offset(endPoint.dx, endPoint.dy + 10));
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset point,
    double angleDegrees,
    Paint paint,
  ) {
    final double arrowSize = 6.0;
    final double angle = angleDegrees * math.pi / 180;
    Path path = Path();
    path.moveTo(point.dx, point.dy);
    path.lineTo(
      point.dx + arrowSize * math.cos(angle - 0.5),
      point.dy + arrowSize * math.sin(angle - 0.5),
    );
    path.moveTo(point.dx, point.dy);
    path.lineTo(
      point.dx + arrowSize * math.cos(angle + 0.5),
      point.dy + arrowSize * math.sin(angle + 0.5),
    );
    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF008080),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
