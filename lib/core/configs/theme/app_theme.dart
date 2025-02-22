import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:perceptron/core/configs/theme/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.background,
        onSecondary: AppColors.background,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.background),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.background),
        bodyLarge: GoogleFonts.plusJakartaSans(
            fontSize: 16, color: AppColors.background),
        bodyMedium: GoogleFonts.plusJakartaSans(
            fontSize: 14, color: AppColors.background),
      ),
    );
  }
}
