enum ActivityType {
  feeding,
  vaccine,
  health,
  grooming,
  weight,
  note,
}

enum FeedingType { dry, wet, raw, treat, homemade }

enum GroomingType { bath, nailTrim, haircut, brush, other }

enum HealthRecordType { illness, medication, checkup, other }

class ActivityLog {
  final String id;
  final String petId;
  final ActivityType type;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final String? note;

  ActivityLog({
    required this.id,
    required this.petId,
    required this.type,
    required this.timestamp,
    this.data = const {},
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'petId': petId,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
        'data': data,
        'note': note,
      };

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    final petId = json['petId'] as String? ?? json['babyId'] as String? ?? '';
    return ActivityLog(
      id: json['id'] as String,
      petId: petId,
      type: ActivityType.values.byName(json['type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      note: json['note'] as String?,
    );
  }

  ActivityLog copyWith({
    DateTime? timestamp,
    Map<String, dynamic>? data,
    String? note,
  }) =>
      ActivityLog(
        id: id,
        petId: petId,
        type: type,
        timestamp: timestamp ?? this.timestamp,
        data: data ?? this.data,
        note: note ?? this.note,
      );
}

class TodaySummary {
  final int feedingCount;
  final int groomingCount;
  final int healthCount;
  final int totalLogs;

  const TodaySummary({
    this.feedingCount = 0,
    this.groomingCount = 0,
    this.healthCount = 0,
    this.totalLogs = 0,
  });
}

class VaccineSchedule {
  final String id;
  final String name;
  final int recommendedMonths;
  final bool completed;
  final DateTime? completedDate;
  final DateTime? nextDueDate;

  const VaccineSchedule({
    required this.id,
    required this.name,
    required this.recommendedMonths,
    this.completed = false,
    this.completedDate,
    this.nextDueDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'recommendedMonths': recommendedMonths,
        'completed': completed,
        'completedDate': completedDate?.toIso8601String(),
        'nextDueDate': nextDueDate?.toIso8601String(),
      };

  factory VaccineSchedule.fromJson(Map<String, dynamic> json) => VaccineSchedule(
        id: json['id'] as String,
        name: json['name'] as String,
        recommendedMonths: json['recommendedMonths'] as int? ?? json['recommendedWeeks'] as int? ?? 0,
        completed: json['completed'] as bool? ?? false,
        completedDate: json['completedDate'] != null
            ? DateTime.parse(json['completedDate'] as String)
            : null,
        nextDueDate: json['nextDueDate'] != null
            ? DateTime.parse(json['nextDueDate'] as String)
            : null,
      );

  VaccineSchedule copyWith({
    bool? completed,
    DateTime? completedDate,
    DateTime? nextDueDate,
  }) =>
      VaccineSchedule(
        id: id,
        name: name,
        recommendedMonths: recommendedMonths,
        completed: completed ?? this.completed,
        completedDate: completedDate ?? this.completedDate,
        nextDueDate: nextDueDate ?? this.nextDueDate,
      );
}

const defaultPetVaccines = [
  VaccineSchedule(id: 'rabies', name: 'Rabies', recommendedMonths: 4),
  VaccineSchedule(id: 'dhpp1', name: 'DHPP #1', recommendedMonths: 2),
  VaccineSchedule(id: 'dhpp2', name: 'DHPP #2', recommendedMonths: 3),
  VaccineSchedule(id: 'dhpp3', name: 'DHPP #3', recommendedMonths: 4),
  VaccineSchedule(id: 'bordetella', name: 'Bordetella', recommendedMonths: 4),
  VaccineSchedule(id: 'lepto', name: 'Leptospirosis', recommendedMonths: 6),
  VaccineSchedule(id: 'dhpp_booster', name: 'DHPP Booster', recommendedMonths: 12),
  VaccineSchedule(id: 'rabies_booster', name: 'Rabies Booster', recommendedMonths: 12),
];
