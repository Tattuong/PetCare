import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';
import '../models/activity_log.dart';

class ActivityProvider extends ChangeNotifier {
  static const _logsKey = 'pcn_activity_logs';
  static const _vaccinesKey = 'pcn_vaccine_schedule';

  final _uuid = const Uuid();
  List<ActivityLog> _logs = [];
  Map<String, List<VaccineSchedule>> _vaccineSchedules = {};
  final Map<String, Map<ActivityType, ActivityLog>> _lastLogs = {};

  List<ActivityLog> get logs => List.unmodifiable(_logs);

  Future<void> init() async {
    await _load();
    _rebuildLastLogIndex();
    notifyListeners();
  }

  Future<void> _load() async {
    final raw = await StorageService.instance.getString(_logsKey);
    if (raw != null && raw.isNotEmpty) {
      _logs = StorageService.decodeList(raw).map(ActivityLog.fromJson).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    final vaxRaw = await StorageService.instance.getData(_vaccinesKey);
    if (vaxRaw != null) {
      _vaccineSchedules = vaxRaw.map(
        (k, v) => MapEntry(
          k,
          (v as List).map((e) => VaccineSchedule.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        ),
      );
    }
  }

  Future<void> _saveLogs() async {
    await StorageService.instance.saveString(
      _logsKey,
      StorageService.encodeList(_logs.map((l) => l.toJson()).toList()),
    );
  }

  Future<void> _saveVaccines() async {
    final data = _vaccineSchedules.map(
      (k, v) => MapEntry(k, v.map((s) => s.toJson()).toList()),
    );
    await StorageService.instance.saveData(_vaccinesKey, data);
  }

  void _rebuildLastLogIndex() {
    _lastLogs.clear();
    for (final log in _logs) {
      _lastLogs.putIfAbsent(log.petId, () => {}).putIfAbsent(log.type, () => log);
    }
  }

  void _updateLastLogIndex(ActivityLog log) {
    _lastLogs.putIfAbsent(log.petId, () => {})[log.type] = log;
  }

  void _invalidateLastLogIndex(String petId, ActivityType type) {
    _lastLogs[petId]?.remove(type);
    final latest = logsForPet(petId, type: type).firstOrNull;
    if (latest != null) {
      _lastLogs.putIfAbsent(petId, () => {})[type] = latest;
    }
  }

  List<ActivityLog> logsForPet(String petId, {ActivityType? type}) {
    return _logs.where((l) {
      if (l.petId != petId) return false;
      if (type != null && l.type != type) return false;
      return true;
    }).toList();
  }

  ActivityLog? lastLog(String petId, ActivityType type) => _lastLogs[petId]?[type];

  ActivityLog? lastCareLog(String petId) {
    final careTypes = [ActivityType.feeding, ActivityType.grooming, ActivityType.health, ActivityType.vaccine];
    ActivityLog? latest;
    for (final type in careTypes) {
      final log = lastLog(petId, type);
      if (log != null && (latest == null || log.timestamp.isAfter(latest.timestamp))) {
        latest = log;
      }
    }
    return latest;
  }

  String? timeAgoLabel(DateTime? dt, {bool vi = false}) {
    if (dt == null) return null;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return vi ? 'Vừa xong' : 'Just now';
    if (diff.inMinutes < 60) return vi ? '${diff.inMinutes} phút trước' : '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return vi ? '${diff.inHours} giờ trước' : '${diff.inHours}h ago';
    if (diff.inDays < 7) return vi ? '${diff.inDays} ngày trước' : '${diff.inDays}d ago';
    final weeks = (diff.inDays / 7).floor();
    return vi ? '$weeks tuần trước' : '${weeks}w ago';
  }

  TodaySummary todaySummary(String petId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayLogs = _logs.where((l) {
      if (l.petId != petId) return false;
      final d = DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day);
      return d == today;
    }).toList();

    return TodaySummary(
      feedingCount: todayLogs.where((l) => l.type == ActivityType.feeding).length,
      groomingCount: todayLogs.where((l) => l.type == ActivityType.grooming).length,
      healthCount: todayLogs.where((l) => l.type == ActivityType.health).length,
      totalLogs: todayLogs.length,
    );
  }

  double? latestWeight(String petId) {
    final weightLogs = logsForPet(petId, type: ActivityType.weight);
    if (weightLogs.isEmpty) return null;
    return (weightLogs.first.data['weight'] as num?)?.toDouble();
  }

  Future<ActivityLog> addLog({
    required String petId,
    required ActivityType type,
    DateTime? timestamp,
    Map<String, dynamic> data = const {},
    String? note,
  }) async {
    final log = ActivityLog(
      id: _uuid.v4(),
      petId: petId,
      type: type,
      timestamp: timestamp ?? DateTime.now(),
      data: data,
      note: note,
    );
    _logs.insert(0, log);
    _updateLastLogIndex(log);
    await _saveLogs();
    notifyListeners();
    return log;
  }

  Future<void> updateLog(ActivityLog log) async {
    final i = _logs.indexWhere((l) => l.id == log.id);
    if (i >= 0) {
      final previous = _logs[i];
      _logs[i] = log;
      _logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (previous.petId != log.petId || previous.type != log.type) {
        _invalidateLastLogIndex(previous.petId, previous.type);
      }
      _updateLastLogIndex(log);
      await _saveLogs();
      notifyListeners();
    }
  }

  Future<void> deleteLog(String id) async {
    final existing = _logs.where((l) => l.id == id).firstOrNull;
    _logs.removeWhere((l) => l.id == id);
    if (existing != null) {
      _invalidateLastLogIndex(existing.petId, existing.type);
    }
    await _saveLogs();
    notifyListeners();
  }

  List<ActivityLog> searchLogs(String petId, String query) {
    final q = query.toLowerCase();
    return logsForPet(petId).where((l) {
      if (l.note?.toLowerCase().contains(q) == true) return true;
      if (l.type.name.contains(q)) return true;
      return l.timestamp.toString().contains(q);
    }).toList();
  }

  List<ActivityLog> logsForDate(String petId, DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return logsForPet(petId).where((l) {
      final ld = DateTime(l.timestamp.year, l.timestamp.month, l.timestamp.day);
      return ld == d;
    }).toList();
  }

  List<VaccineSchedule> vaccineSchedule(String petId) {
    if (!_vaccineSchedules.containsKey(petId)) {
      _vaccineSchedules[petId] = defaultPetVaccines.map((v) => v).toList();
      _saveVaccines();
    }
    return _vaccineSchedules[petId]!;
  }

  Future<void> toggleVaccine(String petId, String vaccineId, {DateTime? date}) async {
    final list = vaccineSchedule(petId);
    final i = list.indexWhere((v) => v.id == vaccineId);
    if (i < 0) return;
    final current = list[i];
    final completed = !current.completed;
    list[i] = current.copyWith(
      completed: completed,
      completedDate: completed ? (date ?? DateTime.now()) : null,
      nextDueDate: completed ? DateTime.now().add(const Duration(days: 365)) : null,
    );
    _vaccineSchedules[petId] = list;
    await _saveVaccines();
    notifyListeners();
  }

  List<Map<String, dynamic>> weightData(String petId) {
    return logsForPet(petId, type: ActivityType.weight)
        .map((l) => {
              'date': l.timestamp,
              'weight': (l.data['weight'] as num?)?.toDouble(),
            })
        .where((e) => e['weight'] != null)
        .toList()
      ..sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
  }

  String exportData(String petId) {
    final petLogs = logsForPet(petId);
    final buffer = StringBuffer();
    buffer.writeln('PetCare Export');
    buffer.writeln('---');
    for (final log in petLogs) {
      buffer.writeln('${log.timestamp.toIso8601String()} | ${log.type.name} | ${log.data} | ${log.note ?? ''}');
    }
    return buffer.toString();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
