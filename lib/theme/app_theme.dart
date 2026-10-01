import 'package:flutter/material.dart';

/// Design tokens from design/DESIGN.md (palette P28 "sea glass").
class AppColors {
  static const background = Color(0xFFF4FCFB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEAF6F4);
  static const accent = Color(0xFF14B8A6);
  static const accentFill = Color(0xFF0E8376);
  static const accentPressed = Color(0xFF0B6E63);
  static const accentTint = Color(0xFFE3F7F4);
  static const support = Color(0xFFDDA8F0);
  static const supportTint = Color(0xFFF3E6FA);
  static const textPrimary = Color(0xFF0C1F1D);
  static const textSecondary = Color(0xFF4A615E);
  static const textTertiary = Color(0xFF7C918E);
  static const border = Color(0xFFD7E8E5);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFD97706);
  static const warningTint = Color(0xFFFEF3C7);
  static const danger = Color(0xFFDC2626);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD5F3EE), Color(0xFFF1E4F8)],
  );
}

class AppRadius {
  static const card = 20.0;
  static const control = 14.0;
  static const input = 12.0;
}

const kSans = 'Nunito Sans';
const kSerif = 'Lora';

class AppText {
  static const display = TextStyle(
      fontFamily: kSerif,
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      height: 1.15,
      color: AppColors.textPrimary);
  static const headline = TextStyle(
      fontFamily: kSerif,
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      height: 1.2,
      color: AppColors.textPrimary);
  static const title =
      TextStyle(fontFamily: kSans, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const body = TextStyle(
      fontFamily: kSans, fontSize: 16, fontWeight: FontWeight.w400, height: 1.4, color: AppColors.textPrimary);
  static const bodyMuted = TextStyle(fontFamily: kSans, fontSize: 15, height: 1.45, color: AppColors.textSecondary);
  static const label =
      TextStyle(fontFamily: kSans, fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const caption =
      TextStyle(fontFamily: kSans, fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
  static const overline = TextStyle(
      fontFamily: kSans, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.textTertiary);
}

const kCardShadow = [
  BoxShadow(color: Color(0x0A0C1F1D), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F0C1F1D), blurRadius: 24, offset: Offset(0, 8)),
];

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: kSans,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accentFill,
      primary: AppColors.accentFill,
      secondary: AppColors.support,
      surface: AppColors.surface,
    ),
  );
  return base.copyWith(
    textTheme:
        base.textTheme.apply(fontFamily: kSans, bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.accentFill : AppColors.border),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}
