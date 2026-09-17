import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/services/pet_photo_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/activity_log.dart';
import '../../models/pet.dart';
import '../../providers/activity_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/shop_provider.dart';
import '../../models/app_theme_preset.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/home_style.dart';
import '../../widgets/pet_ui_components.dart';
import '../feeding/feeding_screen.dart';
import '../grooming/grooming_screen.dart';
import '../health/health_screen.dart';
import '../pet_profile/pet_profile_screen.dart';
import '../settings/settings_screen.dart';
import '../vaccine/vaccine_screen.dart';
import '../shop/shop_screen.dart';
import '../statistics/statistics_screen.dart';
import '../tips/tips_screen.dart';
import '../main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _openScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final vi = AppStrings.languageCodeOf(context) == 'vi';
    final pet = context.select<PetProvider, Pet?>((p) => p.activePet);

    if (pet == null) {
      return ThemedPageBackground(
        child: Center(child: _EmptyPetPrompt(onAdd: () => _showAddPetDialog(context))),
      );
    }

    final pets = context.select<PetProvider, List<Pet>>((p) => p.pets);
    final canAdd = context.select<ShopProvider, bool>((s) => s.canAddMorePets(pets.length));
    final activity = context.read<ActivityProvider>();
    final reminder = _nextReminder(activity, pet.id, vi);

    return ThemedPageBackground(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _HomeHeroSection(
              pet: pet,
              onMenu: () => _openMenuSheet(context),
              onProfile: () => _openScreen(PetProfileScreen(pet: pet)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  QuickActionTile(
                    label: AppStrings.t(context, 'health'),
                    icon: Icons.medication_rounded,
                    color: AppColors.quickActionColors[0],
                    onTap: () => _openScreen(const HealthScreen()),
                  ),
                  const SizedBox(width: 10),
                  QuickActionTile(
                    label: AppStrings.t(context, 'grooming'),
                    icon: Icons.content_cut_rounded,
                    color: AppColors.quickActionColors[1],
                    onTap: () => _openScreen(const GroomingScreen()),
                  ),
                  const SizedBox(width: 10),
                  QuickActionTile(
                    label: AppStrings.t(context, 'consult'),
                    icon: Icons.pets_rounded,
                    color: AppColors.quickActionColors[2],
                    onTap: () => _openScreen(const HealthScreen()),
                  ),
                  const SizedBox(width: 10),
                  QuickActionTile(
                    label: AppStrings.t(context, 'nutrition'),
                    icon: Icons.restaurant_rounded,
                    color: AppColors.quickActionColors[3],
                    onTap: () => _openScreen(const FeedingScreen()),
                  ),
                ],
              ),
            ),
          ),
          if (reminder != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _ReminderBanner(
                  title: reminder.title,
                  subtitle: reminder.subtitle,
                  onTap: () => _openScreen(const VaccineScreen()),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Expanded(child: Text(AppStrings.t(context, 'myPets'), style: HomeStyle.sectionTitle)),
                  Material(
                    color: AppColors.pastelOrangeDark,
                    shape: const CircleBorder(),
                    elevation: 4,
                    shadowColor: AppColors.pastelOrangeDark.withValues(alpha: 0.4),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _showAddPetDialog(context),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(canAdd ? Icons.add_rounded : Icons.lock_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 210,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: pets.length + (canAdd ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, i) {
                  if (canAdd && i == pets.length) {
                    return _AddPetCard(onTap: () => _showAddPetDialog(context));
                  }
                  final p = pets[i];
                  final colors = [AppColors.pastelOrange, AppColors.pastelLavender, AppColors.pastelPink, AppColors.pastelGreen];
                  return PetShowcaseCard(
                    name: p.name,
                    ageLabel: p.ageLabel(vi: vi),
                    gender: p.gender,
                    photoPath: p.photoPath,
                    species: p.species,
                    bgColor: colors[i % colors.length],
                    onTap: () {
                      context.read<PetProvider>().selectPet(p.id);
                      _openScreen(PetProfileScreen(pet: p));
                    },
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _openMenuSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(4)),
              ),
              ListTile(
                leading: _menuIcon(Icons.storefront_outlined, AppColors.pastelLavender),
                title: Text(AppStrings.t(context, 'navShop'), style: HomeStyle.gridLabel()),
                onTap: () {
                  Navigator.pop(ctx);
                  MainShell.instance?.openShop();
                },
              ),
              ListTile(
                leading: _menuIcon(Icons.lightbulb_outline_rounded, AppColors.pastelYellow),
                title: Text(AppStrings.t(context, 'navTips'), style: HomeStyle.gridLabel()),
                onTap: () {
                  Navigator.pop(ctx);
                  _openScreen(const TipsScreen());
                },
              ),
              ListTile(
                leading: _menuIcon(Icons.insights_rounded, AppColors.pastelOrange),
                title: Text(AppStrings.t(context, 'navLogs'), style: HomeStyle.gridLabel()),
                onTap: () {
                  Navigator.pop(ctx);
                  _openScreen(const StatisticsScreen());
                },
              ),
              ListTile(
                leading: _menuIcon(Icons.settings_outlined, AppColors.pastelPink),
                title: Text(AppStrings.t(context, 'navSettings'), style: HomeStyle.gridLabel()),
                onTap: () {
                  Navigator.pop(ctx);
                  _openScreen(const SettingsScreen());
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuIcon(IconData icon, Color bg) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bg.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: AppColors.primaryDark, size: 20),
    );
  }

  ({String title, String subtitle})? _nextReminder(ActivityProvider activity, String petId, bool vi) {
    final dueVax = activity.vaccineSchedule(petId).where((v) => !v.completed).firstOrNull;
    if (dueVax != null) {
      return (
        title: AppStrings.tCode(vi ? 'vi' : 'en', 'reminderHealthCheckup'),
        subtitle: '${dueVax.name} · ${AppStrings.tCode(vi ? 'vi' : 'en', 'vaccineDue')}',
      );
    }
    final grooming = activity.lastLog(petId, ActivityType.grooming);
    final nextDueStr = grooming?.data['nextDue'] as String?;
    if (nextDueStr != null) {
      final dt = DateTime.tryParse(nextDueStr);
      if (dt != null) {
        return (
          title: AppStrings.tCode(vi ? 'vi' : 'en', 'nextGrooming'),
          subtitle: DateFormat('HH:mm · dd MMM, yyyy').format(dt),
        );
      }
    }
    return null;
  }

  Future<void> _showAddPetDialog(BuildContext context) async {
    final shop = context.read<ShopProvider>();
    final petProvider = context.read<PetProvider>();
    if (!shop.canAddMorePets(petProvider.pets.length)) {
      final openShop = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(AppStrings.t(context, 'addPet')),
          content: Text(AppStrings.t(context, 'multiPetLocked')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(context, 'navShop'))),
          ],
        ),
      );
      if (openShop == true && context.mounted) MainShell.instance?.openShop();
      return;
    }

    final result = await showDialog<PetFormResult>(context: context, builder: (ctx) => const PetFormDialog(isEdit: false));
    if (result != null && context.mounted) {
      await petProvider.addPet(
        name: result.name,
        birthDate: result.birthDate,
        species: result.species,
        breed: result.breed,
        furColor: result.furColor,
        gender: result.gender,
        photoPath: result.photoPath,
      );
    }
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}

