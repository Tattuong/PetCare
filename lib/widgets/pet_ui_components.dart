import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';
import 'home_style.dart';

/// Hero illustration for onboarding — person + dog, flat pastel style.
class PetHeroIllustration extends StatelessWidget {
  final double height;

  const PetHeroIllustration({super.key, this.height = 260});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _HeroPainter(),
        child: const Align(
          alignment: Alignment(0.15, 0.1),
          child: Icon(Icons.pets_rounded, size: 72, color: Color(0xFFE8A849)),
        ),
      ),
    );
  }
}

class _HeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.pastelLavender.withValues(alpha: 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.08, size.height * 0.12, size.width * 0.84, size.height * 0.76), const Radius.circular(40)),
      bg,
    );

    final person = Paint()..color = const Color(0xFF9B8FD9);
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.38), size.width * 0.09, person);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(size.width * 0.38, size.height * 0.62), width: size.width * 0.22, height: size.height * 0.28),
        const Radius.circular(24),
      ),
      person,
    );

    final dog = Paint()..color = const Color(0xFFE8A849);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.62, size.height * 0.68), width: size.width * 0.28, height: size.height * 0.18), dog);
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.48), size.width * 0.08, dog);

    final ground = Paint()..color = AppColors.pastelOrange.withValues(alpha: 0.45);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.1, size.height * 0.78, size.width * 0.8, size.height * 0.12), const Radius.circular(20)),
      ground,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.radius = HomeStyle.cardRadius,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? Colors.white) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: HomeStyle.softShadow(),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(radius), child: content),
    );
  }
}

class QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(22),
              boxShadow: HomeStyle.floatShadow(color),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PetShowcaseCard extends StatelessWidget {
  final String name;
  final String ageLabel;
  final String gender;
  final String? photoPath;
  final String species;
  final Color bgColor;
  final VoidCallback onTap;

  const PetShowcaseCard({
    super.key,
    required this.name,
    required this.ageLabel,
    required this.gender,
    this.photoPath,
    required this.species,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final genderIcon = gender == 'female' ? Icons.female_rounded : gender == 'male' ? Icons.male_rounded : Icons.pets_rounded;
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();

    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      radius: 24,
      child: SizedBox(
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasPhoto)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(File(photoPath!), fit: BoxFit.cover),
                    )
                  else
                    Center(
                      child: Icon(
                        species == 'cat' ? Icons.pets_rounded : Icons.pets,
                        size: 64,
                        color: bgColor.withValues(alpha: 0.9),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(genderIcon, size: 16, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(name, style: HomeStyle.sectionTitle.copyWith(fontSize: 16)),
            const SizedBox(height: 2),
            Text(ageLabel, style: HomeStyle.ageLabel()),
          ],
        ),
      ),
    );
  }
}

class PurpleHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const PurpleHeaderBar({super.key, required this.title, this.onBack, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.reminderGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: onBack ?? () => Navigator.maybePop(context),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              if (actions != null)
                SizedBox(width: 48, child: Row(mainAxisSize: MainAxisSize.min, children: actions!))
              else
                const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}
