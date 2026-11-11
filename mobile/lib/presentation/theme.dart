import 'package:flutter/material.dart';

abstract final class AppColors {
  static const trafficFree = Color(0xFF34C759);
  static const trafficSlow = Color(0xFFFF9500);
  static const trafficBlocked = Color(0xFFFF3B30);
  static const trafficUnknown = Color(0xFF8E8E93);
  static const primary = Color(0xFF000000);
  static const surface = Color(0xFFF2F2F7);
  static const border = Color(0xFFE5E5EA);
  static const secondary = Color(0xFF8E8E93);
}

ThemeData buildTheme() => ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.surface,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        centerTitle: false,
      ),
    );
