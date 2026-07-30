import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/helpers/activity_log_helper.dart';
import '../../models/activity_log.dart';
import '../../providers/pet_provider.dart';
import '../../widgets/app_ui.dart';

class FeedingScreen extends StatefulWidget {
  const FeedingScreen({super.key});

  @override
  State<FeedingScreen> createState() => _FeedingScreenState();
}

class _FeedingScreenState extends State<FeedingScreen> {
  FeedingType _type = FeedingType.dry;
  final _portionCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _time = DateTime.now();

  @override
  void dispose() {
    _portionCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final pet = context.read<PetProvider>().activePet;
    if (pet == null) return;

    await ActivityLogHelper.logAndReward(
      context,
      ActivityLog(
        id: '',
        petId: pet.id,
        type: ActivityType.feeding,
        timestamp: _time,
        data: {
          'feedingType': _type.name,
          'portion': double.tryParse(_portionCtrl.text) ?? 0,
        },
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );
  }

  String _feedingLabel(FeedingType type) {
    return switch (type) {
      FeedingType.dry => AppStrings.t(context, 'feedingDry'),
      FeedingType.wet => AppStrings.t(context, 'feedingWet'),
      FeedingType.raw => AppStrings.t(context, 'feedingRaw'),
      FeedingType.treat => AppStrings.t(context, 'feedingTreat'),
      FeedingType.homemade => AppStrings.t(context, 'feedingHomemade'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScreen(
      title: AppStrings.t(context, 'feedingTitle'),
      saveLabel: AppStrings.t(context, 'save'),
      onSave: _save,
      children: [
        Text(AppStrings.t(context, 'feedingType'), style: AppTypography.labelBold(size: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FeedingType.values.map((t) {
            final selected = _type == t;
            return ChoiceChip(
              label: Text(_feedingLabel(t)),
              selected: selected,
              onSelected: (_) => setState(() => _type = t),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _portionCtrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'portion')),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.t(context, 'mealTime')),
          subtitle: Text('${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
          trailing: const Icon(Icons.access_time_rounded),
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_time));
            if (picked != null) {
              setState(() => _time = DateTime(_time.year, _time.month, _time.day, picked.hour, picked.minute));
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteCtrl,
          maxLines: 3,
          decoration: InputDecoration(labelText: AppStrings.t(context, 'note')),
        ),
      ],
    );
  }
}
