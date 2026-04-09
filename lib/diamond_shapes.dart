import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract class MinimalShapePainter extends CustomPainter {
  final Color color;
  MinimalShapePainter({this.color = const Color(0xFF2D3142)});
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 1. ROUND
class MinimalRoundPainter extends MinimalShapePainter {
  MinimalRoundPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
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
    List<Offset> middlePoints = [];
    for (int i = 0; i < 8; i++) {
      double angle = (i * 45 + 22.5) * math.pi / 180;
      middlePoints.add(
        Offset(
          center.dx + middleRadius * math.cos(angle),
          center.dy + middleRadius * math.sin(angle),
        ),
      );
    }
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
  }
}

// 2. EMERALD
class MinimalEmeraldPainter extends MinimalShapePainter {
  MinimalEmeraldPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    final double outerW = size.width * 0.62;
    final double outerH = size.height * 0.85;
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
  }
}

// 3. PRINCESS
class MinimalPrincessPainter extends MinimalShapePainter {
  MinimalPrincessPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    final double side = size.width * 0.75;
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
  }
}

//4. Cushion
class MinimalCushionPainter extends MinimalShapePainter {
  MinimalCushionPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    final double h = size.height * 0.7;
    final double w = h * 0.9;
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
    canvas.drawLine(
      Offset(outerRRect.left + 10, outerRRect.top + 10),
      Offset(tableRRect.left, tableRRect.top),
      paint,
    );
    canvas.drawLine(
      Offset(outerRRect.right - 10, outerRRect.top + 10),
      Offset(tableRRect.right, tableRRect.top),
      paint,
    );
    canvas.drawLine(
      Offset(outerRRect.left + 10, outerRRect.bottom - 10),
      Offset(tableRRect.left, tableRRect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(outerRRect.right - 10, outerRRect.bottom - 10),
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
  }
}

// 5. RADIANT
class MinimalRadiantPainter extends MinimalShapePainter {
  MinimalRadiantPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final center = Offset(size.width / 2, size.height / 2);
    final double w = size.width * 0.65;
    final double h = size.height * 0.85;
    final double cropOuter = 10.0;
    final double tw = w * 0.5;
    final double th = h * 0.5;
    final double cropInner = 5.0;
    Path getRadiantPath(
      Offset center,
      double width,
      double height,
      double crop,
    ) {
      return Path()
        ..moveTo(center.dx - width / 2 + crop, center.dy - height / 2)
        ..lineTo(center.dx + width / 2 - crop, center.dy - height / 2)
        ..lineTo(center.dx + width / 2, center.dy - height / 2 + crop)
        ..lineTo(center.dx + width / 2, center.dy + height / 2 - crop)
        ..lineTo(center.dx + width / 2 - crop, center.dy + height / 2)
        ..lineTo(center.dx - width / 2 + crop, center.dy + height / 2)
        ..lineTo(center.dx - width / 2, center.dy + height / 2 - crop)
        ..lineTo(center.dx - width / 2, center.dy - height / 2 + crop)
        ..close();
    }

