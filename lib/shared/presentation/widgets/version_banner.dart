import 'package:flutter/material.dart';

class VersionBanner extends StatelessWidget {
  static const String version = '1.0.0+1'; // Update this after every tweak

  const VersionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'v$version',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF461700),
            fontWeight: FontWeight.bold,
            fontFamily: 'Segoe UI',
          ),
        ),
      ),
    );
  }
} 