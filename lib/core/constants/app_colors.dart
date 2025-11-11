import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryGold = Color(0xFFC9A961);
  static const Color primaryGoldDark = Color(0xFFB89851);
  static const Color primaryDark = Color(0xFF0F0F0F);

  // Background Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color backgroundCard = Color(0xFF1A1A1A);
  static const Color backgroundCardDark = Color(0xFF0F0F0F);

  // Text Colors
  static const Color textPrimary = Color(0xFFE8E8E8);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textDark = Color(0xFF0F0F0F);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Border Colors
  static Color borderGold = primaryGold.withValues(alpha: 0.3);
  static Color borderGoldFull = primaryGold.withValues(alpha: 1.0);
}


