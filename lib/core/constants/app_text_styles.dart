import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Text styles for the app
class AppTextStyles {
  AppTextStyles._();

  // Display text styles
  static TextStyle get displayLarge => TextStyle(
        fontSize: 57.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25.sp,
        height: 1.12,
      );

  static TextStyle get displayMedium => TextStyle(
        fontSize: 45.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.sp,
        height: 1.16,
      );

  static TextStyle get displaySmall => TextStyle(
        fontSize: 36.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.sp,
        height: 1.22,
      );

  // Headline text styles
  static TextStyle get headlineLarge => TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.sp,
        height: 1.25,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.sp,
        height: 1.29,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.sp,
        height: 1.33,
      );

  // Title text styles
  static TextStyle get titleLarge => TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.sp,
        height: 1.27,
      );

  static TextStyle get titleMedium => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15.sp,
        height: 1.50,
      );

  static TextStyle get titleSmall => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1.sp,
        height: 1.43,
      );

  // Label text styles
  static TextStyle get labelLarge => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1.sp,
        height: 1.43,
      );

  static TextStyle get labelMedium => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5.sp,
        height: 1.33,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5.sp,
        height: 1.45,
      );

  // Body text styles
  static TextStyle get bodyLarge => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15.sp,
        height: 1.50,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25.sp,
        height: 1.43,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4.sp,
        height: 1.33,
      );

  // Custom app-specific text styles
  static TextStyle get logoText => TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2.sp,
        height: 1.2,
      );

  static TextStyle get buttonText => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5.sp,
        height: 1.25,
      );

  static TextStyle get inputText => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15.sp,
        height: 1.50,
      );

  static TextStyle get hintText => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15.sp,
        height: 1.50,
      );

  static TextStyle get errorText => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4.sp,
        height: 1.33,
      );

  static TextStyle get captionText => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4.sp,
        height: 1.33,
      );

  static TextStyle get overlineText => TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5.sp,
        height: 1.6,
      );
}
