import 'package:flutter/material.dart';

class FruitImage extends StatelessWidget {
  final String type;
  final int level;
  final double size;
  final bool isAscended;

  const FruitImage({
    super.key,
    required this.type,
    required this.level,
    this.size = 100,
  }) : isAscended = level >= 5;

  @override
  Widget build(BuildContext context) {
    // Convert 'Apple' to 'apple' for filename
    final assetName = 'assets/${type.toLowerCase()}_$level.png';

    Widget imageContent = Image.asset(
      assetName,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if image is missing
        return Icon(
          Icons.eco,
          size: size,
          color: _getFallbackColor(level),
        );
      },
    );

    // Apply specific effects for growth stages
    if (level == 3) {
      // Young fruit is slightly translucent/smaller in spirit
      imageContent = Opacity(opacity: 0.8, child: imageContent);
    }

    if (isAscended) {
      // ASCENDED: Add a holy glow
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.6),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          imageContent,
        ],
      );
    }

    return imageContent;
  }

  Color _getFallbackColor(int level) {
    if (level >= 5) return Colors.amber;
    if (level >= 4) return Colors.redAccent;
    if (level >= 3) return Colors.orange;
    return Colors.green;
  }
}
