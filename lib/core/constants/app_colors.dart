import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Bank of Anthos / Google Cloud aesthetic
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryLight = Color(0xFF1E293B); // Slate 800
  static const Color primaryAccent = Color(0xFF0F2027);

  static const Color anthosBlue = Color(0xFF2563EB); // Vibrant Blue
  static const Color anthosCyan = Color(0xFF06B6D4); // Tailwind Cyan 500
  static const Color anthosEmerald = Color(0xFF10B981); // Emerald 500
  static const Color anthosAmber = Color(0xFFF59E0B); // Amber 500
  static const Color anthosRed = Color(0xFFEF4444); // Rose/Red 500

  // Surfaces & Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);

  static const Color backgroundDark = Color(0xFF0B0F19); // Rich Obsidian
  static const Color surfaceDark = Color(0xFF131C2E); // Deep Slate Navy
  static const Color surfaceVariantDark = Color(0xFF1E293B); // Slate 800

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF243447);

  // Gradients
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F2027),
      Color(0xFF203A43),
      Color(0xFF2C5364),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A73E8),
      Color(0xFF00C49F),
    ],
  );
}
