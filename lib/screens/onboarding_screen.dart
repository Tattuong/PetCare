import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/pet_provider.dart';
import '../screens/home/home_screen.dart';
import '../widgets/home_style.dart';
import '../widgets/pet_ui_components.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  DateTime _birthDate = DateTime.now();
  String _species = 'dog';
  bool _showForm = false;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pcn_onboarding_seen', true);

    if (_nameCtrl.text.trim().isNotEmpty) {
      await context.read<PetProvider>().addPet(
            name: _nameCtrl.text.trim(),
            birthDate: _birthDate,
            species: _species,
          );
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MainShell(key: MainShell.shellKey),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _showForm ? _buildForm() : _buildWelcome(),
      ),
    );
  }

  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.pets_rounded, color: AppColors.pastelOrangeDark, size: 28),
              const SizedBox(width: 8),
              Text(
                AppStrings.t(context, 'appName'),
                style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          const Spacer(flex: 1),
          const PetHeroIllustration(height: 280),
          const SizedBox(height: 32),
          RichText(
            text: TextSpan(
              style: HomeStyle.displayGreeting.copyWith(fontSize: 28, height: 1.25),
              children: [
                TextSpan(text: '${AppStrings.t(context, 'onboardingHeadlinePart1')} '),
                TextSpan(text: AppStrings.t(context, 'onboardingHeadlineYou'), style: const TextStyle(color: AppColors.primaryDark)),
                TextSpan(text: ' ${AppStrings.t(context, 'onboardingHeadlinePart2')} '),
                TextSpan(text: AppStrings.t(context, 'onboardingHeadlinePet'), style: const TextStyle(color: AppColors.pastelOrangeDark)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(AppStrings.t(context, 'onboardingCaption'), style: HomeStyle.displaySubtitle),
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HomeStyle.buttonRadius)),
                elevation: 0,
              ),
              onPressed: () => setState(() => _showForm = true),
              child: Text(AppStrings.t(context, 'getStarted'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(onPressed: _finish, child: Text(AppStrings.t(context, 'skip'))),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppStrings.t(context, 'addPet'), style: HomeStyle.displayGreeting.copyWith(fontSize: 24)),
          const SizedBox(height: 8),
          Text(AppStrings.t(context, 'onboardingSubtitle'), style: HomeStyle.displaySubtitle),
          const SizedBox(height: 24),
          TextField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: AppStrings.t(context, 'petName'),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _species,
            decoration: InputDecoration(
              labelText: AppStrings.t(context, 'species'),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            items: [
              DropdownMenuItem(value: 'dog', child: Text(AppStrings.t(context, 'speciesDog'))),
              DropdownMenuItem(value: 'cat', child: Text(AppStrings.t(context, 'speciesCat'))),
            ],
            onChanged: (v) => setState(() => _species = v ?? 'dog'),
          ),
          const SizedBox(height: 12),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppStrings.t(context, 'birthDate')),
              subtitle: Text('${_birthDate.day}/${_birthDate.month}/${_birthDate.year}'),
              trailing: const Icon(Icons.calendar_today_rounded, color: AppColors.primaryDark),
              onTap: () async {
                final picked = await showDatePicker(context: context, initialDate: _birthDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                if (picked != null) setState(() => _birthDate = picked);
              },
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HomeStyle.buttonRadius)),
            ),
            onPressed: _finish,
            child: Text(AppStrings.t(context, 'getStarted')),
          ),
        ],
      ),
    );
  }
}