class _HomeHeroSection extends StatelessWidget {
  final Pet pet;
  final VoidCallback onMenu;
  final VoidCallback onProfile;

  const _HomeHeroSection({required this.pet, required this.onMenu, required this.onProfile});

  @override
  Widget build(BuildContext context) {
    final greeting = AppStrings.t(context, 'homeGreeting', {'name': pet.name});

    return ClipPath(
      clipper: _HeroWaveClipper(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF3EDFF), Color(0xFFFFF8F2), Color(0xFFFAF8FF)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -20,
              child: _HeroBlob(size: 140, color: AppColors.pastelLavender.withValues(alpha: 0.45)),
            ),
            Positioned(
              top: 60,
              left: -40,
              child: _HeroBlob(size: 100, color: AppColors.pastelOrange.withValues(alpha: 0.35)),
            ),
            Positioned(
              bottom: 20,
              right: 40,
              child: _HeroBlob(size: 60, color: AppColors.pastelGreen.withValues(alpha: 0.3)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _SoftIconButton(icon: Icons.menu_rounded, onTap: onMenu),
                      const Spacer(),
                      _PetAvatarButton(pet: pet, onTap: onProfile),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(greeting, style: HomeStyle.displayGreeting),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: HomeStyle.displaySubtitle,
                      children: [
                        TextSpan(text: AppStrings.t(context, 'homeSubtitlePrefix')),
                        TextSpan(
                          text: AppStrings.t(context, 'homeSubtitleHighlight'),
                          style: HomeStyle.displaySubtitle.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _HeroBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _HeroWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height - 28)
      ..quadraticBezierTo(size.width * 0.25, size.height, size.width * 0.5, size.height - 14)
      ..quadraticBezierTo(size.width * 0.75, size.height - 28, size.width, size.height - 18)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SoftIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SoftIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Icon(icon, size: 22, color: AppColors.textPrimary.withValues(alpha: 0.85)),
        ),
      ),
    );
  }
}

class _PetAvatarButton extends StatelessWidget {
  final Pet pet;
  final VoidCallback onTap;

  const _PetAvatarButton({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = pet.photoPath != null && File(pet.photoPath!).existsSync();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.pastelLavender, AppColors.pastelOrange.withValues(alpha: 0.8)],
            ),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.pastelLavender,
            backgroundImage: hasPhoto ? FileImage(File(pet.photoPath!)) : null,
            child: hasPhoto ? null : Icon(Icons.pets_rounded, size: 22, color: AppColors.primaryDark),
          ),
        ),
      ),
    );
  }
}

