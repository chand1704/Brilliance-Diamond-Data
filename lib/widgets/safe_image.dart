import 'package:flutter/material.dart';

import '../diamond_shapes.dart';
import '../model/gmss_stone_model.dart';

class SafeImage extends StatelessWidget {
  final String url;
  final double size;
  final GmssStone stone;
  const SafeImage({
    super.key,
    required this.url,
    required this.size,
    required this.stone,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty || url == "null" || !url.startsWith('http')) {
      return _buildShapePlaceholder();
    }
    return Image.network(
      url,
      fit: BoxFit.contain,
      cacheWidth: 300,
      cacheHeight: 300,
      filterQuality: FilterQuality.low,
      errorBuilder: (context, error, stackTrace) {
        return _buildShapePlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.teal.withOpacity(0.1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShapePlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: CustomPaint(
          size: Size(size * 0.7, size * 0.7),
          painter: _getShapePainter(stone),
        ),
      ),
    );
  }

  CustomPainter _getShapePainter(GmssStone stone) {
    final String shape = stone.shapeStr.toUpperCase();
    if (shape.contains("ROUND")) {
      return MinimalRoundPainter();
    } else if (shape.contains("PRINCESS")) {
      return MinimalPrincessPainter();
    } else if (shape.contains("EMERALD")) {
      return MinimalEmeraldPainter();
    } else if (shape.contains("CUSHION")) {
      return MinimalCushionPainter();
    } else if (shape.contains("RADIANT")) {
      return MinimalRadiantPainter();
    } else if (shape.contains("MARQUISE")) {
      return MinimalMarquisePainter();
    } else if (shape.contains("PEAR")) {
      return MinimalPearPainter();
    } else if (shape.contains("OVAL")) {
      return MinimalOvalPainter();
    } else if (shape.contains("HEART")) {
      return MinimalHeartPainter();
    } else if (shape.contains("ASSCHER")) {
      return MinimalAsscherPainter();
    }
    return MinimalRoundPainter();
  }
}
