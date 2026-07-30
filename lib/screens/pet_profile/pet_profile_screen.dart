import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/pet_photo_service.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/pet.dart';
import '../../providers/activity_provider.dart';
import '../../providers/pet_provider.dart';
import '../../screens/home/home_screen.dart';
import '../../widgets/home_style.dart';
import '../../widgets/pet_ui_components.dart';

class PetProfileScreen extends StatefulWidget {
  final Pet pet;

  const PetProfileScreen({super.key, required this.pet});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  late Pet _pet;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
  }

  Future<void> _pickPhoto() async {
    final path = await PetPhotoService.pickAndSave(context, petId: _pet.id);
    if (path == null) return;
    _pet = _pet.copyWith(photoPath: path);
    await context.read<PetProvider>().updatePet(_pet);
    if (mounted) setState(() {});
  }

  Future<void> _edit() async {
    final result = await showDialog<PetFormResult>(
      context: context,
      builder: (ctx) => PetFormDialog(isEdit: true, initial: _pet),
    );
    if (result != null && mounted) {
      _pet = _pet.copyWith(
        name: result.name,
        birthDate: result.birthDate,
        species: result.species,
        breed: result.breed,
        furColor: result.furColor,
        gender: result.gender,
        photoPath: result.photoPath ?? _pet.photoPath,
      );
      await context.read<PetProvider>().updatePet(_pet);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final vi = AppStrings.languageCodeOf(context) == 'vi';
    final activity = context.watch<ActivityProvider>();
    final weight = activity.latestWeight(_pet.id);
    final weightData = activity.weightData(_pet.id);
    final genderIcon = _pet.gender == 'female' ? Icons.female_rounded : _pet.gender == 'male' ? Icons.male_rounded : Icons.pets_rounded;
    final hasPhoto = _pet.photoPath != null && File(_pet.photoPath!).existsSync();

    return Scaffold(
      backgroundColor: HomeStyle.pageBg,
      body: Column(
        children: [
          PurpleHeaderBar(
            title: AppStrings.t(context, 'petDetails'),
            actions: [
              IconButton(icon: const Icon(Icons.more_vert_rounded, color: Colors.white), onPressed: _edit),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                children: [
                  SoftCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickPhoto,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                height: 140,
                                width: 140,
                                decoration: BoxDecoration(
                                  color: AppColors.pastelOrange.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: hasPhoto
                                      ? Image.file(File(_pet.photoPath!), fit: BoxFit.cover, width: 140, height: 140)
                                      : Icon(Icons.pets_rounded, size: 72, color: AppColors.pastelOrangeDark),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  shape: BoxShape.circle,
                                  boxShadow: HomeStyle.floatShadow(AppColors.primaryDark),
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.t(context, hasPhoto ? 'changePhoto' : 'tapToAddPhoto'),
                          style: HomeStyle.displaySubtitle.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        Text(_pet.name, style: HomeStyle.sectionTitle.copyWith(fontSize: 22)),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_pet.ageLabel(vi: vi), style: HomeStyle.ageLabel()),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.pastelLavender,
                              child: Icon(genderIcon, size: 14, color: AppColors.primaryDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatMiniCard(
                          icon: Icons.monitor_weight_outlined,
                          label: AppStrings.t(context, 'weightLabel'),
                          value: weight != null ? '${weight.toStringAsFixed(1)} kg' : '-',
                          color: AppColors.pastelPinkDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatMiniCard(
                          icon: Icons.favorite_rounded,
                          label: AppStrings.t(context, 'health'),
                          value: _pet.speciesLabel(vi: vi),
                          color: AppColors.pastelPurple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppStrings.t(context, 'weightChart'), style: HomeStyle.sectionTitle.copyWith(fontSize: 16)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(AppStrings.t(context, 'week'), style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: weightData.isEmpty
                              ? Center(child: Text(AppStrings.t(context, 'noWeightYet'), style: HomeStyle.displaySubtitle))
                              : _MiniWeightChart(data: weightData),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ProfileRow(label: AppStrings.t(context, 'breed'), value: _pet.breed.isEmpty ? '-' : _pet.breed),
                  _ProfileRow(label: AppStrings.t(context, 'furColor'), value: _pet.furColor.isEmpty ? '-' : _pet.furColor),
                  _ProfileRow(
                    label: AppStrings.t(context, 'birthDate'),
                    value: '${_pet.birthDate.day}/${_pet.birthDate.month}/${_pet.birthDate.year}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatMiniCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(label, style: HomeStyle.ageLabel()),
        ],
      ),
    );
  }
}

class _MiniWeightChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _MiniWeightChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), (data[i]['weight'] as double?) ?? 0));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) => LineTooltipItem('${s.y.toStringAsFixed(1)} kg', const TextStyle(color: Colors.white, fontSize: 11))).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryDark,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: index == spots.length - 1 ? 6 : 3,
                color: index == spots.length - 1 ? AppColors.error : AppColors.primaryDark,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(show: true, color: AppColors.pastelLavender.withValues(alpha: 0.35)),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(label, style: HomeStyle.displaySubtitle.copyWith(fontSize: 13))),
            Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