    canvas.drawPath(getRadiantPath(center, w, h, cropOuter), paint);
    canvas.drawPath(getRadiantPath(center, tw, th, cropInner), paint);
    canvas.drawLine(
      Offset(center.dx - w / 2 + cropOuter, center.dy - h / 2),
      Offset(center.dx - tw / 2 + cropInner, center.dy - th / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + w / 2 - cropOuter, center.dy - h / 2),
      Offset(center.dx + tw / 2 - cropInner, center.dy - th / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - w / 2 + cropOuter, center.dy + h / 2),
      Offset(center.dx - tw / 2 + cropInner, center.dy + th / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + w / 2 - cropOuter, center.dy + h / 2),
      Offset(center.dx + tw / 2 - cropInner, center.dy + th / 2),
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
}

// 6. MARQUISE
class MinimalMarquisePainter extends MinimalShapePainter {
  MinimalMarquisePainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    final double h = size.height * 0.85;
    final double w = size.width * 0.45;
    final Path outer = Path();
    outer.moveTo(center.dx, center.dy - h / 2);
    outer.quadraticBezierTo(
      center.dx + w,
      center.dy,
      center.dx,
      center.dy + h / 2,
    );
    outer.quadraticBezierTo(
      center.dx - w,
      center.dy,
      center.dx,
      center.dy - h / 2,
    );
    canvas.drawPath(outer, paint);
    final double tw = w * 0.45;
    final double th = h * 0.45;
    final Path tablePath = Path()
      ..moveTo(center.dx, center.dy - th / 2)
      ..lineTo(center.dx + tw / 2, center.dy)
      ..lineTo(center.dx, center.dy + th / 2)
      ..lineTo(center.dx - tw / 2, center.dy)
      ..close();
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
}

// 7. PEAR
class MinimalPearPainter extends MinimalShapePainter {
  MinimalPearPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final center = Offset(size.width / 2, size.height / 2);
    final double h = size.height * 0.85;
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
    final Offset tableRight = Offset(
      center.dx + tw * 0.45,
      center.dy + h * 0.05,
    );
    final Offset tableLeft = Offset(
      center.dx - tw * 0.45,
      center.dy + h * 0.05,
    );
    final Offset tableBottom = Offset(center.dx, tBottomY);
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
    canvas.drawLine(tableTop, Offset(center.dx, topY), paint);
    canvas.drawLine(tableBottom, Offset(center.dx, bottomY), paint);
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
    canvas.drawLine(
      tableBottom,
      Offset(center.dx + w * 0.15, bottomY - h * 0.02),
      paint,
    );
    canvas.drawLine(
      tableBottom,
      Offset(center.dx - w * 0.15, bottomY - h * 0.02),
      paint,
    );
  }
}

// 8. OVAL
class MinimalOvalPainter extends MinimalShapePainter {
  MinimalOvalPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final center = Offset(size.width / 2, size.height / 2);
    final double h = size.height * 0.9;
    final double w = h * 0.65;
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
  }
}

// 9. HEART
class MinimalHeartPainter extends MinimalShapePainter {
  MinimalHeartPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    final double h = size.height * 0.75;
    final double w = size.width * 0.85;
    double cleftY = center.dy - h * 0.18;
    double bottomY = center.dy + h * 0.45;
    double lobeTopY = center.dy - h * 0.5;
    final Path heartPath = Path();
    heartPath.moveTo(center.dx, cleftY);
    heartPath.cubicTo(
      center.dx - w * 0.5,
      lobeTopY,
      center.dx - w * 0.65,
      center.dy + h * 0.1,
      center.dx,
      bottomY,
    );
    heartPath.moveTo(center.dx, cleftY);
    heartPath.cubicTo(
      center.dx + w * 0.5,
      lobeTopY,
      center.dx + w * 0.65,
      center.dy + h * 0.1,
      center.dx,
      bottomY,
    );
    canvas.drawPath(heartPath, paint);
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
}

// 10. ASSCHER
class MinimalAsscherPainter extends MinimalShapePainter {
  MinimalAsscherPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    final double side = size.width * 0.8;
    List<double> scales = [1.0, 0.82, 0.64, 0.45];
    List<List<Offset>> layers = [];
    for (var scale in scales) {
      double s = side * scale;
      double c = (s / 3.2);
      List<Offset> points = [
        Offset(center.dx - s / 2 + c, center.dy - s / 2),
        Offset(center.dx + s / 2 - c, center.dy - s / 2),
        Offset(center.dx + s / 2, center.dy - s / 2 + c),
        Offset(center.dx + s / 2, center.dy + s / 2 - c),
        Offset(center.dx + s / 2 - c, center.dy + s / 2),
        Offset(center.dx - s / 2 + c, center.dy + s / 2),
        Offset(center.dx - s / 2, center.dy + s / 2 - c),
        Offset(center.dx - s / 2, center.dy - s / 2 + c),
      ];
      layers.add(points);
      canvas.drawPath(Path()..addPolygon(points, true), paint);
    }
    final innerLayer = layers.last;
    for (int j = 0; j < 8; j++) {
      canvas.drawLine(innerLayer[j], center, paint);
    }
    for (int i = 0; i < layers.length - 1; i++) {
      for (int j = 0; j < 8; j++) {
        canvas.drawLine(layers[i][j], layers[i + 1][j], paint);
      }
    }
  }
}

