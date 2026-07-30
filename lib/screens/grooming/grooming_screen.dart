import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/helpers/activity_log_helper.dart';
import '../../models/activity_log.dart';
import '../../providers/pet_provider.dart';
import '../../widgets/app_ui.dart';

class GroomingScreen extends StatefulWidget {
  const GroomingScreen({super.key});

  @override
  State<GroomingScreen> createState() => _GroomingScreenState();
}

class _GroomingScreenState extends State<GroomingScreen> {
  GroomingType _type = GroomingType.bath;
  final _noteCtrl = TextEditingController();
  DateTime _time = DateTime.now();
  DateTime? _nextDue;

  @override
  void dispose() {
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
        type: ActivityType.grooming,
        timestamp: _time,
        data: {
          'groomingType': _type.name,
          if (_nextDue != null) 'nextDue': _nextDue!.toIso8601String(),
        },
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      ),
    );
  }

  String _groomingLabel(GroomingType type) {
    return switch (type) {
      GroomingType.bath => AppStrings.t(context, 'groomingBath'),
      GroomingType.nailTrim => AppStrings.t(context, 'groomingNailTrim'),
      GroomingType.haircut => AppStrings.t(context, 'groomingHaircut'),
      GroomingType.brush => AppStrings.t(context, 'groomingBrush'),
      GroomingType.other => AppStrings.t(context, 'groomingOther'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppFormScreen(
      title: AppStrings.t(context, 'groomingTitle'),
      saveLabel: AppStrings.t(context, 'save'),
      onSave: _save,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: GroomingType.values.map((t) {
            return ChoiceChip(
              label: Text(_groomingLabel(t)),
              selected: _type == t,
              onSelected: (_) => setState(() => _type = t),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.t(context, 'mealTime')),
          subtitle: Text('${_time.day}/${_time.month}/${_time.year} ${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
          trailing: const Icon(Icons.calendar_today_rounded),
          onTap: () async {
            final date = await showDatePicker(context: context, initialDate: _time, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
            if (date != null && context.mounted) {
              final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_time));
              if (time != null) {
                setState(() => _time = DateTime(date.year, date.month, date.day, time.hour, time.minute));
              }
            }
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(AppStrings.t(context, 'nextGrooming')),
          subtitle: Text(_nextDue != null ? '${_nextDue!.day}/${_nextDue!.month}/${_nextDue!.year}' : '-'),
          trailing: const Icon(Icons.event_rounded),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _nextDue ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (picked != null) setState(() => _nextDue = picked);
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
