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
    String optimizedUrl = url.trim();
    if (optimizedUrl.isEmpty ||
        optimizedUrl == "null" ||
        !optimizedUrl.startsWith('http')) {
      return _buildShapePlaceholder();
    }

    return Container(
      color: Colors.grey.shade50, // Subtle background to prevent blank white look
      child: Image.network(
        optimizedUrl,
        fit: BoxFit.contain,
        cacheWidth: 300,
        cacheHeight: 300,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildShapePlaceholder(),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Shimmer-like background
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade50,
                    Colors.grey.shade200,
                    Colors.grey.shade50,
                  ],
                  stops: [
                    0.0,
                    value,
                    1.0,
                  ],
                ),
              ),
            );
          },
        ),
        _buildShapePlaceholder(),
      ],
    );
  }

  Widget _buildShapePlaceholder() {
    return Center(
      child: Opacity(
        opacity: 0.5,
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