// 11. ROSE CUT
class MinimalRosePainter extends MinimalShapePainter {
  MinimalRosePainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width * 0.42;
    List<Offset> outerPoints = [];
    for (int i = 0; i < 6; i++) {
      double angle = (i * 60 - 30) * math.pi / 180;
      outerPoints.add(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
      );
    }
    final double innerRadius = radius * 0.45;
    List<Offset> innerPoints = [];
    for (int i = 0; i < 6; i++) {
      double angle = (i * 60 - 30) * math.pi / 180;
      innerPoints.add(
        Offset(
          center.dx + innerRadius * math.cos(angle),
          center.dy + innerRadius * math.sin(angle),
        ),
      );
    }
    canvas.drawPath(Path()..addPolygon(outerPoints, true), paint);
    canvas.drawPath(Path()..addPolygon(innerPoints, true), paint);
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(innerPoints[i], outerPoints[i], paint);
      canvas.drawLine(innerPoints[i], outerPoints[(i + 1) % 6], paint);
      canvas.drawLine(center, innerPoints[i], paint);
    }
  }
}

// 12. BAGUETTE (Faceted Hexagon style based on your image)
class MinimalBaguettePainter extends MinimalShapePainter {
  MinimalBaguettePainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width * 0.45;
    List<Offset> outerPoints = [];
    for (int i = 0; i < 6; i++) {
      double angle = (i * 60 + 90) * math.pi / 180;
      outerPoints.add(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
      );
    }
    canvas.drawPath(Path()..addPolygon(outerPoints, true), paint);
    List<Offset> midPoints = outerPoints
        .map(
          (p) => Offset(
            center.dx + (p.dx - center.dx) * 0.5,
            center.dy + (p.dy - center.dy) * 0.5,
          ),
        )
        .toList();
    for (int i = 0; i < 6; i++) {
      if (i < 3) {
        canvas.drawLine(outerPoints[i], outerPoints[i + 3], paint);
      }
      canvas.drawLine(midPoints[i], outerPoints[(i + 1) % 6], paint);
      canvas.drawLine(midPoints[i], outerPoints[(i + 5) % 6], paint);
      canvas.drawLine(midPoints[i], midPoints[(i + 1) % 6], paint);
    }
  }
}

// 13. HALF MOON
class MinimalHalfMoonPainter extends CustomPainter {
  final Color color;
  MinimalHalfMoonPainter({this.color = Colors.black});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final center = Offset(size.width / 2, size.height / 2);
    final double w = size.width * 0.85;
    final double h = w * 0.45;
    final double topY = center.dy - h / 2;
    final Path path = Path();
    path.moveTo(center.dx - w / 2, topY);
    path.lineTo(center.dx + w / 2, topY);
    path.addArc(
      Rect.fromCenter(center: Offset(center.dx, topY), width: w, height: h * 2),
      0,
      math.pi,
    );

