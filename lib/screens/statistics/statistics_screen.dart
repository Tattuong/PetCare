import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/activity_log.dart';
import '../../providers/activity_provider.dart';
import '../../providers/pet_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_ui.dart';
import '../timeline/timeline_screen.dart';

class StatisticsScreen extends StatelessWidget {
  final bool embedded;

  const StatisticsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetProvider>().activePet;
    final activity = context.watch<ActivityProvider>();
    final shop = context.watch<ShopProvider>();

    if (pet == null) {
      return Center(child: Text(AppStrings.t(context, 'addPet')));
    }

    final weightData = activity.weightData(pet.id);
    final hasPro = shop.hasStatsPro;

    final body = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, embedded ? 8 : 16, 20, 8),
            child: Text(
              AppStrings.t(context, 'statisticsTitle'),
              style: AppTypography.journalTitle(),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.t(context, 'weightChart'), style: AppTypography.labelBold(size: 16)),
                  const SizedBox(height: 16),
                  if (!hasPro && weightData.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        AppStrings.t(context, 'statsProLocked'),
                        style: const TextStyle(color: AppColors.warning, fontSize: 12),
                      ),
                    ),
                  SizedBox(
                    height: 200,
                    child: weightData.isEmpty
                        ? Center(child: Text(AppStrings.t(context, 'noWeightYet')))
                        : _WeightChart(data: hasPro ? weightData : weightData.take(5).toList()),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(AppStrings.t(context, 'careSchedule'), style: AppTypography.labelBold(size: 16)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _CareScheduleList(petId: pet.id),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(AppStrings.t(context, 'timeline'), style: AppTypography.labelBold(size: 16)),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: TimelineScreen(embedded: true, petId: pet.id),
        ),
      ],
    );

    if (embedded) return body;
    return Scaffold(body: SafeArea(child: body));
  }
}

class _WeightChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const _WeightChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), (data[i]['weight'] as double?) ?? 0));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryDark,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.pastelGreen.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _CareScheduleList extends StatelessWidget {
  final String petId;

  const _CareScheduleList({required this.petId});

  @override
  Widget build(BuildContext context) {
    final activity = context.watch<ActivityProvider>();
    final groomingLogs = activity.logsForPet(petId, type: ActivityType.grooming).take(3);
    final vaccineSchedule = activity.vaccineSchedule(petId).where((v) => !v.completed).take(3);

    if (groomingLogs.isEmpty && vaccineSchedule.isEmpty) {
      return AppGlassCard(
        child: Text(AppStrings.t(context, 'noLogs'), style: const TextStyle(color: AppColors.textSecondary)),
      );
    }

    return Column(
      children: [
        ...vaccineSchedule.map((v) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppGlassCard(
                child: Row(
                  children: [
                    const Icon(Icons.vaccines_rounded, color: AppColors.primaryDark),
                    const SizedBox(width: 12),
                    Expanded(child: Text('${AppStrings.t(context, 'vaccineDue')}: ${v.name}')),
                  ],
                ),
              ),
            )),
        ...groomingLogs.map((log) {
          final nextDue = log.data['nextDue'] as String?;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppGlassCard(
              child: Row(
                children: [
                  const Icon(Icons.shower_rounded, color: AppColors.pastelOrangeDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      nextDue != null
                          ? '${AppStrings.t(context, 'nextGrooming')}: ${DateTime.parse(nextDue).day}/${DateTime.parse(nextDue).month}/${DateTime.parse(nextDue).year}'
                          : log.data['groomingType']?.toString() ?? AppStrings.t(context, 'grooming'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
