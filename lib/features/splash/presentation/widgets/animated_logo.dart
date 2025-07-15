import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5), // Start from above the screen
      end: Offset.zero, // End at center
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _rotationController.repeat();
      _pulseController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _pulseAnimation, _slideAnimation]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Transform.scale(
            scale: _pulseAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 2 * math.pi,
              child: SizedBox(
                width: 200, // Larger size
                height: 200, // Larger size
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to checkroom icon if logo.png is not found
                                          return Icon(
                      Icons.checkroom_outlined,
                      size: 100,
                      color: const Color(0xFF461700),
                    );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Alternative logo widget using custom painter for more complex designs
class CustomAnimatedLogo extends StatefulWidget {
  const CustomAnimatedLogo({super.key});

  @override
  State<CustomAnimatedLogo> createState() => _CustomAnimatedLogoState();
}

class _CustomAnimatedLogoState extends State<CustomAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(120, 120),
          painter: LogoPainter(_animation.value, Theme.of(context)),
        );
      },
    );
  }
}

class LogoPainter extends CustomPainter {
  final double animationValue;
  final ThemeData theme;

  LogoPainter(this.animationValue, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw animated circles
    for (int i = 0; i < 3; i++) {
      final paint = Paint()
        ..color = [
          theme.colorScheme.primary,
          theme.colorScheme.secondary,
          theme.colorScheme.tertiary,
        ][i].withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final animatedRadius = radius * (0.3 + 0.3 * i) * 
          (1 + 0.2 * (animationValue + i * 0.33) % 1);

      canvas.drawCircle(center, animatedRadius, paint);
    }

    // Draw center icon
    final iconPaint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.fill;

    final iconPath = Path();
    // Simple dress/clothing icon path
    iconPath.moveTo(center.dx - 15, center.dy - 20);
    iconPath.lineTo(center.dx + 15, center.dy - 20);
    iconPath.lineTo(center.dx + 20, center.dy + 20);
    iconPath.lineTo(center.dx - 20, center.dy + 20);
    iconPath.close();

    canvas.drawPath(iconPath, iconPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
