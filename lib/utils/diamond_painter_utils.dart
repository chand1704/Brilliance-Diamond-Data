import 'package:flutter/material.dart';

import '../diamond_shapes.dart';

class DiamondPainterUtils {
  static CustomPainter? getPainterForShapeName(String name, bool isActive) {
    if (name.isEmpty) return null;
    final Color shapeColor = isActive ? Colors.teal : const Color(0xFF616161);
    final String upperName = name.toUpperCase();
    if (upperName.contains("ROUND")) {
      return MinimalRoundPainter(color: shapeColor);
    } else if (upperName.contains("PRINCESS")) {
      return MinimalPrincessPainter(color: shapeColor);
    } else if (upperName.contains("EMERALD")) {
      return MinimalEmeraldPainter(color: shapeColor);
    } else if (upperName.contains("CUSHION")) {
      return MinimalCushionPainter(color: shapeColor);
    } else if (upperName.contains("RADIANT")) {
      return MinimalRadiantPainter(color: shapeColor);
    } else if (upperName.contains("MARQUISE")) {
      return MinimalMarquisePainter(color: shapeColor);
    } else if (upperName.contains("PEAR")) {
      return MinimalPearPainter(color: shapeColor);
    } else if (upperName.contains("OVAL")) {
      return MinimalOvalPainter(color: shapeColor);
    } else if (upperName.contains("HEART")) {
      return MinimalHeartPainter(color: shapeColor);
    } else if (upperName.contains("ASSCHER")) {
      return MinimalAsscherPainter(color: shapeColor);
    } else if (upperName.contains("ROSE")) {
      return MinimalRosePainter(color: shapeColor);
    } else if (upperName.contains("BAGUETTE")) {
      return MinimalBaguettePainter(color: shapeColor);
    } else if (upperName.contains("HALF MOON")) {
      return MinimalHalfMoonPainter(color: shapeColor);
    } else if (upperName.contains("TRAPEZOID")) {
      return MinimalTrapezoidPainter(color: shapeColor);
    } else if (upperName.contains("PENTAGONAL")) {
      return MinimalPentagonalPainter(color: shapeColor);
    } else if (upperName.contains("HEXAGON")) {
      return MinimalHexagonalPainter(color: shapeColor);
    } else if (upperName.contains("TRIANGULAR")) {
      return MinimalTriangularPainter(color: shapeColor);
    } else if (upperName.contains("TRILLIANT") ||
        upperName.contains("TRILLION")) {
      return MinimalTrilliantPainter(color: shapeColor);
    } else if (upperName.contains("SHIELD")) {
      return MinimalShieldPainter(color: shapeColor);
    } else if (upperName.contains("LOZENGE")) {
      return MinimalLozengePainter(color: shapeColor);
    } else if (upperName.contains("KITE")) {
      return MinimalKitePainter(color: shapeColor);
    } else if (upperName.contains("PORTUGUESE")) {
      return MinimalPortuguesePainter(color: shapeColor);
    }
    return null;
  }
}