    canvas.drawPath(path, paint);
    final List<Offset> top = [
      Offset(center.dx - w / 2, topY),
      Offset(center.dx - w * 0.25, topY),
      Offset(center.dx, topY),
      Offset(center.dx + w * 0.25, topY),
      Offset(center.dx + w / 2, topY),
    ];
    final Offset vLeft = Offset(center.dx - w * 0.2, topY + h * 0.3);
    final Offset vRight = Offset(center.dx + w * 0.2, topY + h * 0.3);
    final Offset vBottom = Offset(center.dx, topY + h * 0.55);
    final Offset arcLeft = Offset(center.dx - w * 0.4, topY + h * 0.5);
    final Offset arcRight = Offset(center.dx + w * 0.4, topY + h * 0.5);
    final Offset arcBottomLeft = Offset(center.dx - w * 0.2, topY + h * 0.85);
    final Offset arcBottomRight = Offset(center.dx + w * 0.2, topY + h * 0.85);
    final Offset arcCenterPoint = Offset(center.dx, topY + h);
    canvas.drawLine(top[2], vLeft, paint);
    canvas.drawLine(top[2], vRight, paint);
    canvas.drawLine(vLeft, vBottom, paint);
    canvas.drawLine(vRight, vBottom, paint);
    canvas.drawLine(vLeft, vRight, paint);
    canvas.drawLine(vLeft, top[1], paint);
    canvas.drawLine(vRight, top[3], paint);
    canvas.drawLine(vBottom, top[2], paint);
    canvas.drawLine(vLeft, arcLeft, paint);
    canvas.drawLine(vLeft, arcBottomLeft, paint);
    canvas.drawLine(vBottom, arcBottomLeft, paint);
    canvas.drawLine(vBottom, arcCenterPoint, paint);
    canvas.drawLine(vBottom, arcBottomRight, paint);
    canvas.drawLine(vRight, arcBottomRight, paint);
    canvas.drawLine(vRight, arcRight, paint);
    canvas.drawLine(top[0], arcLeft, paint);
    canvas.drawLine(top[4], arcRight, paint);
    canvas.drawLine(top[1], arcBottomLeft, paint);
    canvas.drawLine(top[3], arcBottomRight, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 14. TRAPEZOID
class MinimalTrapezoidPainter extends MinimalShapePainter {
  MinimalTrapezoidPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final center = Offset(size.width / 2, size.height / 2);
    final double topW = size.width * 0.85;
    final double bottomW = size.width * 0.55;
    final double h = size.height * 0.5;
    List<double> scales = [1.0, 0.75, 0.50, 0.25];
    List<List<Offset>> layers = [];
    for (var s in scales) {
      double curTopW = topW * s;
      double curBottomW = bottomW * s;
      double curH = h * s;
      double curTopY = center.dy - curH / 2;
      double curBottomY = center.dy + curH / 2;
      List<Offset> points = [
        Offset(center.dx - curTopW / 2, curTopY), // Top Left
        Offset(center.dx + curTopW / 2, curTopY), // Top Right
        Offset(center.dx + curBottomW / 2, curBottomY), // Bottom Right
        Offset(center.dx - curBottomW / 2, curBottomY), // Bottom Left
      ];
      layers.add(points);
      canvas.drawPath(Path()..addPolygon(points, true), paint);
    }
    for (int i = 0; i < layers.length - 1; i++) {
      for (int j = 0; j < 4; j++) {
        canvas.drawLine(layers[i][j], layers[i + 1][j], paint);
      }
    }
  }
}

// 15. PENTAGONAL (Faceted/Step style)
class MinimalPentagonalPainter extends MinimalShapePainter {
  MinimalPentagonalPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width * 0.45;
    List<double> scales = [1.0, 0.75, 0.5, 0.25];
    List<List<Offset>> layers = [];
    for (var scale in scales) {
      double r = maxRadius * scale;
      List<Offset> points = [];
      for (int i = 0; i < 5; i++) {
        double angle = (i * 72 - 18) * math.pi / 180;
        points.add(
          Offset(
            center.dx + r * math.cos(angle),
            center.dy + r * math.sin(angle),
          ),
        );
      }
      layers.add(points);
      canvas.drawPath(Path()..addPolygon(points, true), paint);
    }
    final innerLayer = layers.last;
    for (int j = 0; j < 5; j++) {
      canvas.drawLine(innerLayer[j], center, paint);
    }
    for (int i = 0; i < layers.length - 1; i++) {
      for (int j = 0; j < 5; j++) {
        canvas.drawLine(layers[i][j], layers[i + 1][j], paint);
      }
    }
  }
}

