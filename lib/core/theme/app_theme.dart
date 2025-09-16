import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

// App theme configuration
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        onPrimary: AppColors.lightOnPrimary,
        secondary: AppColors.lightSecondary,
        onSecondary: AppColors.lightOnSecondary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        error: AppColors.lightError,
        onError: AppColors.lightOnError,
      ),

      // Scaffold background
      scaffoldBackgroundColor: AppColors.lightBackground,

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightOnBackground,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.lightOnSurface,
        ),
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.lightOnSurface),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.lightOnSurface),
        displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.lightOnSurface),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.lightOnSurface),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.lightOnSurface),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.lightOnSurface),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.lightOnSurface),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.lightOnSurface),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.lightOnSurface),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.lightOnSurface),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightOnSurface),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.lightOnSurface),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.lightOnSurface),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.lightOnSurface),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.lightOnSurface),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          textStyle: AppTextStyles.buttonText,
          elevation: 2,
          shadowColor: AppColors.lightPrimary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          textStyle: AppTextStyles.buttonText,
          side: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          textStyle: AppTextStyles.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightError, width: 2),
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.grey600),
        hintStyle: AppTextStyles.hintText.copyWith(color: AppColors.grey500),
        errorStyle: AppTextStyles.errorText.copyWith(color: AppColors.lightError),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: AppColors.lightPrimary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: 1,
        space: 1,
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightPrimary,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkOnSecondary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        error: AppColors.darkError,
        onError: AppColors.darkOnError,
      ),

      // Scaffold background
      scaffoldBackgroundColor: AppColors.darkBackground,

      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnBackground,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.darkOnSurface,
        ),
      ),

      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.darkOnSurface),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: AppColors.darkOnSurface),
        displaySmall: AppTextStyles.displaySmall.copyWith(color: AppColors.darkOnSurface),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.darkOnSurface),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: AppColors.darkOnSurface),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.darkOnSurface),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.darkOnSurface),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.darkOnSurface),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.darkOnSurface),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkOnSurface),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkOnSurface),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.darkOnSurface),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.darkOnSurface),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.darkOnSurface),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.darkOnSurface),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          textStyle: AppTextStyles.buttonText,
          elevation: 2,
          shadowColor: AppColors.darkPrimary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          textStyle: AppTextStyles.buttonText,
          side: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          textStyle: AppTextStyles.buttonText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkError, width: 2),
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.grey400),
        hintStyle: AppTextStyles.hintText.copyWith(color: AppColors.grey500),
        errorStyle: AppTextStyles.errorText.copyWith(color: AppColors.darkError),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: AppColors.grey700,
        thickness: 1,
        space: 1,
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkPrimary,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