class _ReminderBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ReminderBanner({required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HomeStyle.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.reminderGradient,
            borderRadius: BorderRadius.circular(HomeStyle.cardRadius),
            boxShadow: HomeStyle.floatShadow(AppColors.pastelPurple),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.notifications_active_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: GoogleFonts.nunito(fontSize: 12, color: Colors.white.withValues(alpha: 0.9))),
                    ],
                  ),
                ),
                Icon(Icons.pets_rounded, size: 40, color: Colors.white.withValues(alpha: 0.35)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- shared form + empty state (unchanged API) ---

class PetFormResult {
  final String name;
  final DateTime birthDate;
  final String species;
  final String breed;
  final String furColor;
  final String gender;
  final String? photoPath;

  const PetFormResult({
    required this.name,
    required this.birthDate,
    this.species = 'dog',
    this.breed = '',
    this.furColor = '',
    this.gender = 'unknown',
    this.photoPath,
  });
}

class PetFormDialog extends StatefulWidget {
  final bool isEdit;
  final Pet? initial;

  const PetFormDialog({super.key, required this.isEdit, this.initial});

  @override
  State<PetFormDialog> createState() => _PetFormDialogState();
}

class _PetFormDialogState extends State<PetFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _breedCtrl;
  late final TextEditingController _furCtrl;
  late DateTime _birthDate;
  late String _species;
  late String _gender;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _breedCtrl = TextEditingController(text: widget.initial?.breed ?? '');
    _furCtrl = TextEditingController(text: widget.initial?.furColor ?? '');
    _birthDate = widget.initial?.birthDate ?? DateTime.now();
    _species = widget.initial?.species ?? 'dog';
    _gender = widget.initial?.gender ?? 'unknown';
    _photoPath = widget.initial?.photoPath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _furCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(
      context,
      PetFormResult(
        name: name,
        birthDate: _birthDate,
        species: _species,
        breed: _breedCtrl.text.trim(),
        furColor: _furCtrl.text.trim(),
        gender: _gender,
        photoPath: _photoPath,
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final path = await PetPhotoService.pickAndSave(context, petId: widget.initial?.id);
    if (path != null && mounted) setState(() => _photoPath = path);
  }

  bool get _hasPhoto => _photoPath != null && File(_photoPath!).existsSync();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(AppStrings.t(context, widget.isEdit ? 'editPet' : 'addPet')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _pickPhoto,
              child: Column(
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.pastelLavender.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.pastelLavender, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: _hasPhoto
                          ? Image.file(File(_photoPath!), fit: BoxFit.cover)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded, size: 32, color: AppColors.primaryDark.withValues(alpha: 0.7)),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.t(context, 'addPhoto'),
                                  style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.t(context, _hasPhoto ? 'changePhoto' : 'tapToAddPhoto'),
                    style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              autofocus: !widget.isEdit,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: AppStrings.t(context, 'petName')),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _species,
              decoration: InputDecoration(labelText: AppStrings.t(context, 'species')),
              items: [
                DropdownMenuItem(value: 'dog', child: Text(AppStrings.t(context, 'speciesDog'))),
                DropdownMenuItem(value: 'cat', child: Text(AppStrings.t(context, 'speciesCat'))),
                DropdownMenuItem(value: 'other', child: Text(AppStrings.t(context, 'speciesOther'))),
              ],
              onChanged: (v) => setState(() => _species = v ?? 'dog'),
            ),
            const SizedBox(height: 8),
            TextField(controller: _breedCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'breed'))),
            const SizedBox(height: 8),
            TextField(controller: _furCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'furColor'))),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(labelText: AppStrings.t(context, 'gender')),
              items: [
                DropdownMenuItem(value: 'male', child: Text(AppStrings.t(context, 'genderMale'))),
                DropdownMenuItem(value: 'female', child: Text(AppStrings.t(context, 'genderFemale'))),
                DropdownMenuItem(value: 'unknown', child: Text(AppStrings.t(context, 'genderUnknown'))),
              ],
              onChanged: (v) => setState(() => _gender = v ?? 'unknown'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppStrings.t(context, 'birthDate')),
              subtitle: Text(_formatDate(_birthDate)),
              trailing: const Icon(Icons.calendar_today_rounded, color: AppColors.primaryDark),
              onTap: () async {
                final picked = await showDatePicker(context: context, initialDate: _birthDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                if (picked != null) setState(() => _birthDate = picked);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.t(context, 'cancel'))),
        FilledButton(onPressed: _save, child: Text(AppStrings.t(context, 'save'))),
      ],
    );
  }
}

class _AddPetCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddPetCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.pastelLavender, width: 2),
            boxShadow: HomeStyle.softShadow(),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.pastelOrangeDark.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, size: 32, color: AppColors.pastelOrangeDark),
              ),
              const SizedBox(height: 12),
              Text(AppStrings.t(context, 'addPet'), style: HomeStyle.gridLabel(), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPetPrompt extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyPetPrompt({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PetHeroIllustration(height: 200),
          const SizedBox(height: 24),
          Text(AppStrings.t(context, 'onboardingHeadline'), style: HomeStyle.displayGreeting, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(AppStrings.t(context, 'onboardingCaption'), textAlign: TextAlign.center, style: HomeStyle.displaySubtitle),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.themePrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HomeStyle.buttonRadius)),
              ),
              onPressed: onAdd,
              child: Text(AppStrings.t(context, 'getStarted')),
            ),
          ),
        ],
      ),
    );
  }
}
