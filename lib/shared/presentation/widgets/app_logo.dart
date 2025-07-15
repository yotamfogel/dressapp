import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showBackground;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showBackground = true,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoWidget = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to checkroom icon if logo.png is not found
        return Icon(
          Icons.checkroom,
          size: size * 0.5,
          color: Colors.white,
        );
      },
    );

    if (showBackground) {
      return Container(
        width: size,
        height: size,
        margin: margin ?? const EdgeInsets.only(bottom: 32),
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFEFAD4), // Cream
              const Color(0xFFFFFFFF), // White
            ],
          ),
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          child: logoWidget,
        ),
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 32),
      child: logoWidget,
    );
  }
} 