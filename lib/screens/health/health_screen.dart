import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/helpers/activity_log_helper.dart';
import '../../models/activity_log.dart';
import '../../providers/pet_provider.dart';
import '../../widgets/app_ui.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  HealthRecordType _type = HealthRecordType.checkup;
  final _medicationCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _medicationCtrl.dispose();
    _symptomsCtrl.dispose();
    _weightCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveHealth() async {
    final pet = context.read<PetProvider>().activePet;
    if (pet == null) return;

    await ActivityLogHelper.logAndReward(
      context,
      ActivityLog(
        id: '',
        petId: pet.id,
        type: ActivityType.health,
        timestamp: DateTime.now(),
        data: {
          'healthType': _type.name,
          'medication': _medicationCtrl.text.trim(),
          'symptoms': _symptomsCtrl.text.trim(),
        },
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );
  }

  Future<void> _saveWeight() async {
    final pet = context.read<PetProvider>().activePet;
    if (pet == null) return;
    final weight = double.tryParse(_weightCtrl.text);
    if (weight == null) return;

    await ActivityLogHelper.logAndReward(
      context,
      ActivityLog(
        id: '',
        petId: pet.id,
        type: ActivityType.weight,
        timestamp: DateTime.now(),
        data: {'weight': weight},
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );
  }

  String _healthLabel(HealthRecordType type) {
    return switch (type) {
      HealthRecordType.illness => AppStrings.t(context, 'healthIllness'),
      HealthRecordType.medication => AppStrings.t(context, 'healthMedication'),
      HealthRecordType.checkup => AppStrings.t(context, 'healthCheckupType'),
      HealthRecordType.other => AppStrings.t(context, 'healthOther'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScreen(
      title: AppStrings.t(context, 'healthTitle'),
      saveLabel: AppStrings.t(context, 'save'),
      onSave: _saveHealth,
      children: [
        Text(AppStrings.t(context, 'healthType'), style: AppTypography.labelBold(size: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HealthRecordType.values.map((t) {
            return ChoiceChip(
              label: Text(_healthLabel(t)),
              selected: _type == t,
              onSelected: (_) => setState(() => _type = t),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        if (_type == HealthRecordType.medication || _type == HealthRecordType.illness) ...[
          TextField(
            controller: _medicationCtrl,
            decoration: InputDecoration(labelText: AppStrings.t(context, 'medicationName')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _symptomsCtrl,
            decoration: InputDecoration(labelText: AppStrings.t(context, 'symptoms')),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _noteCtrl,
          maxLines: 3,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'note')),
        ),
        const SizedBox(height: 24),
        Text(AppStrings.t(context, 'weightLabel'), style: AppTypography.labelBold(size: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _weightCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppStrings.t(context, 'weight')),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: _saveWeight,
              child: Text(AppStrings.t(context, 'save')),
            ),
          ],
        ),
      ],
    );
  }
}