// 16. HEXAGONAL (Step/Nested style as seen in image_3f05eb.png)
class MinimalHexagonalPainter extends MinimalShapePainter {
  MinimalHexagonalPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width * 0.45;
    List<double> scales = [1.0, 0.76, 0.52, 0.28];
    List<List<Offset>> layers = [];
    for (var scale in scales) {
      double r = maxRadius * scale;
      List<Offset> points = [];
      for (int i = 0; i < 6; i++) {
        double angle = (i * 60) * math.pi / 180;
        points.add(
          Offset(
            center.dx + r * math.cos(angle),
            center.dy + r * math.sin(angle),
          ),
        );
      }
      layers.add(points);
      canvas.drawPath(Path()..addPolygon(points, true), paint);
    }
    final innerLayer = layers.last;
    for (int j = 0; j < 6; j++) {
      canvas.drawLine(innerLayer[j], center, paint);
    }
    for (int i = 0; i < layers.length - 1; i++) {
      for (int j = 0; j < 6; j++) {
        canvas.drawLine(layers[i][j], layers[i + 1][j], paint);
      }
    }
  }
}

// 17. TRIANGULAR
class MinimalTriangularPainter extends CustomPainter {
  final Color color;
  MinimalTriangularPainter({this.color = Colors.black});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final center = Offset(size.width / 2, size.height / 2);
    final double side = size.width * 0.9;
    final double h = (math.sqrt(3) / 2) * side;
    final double topY = center.dy - (h * 0.4);
    final double bottomY = center.dy + (h * 0.6);
    final List<Offset> girdle = [
      Offset(center.dx - side / 2, topY),
      Offset(center.dx + side / 2, topY),
      Offset(center.dx, bottomY),
    ];
    canvas.drawPath(Path()..addPolygon(girdle, true), paint);
    final double tw = side * 0.45;
    final double th = h * 0.45;
    final double tableTopY = center.dy - (th * 0.2);
    final double tableBottomY = center.dy + (th * 0.6);
    final List<Offset> table = [
      Offset(center.dx - tw / 2, tableTopY),
      Offset(center.dx + tw / 2, tableTopY),
      Offset(center.dx, tableBottomY),
    ];
    canvas.drawPath(Path()..addPolygon(table, true), paint);
    canvas.drawLine(table[0], girdle[0], paint);
    canvas.drawLine(table[1], girdle[1], paint);
    canvas.drawLine(table[2], girdle[2], paint);
    canvas.drawLine(table[0], girdle[1], paint);
    canvas.drawLine(table[1], girdle[2], paint);
    canvas.drawLine(table[2], girdle[0], paint);
    final Offset topMid = Offset(center.dx, topY);
    final Offset leftMid = Offset(center.dx - side * 0.25, center.dy + h * 0.1);
    final Offset rightMid = Offset(
      center.dx + side * 0.25,
      center.dy + h * 0.1,
    );
    canvas.drawLine(table[0], topMid, paint);
    canvas.drawLine(table[1], topMid, paint);
    canvas.drawLine(table[0], leftMid, paint);
    canvas.drawLine(table[2], leftMid, paint);
    canvas.drawLine(table[1], rightMid, paint);
    canvas.drawLine(table[2], rightMid, paint);
    canvas.drawLine(table[0], center, paint);
    canvas.drawLine(table[1], center, paint);
    canvas.drawLine(table[2], center, paint);
    canvas.drawLine(leftMid, center, paint);
    canvas.drawLine(rightMid, center, paint);
    canvas.drawLine(topMid, center, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 18. TRILLIANT
class MinimalTrilliantPainter extends CustomPainter {
  final Color color;
  MinimalTrilliantPainter({this.color = Colors.black});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final center = Offset(size.width / 2, size.height / 2);
    final double side = size.width * 0.95;
    final double h = (math.sqrt(3) / 2) * side;
    final double topY = center.dy - (h * 0.55);
    final double bottomY = center.dy + (h * 0.45);
    final List<Offset> g = [
      Offset(center.dx, topY),
      Offset(center.dx + side / 2, bottomY),
      Offset(center.dx - side / 2, bottomY),
    ];
    canvas.drawPath(Path()..addPolygon(g, true), paint);
    final double tw = side * 0.45;
    final double th = (math.sqrt(3) / 2) * tw;
    final double tTopY = center.dy - (th * 0.4);
    final double tBottomY = center.dy + (th * 0.3);
    final List<Offset> t = [
      Offset(center.dx, tTopY),
      Offset(center.dx + tw / 2, tBottomY),
      Offset(center.dx - tw / 2, tBottomY),
    ];
    canvas.drawPath(Path()..addPolygon(t, true), paint);
    final Offset leftMid = Offset(
      (g[0].dx + g[2].dx) / 2,
      (g[0].dy + g[2].dy) / 2,
    );
    final Offset rightMid = Offset(
      (g[0].dx + g[1].dx) / 2,
      (g[0].dy + g[1].dy) / 2,
    );
    final Offset bottomMid = Offset(
      (g[1].dx + g[2].dx) / 2,
      (g[1].dy + g[2].dy) / 2,
    );
    canvas.drawLine(t[0], g[0], paint);
    canvas.drawLine(t[1], g[1], paint);
    canvas.drawLine(t[2], g[2], paint);
    canvas.drawLine(t[0], rightMid, paint);
    canvas.drawLine(t[0], leftMid, paint);
    canvas.drawLine(t[1], leftMid, paint);
    canvas.drawLine(t[1], bottomMid, paint);
    canvas.drawLine(t[2], rightMid, paint);
    canvas.drawLine(t[2], bottomMid, paint);
    final Offset bottomQuarterLeft = Offset(center.dx - side * 0.2, bottomY);
    final Offset bottomQuarterRight = Offset(center.dx + side * 0.2, bottomY);
    canvas.drawLine(t[1], bottomQuarterRight, paint);
    canvas.drawLine(t[2], bottomQuarterLeft, paint);
    canvas.drawLine(bottomMid, t[1], paint);
    canvas.drawLine(bottomMid, t[2], paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 19. SHIELD
class MinimalShieldPainter extends MinimalShapePainter {
  MinimalShieldPainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final center = Offset(size.width / 2, size.height / 2);
    final double w = size.width * 0.8;
    final double h = size.height * 0.8;
    List<double> scales = [1.0, 0.82, 0.64, 0.46];
    List<List<Offset>> layers = [];
    for (var s in scales) {
      double curW = w * s;
      double curH = h * s;
      double topY = center.dy - curH * 0.45;
      double midY = center.dy - curH * 0.1;
      double bottomY = center.dy + curH * 0.55;
      List<Offset> points = [
        Offset(center.dx - curW * 0.25, topY),
        Offset(center.dx + curW * 0.25, topY),
        Offset(center.dx + curW * 0.5, midY),
        Offset(center.dx + curW * 0.35, bottomY - curH * 0.3),
        Offset(center.dx, bottomY),
        Offset(center.dx - curW * 0.35, bottomY - curH * 0.3),
        Offset(center.dx - curW * 0.5, midY),
      ];
      layers.add(points);
      canvas.drawPath(Path()..addPolygon(points, true), paint);
    }
    for (int i = 0; i < layers.length - 1; i++) {
      for (int j = 0; j < 7; j++) {
        canvas.drawLine(layers[i][j], layers[i + 1][j], paint);
      }
    }
    final innerLayer = layers.last;
    for (int j = 0; j < 7; j++) {
      canvas.drawLine(innerLayer[j], center, paint);
    }
  }
}

// 20. LOZENGE
class MinimalLozengePainter extends MinimalShapePainter {
  MinimalLozengePainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final center = Offset(size.width / 2, size.height / 2);
    final double h = size.height * 0.95;
    final double w = h * 0.55;
    List<double> scales = [1.0, 0.78, 0.56, 0.34];
    List<List<Offset>> layers = [];
    for (var s in scales) {
      double sw = w * s;
      double sh = h * s;
      List<Offset> points = [
        Offset(center.dx, center.dy - sh / 2),
        Offset(center.dx + sw / 2, center.dy),
        Offset(center.dx, center.dy + sh / 2),
        Offset(center.dx - sw / 2, center.dy),
      ];
      layers.add(points);
      canvas.drawPath(Path()..addPolygon(points, true), paint);
    }
    final innerLayer = layers.last;
    for (int j = 0; j < 4; j++) {
      canvas.drawLine(innerLayer[j], center, paint);
    }
    for (int i = 0; i < layers.length - 1; i++) {
      for (int j = 0; j < 4; j++) {
        canvas.drawLine(layers[i][j], layers[i + 1][j], paint);
      }
    }
  }
}

// 21. KITE (Step/Nested style based on image_491451.png)
class MinimalKitePainter extends MinimalShapePainter {
  MinimalKitePainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final center = Offset(size.width / 2, size.height / 2);
    final double w = size.width * 0.7;
    final double h = size.height * 0.9;
    List<double> scales = [1.0, 0.75, 0.50, 0.25];
    List<List<Offset>> layers = [];
    for (var s in scales) {
      double curW = w * s;
      double curH = h * s;
      double topY = center.dy - (curH * 0.35);
      double shoulderY = center.dy - (curH * 0.05);
      double bottomY = center.dy + (curH * 0.65);
      List<Offset> points = [
        Offset(center.dx, topY),
        Offset(center.dx + curW / 2, shoulderY),
        Offset(center.dx, bottomY),
        Offset(center.dx - curW / 2, shoulderY),
      ];
      layers.add(points);
      canvas.drawPath(Path()..addPolygon(points, true), paint);
    }
    for (int i = 0; i < layers.length - 1; i++) {
      for (int j = 0; j < 4; j++) {
        canvas.drawLine(layers[i][j], layers[i + 1][j], paint);
      }
    }
    final innerLayer = layers.last;
    for (int j = 0; j < 4; j++) {
      canvas.drawLine(innerLayer[j], center, paint);
    }
  }
}

// 22. PORTUGUESE
class MinimalPortuguesePainter extends MinimalShapePainter {
  MinimalPortuguesePainter({super.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width * 0.45;
    const int segments = 16;
    final double rTable = radius * 0.22;
    final double rInner = radius * 0.50;
    final double rMiddle = radius * 0.78;
    final double rGirdle = radius;
    List<Offset> tablePoints = [];
    List<Offset> innerPoints = [];
    List<Offset> middlePoints = [];
    List<Offset> girdlePoints = [];
    for (int i = 0; i < segments; i++) {
      double angle = (i * 360 / segments) * math.pi / 180;
      double offsetAngle = ((i + 0.5) * 360 / segments) * math.pi / 180;
      tablePoints.add(
        Offset(
          center.dx + rTable * math.cos(angle),
          center.dy + rTable * math.sin(angle),
        ),
      );
      innerPoints.add(
        Offset(
          center.dx + rInner * math.cos(offsetAngle),
          center.dy + rInner * math.sin(offsetAngle),
        ),
      );
      middlePoints.add(
        Offset(
          center.dx + rMiddle * math.cos(angle),
          center.dy + rMiddle * math.sin(angle),
        ),
      );
      girdlePoints.add(
        Offset(
          center.dx + rGirdle * math.cos(offsetAngle),
          center.dy + rGirdle * math.sin(offsetAngle),
        ),
      );
    }
    for (int i = 0; i < segments; i++) {
      final next = (i + 1) % segments;
      canvas.drawLine(tablePoints[i], tablePoints[next], paint);
      canvas.drawLine(tablePoints[i], innerPoints[i], paint);
      canvas.drawLine(tablePoints[next], innerPoints[i], paint);
      canvas.drawLine(innerPoints[i], middlePoints[i], paint);
      canvas.drawLine(innerPoints[i], middlePoints[next], paint);
      canvas.drawLine(middlePoints[next], girdlePoints[i], paint);
      canvas.drawLine(middlePoints[next], girdlePoints[next], paint);
      canvas.drawLine(girdlePoints[i], girdlePoints[next], paint);
      canvas.drawLine(innerPoints[i], middlePoints[i], paint);
      canvas.drawLine(middlePoints[i], girdlePoints[i], paint);
      canvas.drawLine(
        middlePoints[i],
        girdlePoints[(i + segments - 1) % segments],
        paint,
      );
    }
    canvas.drawCircle(center, radius, paint);
  }
}
