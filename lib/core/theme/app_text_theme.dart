import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../extensions/typography_extension.dart';

class AppTextTheme {
  static TextTheme get lightTextTheme {
    return TextTheme(
      // Display text (large decorative headings)
      displayLarge: poppins.w700.fs56.textColor(AppColors.onSurface),
      displayMedium: poppins.w700.fs48.textColor(AppColors.onSurface),
      displaySmall: poppins.w700.fs36.textColor(AppColors.onSurface),

      // Headlines (prominent titles)
      headlineLarge: poppins.w600.fs32.textColor(AppColors.onSurface),
      headlineMedium: poppins.w600.fs28.textColor(AppColors.onSurface),
      headlineSmall: poppins.w600.fs24.textColor(AppColors.onSurface),

      // Titles (app bars, tiles, cards)
      titleLarge: poppins.w600.fs22.textColor(AppColors.onSurface),
      titleMedium: poppins.w600.fs16.textColor(AppColors.onSurface),
      titleSmall: poppins.w500.fs14.textColor(AppColors.onSurface),

      // Body text (paragraphs, normal text)
      bodyLarge: poppins.w400.fs16.textColor(AppColors.onSurface),
      bodyMedium: poppins.w400.fs14.textColor(AppColors.onSurface),
      bodySmall: poppins.w400.fs12.textColor(AppColors.onSurface),

      // Labels (buttons, inputs, badges)
      labelLarge: poppins.w500.fs16.textColor(AppColors.onSurface),
      labelMedium: poppins.w500.fs12.textColor(AppColors.onSurface),
      labelSmall: poppins.w500.fs11.textColor(AppColors.onSurface),
    );
  }

  static TextTheme get darkTextTheme {
    return TextTheme(
      // Display text (large decorative headings)
      displayLarge: poppins.w700.fs56.textColor(AppColors.darkOnSurface),
      displayMedium: poppins.w700.fs48.textColor(AppColors.darkOnSurface),
      displaySmall: poppins.w700.fs36.textColor(AppColors.darkOnSurface),

      // Headlines (prominent titles)
      headlineLarge: poppins.w600.fs32.textColor(AppColors.darkOnSurface),
      headlineMedium: poppins.w600.fs28.textColor(AppColors.darkOnSurface),
      headlineSmall: poppins.w600.fs24.textColor(AppColors.darkOnSurface),

      // Titles (app bars, tiles, cards)
      titleLarge: poppins.w600.fs22.textColor(AppColors.darkOnSurface),
      titleMedium: poppins.w600.fs16.textColor(AppColors.darkOnSurface),
      titleSmall: poppins.w500.fs14.textColor(AppColors.darkOnSurface),

      // Body text (paragraphs, normal text)
      bodyLarge: poppins.w400.fs16.textColor(AppColors.darkOnSurface),
      bodyMedium: poppins.w400.fs14.textColor(AppColors.darkOnSurface),
      bodySmall: poppins.w400.fs12.textColor(AppColors.darkOnSurface),

      // Labels (buttons, inputs, badges)
      labelLarge: poppins.w500.fs16.textColor(AppColors.darkOnSurface),
      labelMedium: poppins.w500.fs12.textColor(AppColors.darkOnSurface),
      labelSmall: poppins.w500.fs11.textColor(AppColors.darkOnSurface),
    );
  }
}
