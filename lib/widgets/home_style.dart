import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';

class HomeStyle {
  HomeStyle._();

  static const Color pageBg = AppColors.background;
  static const Color iconInk = Color(0xFF4A4560);

  static const double cardRadius = 28;
  static const double chipRadius = 20;
  static const double buttonRadius = 28;

  static final TextStyle displayGreeting = GoogleFonts.nunito(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.15,
  );

  static final TextStyle displaySubtitle = GoogleFonts.nunito(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static final TextStyle sectionTitle = GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static final TextStyle tabLabelActive = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryDark,
  );

  static final TextStyle tabLabelInactive = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static final TextStyle gridLabelStyle = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static final TextStyle ageLabelStyle = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  static final TextStyle badgeTextNormal = GoogleFonts.nunito(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
  );

  static final TextStyle badgeTextHighlight = GoogleFonts.nunito(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryDark,
  );

  static TextStyle tabLabel({required bool active}) => active ? tabLabelActive : tabLabelInactive;
  static TextStyle gridLabel() => gridLabelStyle;
  static TextStyle ageLabel() => ageLabelStyle;
  static TextStyle badgeText({bool highlight = false}) => highlight ? badgeTextHighlight : badgeTextNormal;

  static List<BoxShadow> softShadow([Color? c]) => [
        BoxShadow(
          color: (c ?? AppColors.primaryDark).withValues(alpha: 0.10),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.8),
          blurRadius: 0,
          offset: const Offset(-2, -2),
        ),
      ];

  static List<BoxShadow> floatShadow(Color c) => [
        BoxShadow(color: c.withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 8)),
      ];

  static BoxDecoration softCard({Color? color, double radius = cardRadius}) => BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: softShadow(),
      );

  static BoxDecoration tabDecoration({required bool active}) => BoxDecoration(
        color: active ? Colors.white : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(chipRadius),
        border: Border.all(color: active ? AppColors.pastelLavender : Colors.transparent, width: 1.5),
        boxShadow: active ? softShadow() : null,
      );
}

class PetsNavIcon extends StatelessWidget {
  final Color color;
  final double size;

  const PetsNavIcon({super.key, required this.color, this.size = 24});

  @override
  Widget build(BuildContext context) => Icon(Icons.pets_rounded, size: size, color: color);
}
