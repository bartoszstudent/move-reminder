class ActivityData {
  final String id;
  final String userId;
  final DateTime date;
  final int steps;
  final int calories;
  final int inactivityMinutes;
  final int cumulativeInactivityMinutes;
  final double activityPercentage;
  final List<ActivitySession> sessions;

  ActivityData({
    required this.id,
    required this.userId,
    required this.date,
    required this.steps,
    required this.calories,
    required this.inactivityMinutes,
    required this.cumulativeInactivityMinutes,
    required this.activityPercentage,
    required this.sessions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'steps': steps,
      'calories': calories,
      'inactivityMinutes': inactivityMinutes,
      'cumulativeInactivityMinutes': cumulativeInactivityMinutes,
      'activityPercentage': activityPercentage,
      'sessions': sessions.map((s) => s.toMap()).toList(),
    };
  }

  factory ActivityData.fromMap(Map<String, dynamic> map, String id) {
    return ActivityData(
      id: id,
      userId: map['userId'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      steps: map['steps'] ?? 0,
      calories: map['calories'] ?? 0,
      inactivityMinutes: map['inactivityMinutes'] ?? 0,
      cumulativeInactivityMinutes: map['cumulativeInactivityMinutes'] ?? 0,
      activityPercentage: (map['activityPercentage'] ?? 0.0).toDouble(),
      sessions:
          (map['sessions'] as List<dynamic>?)
              ?.map((s) => ActivitySession.fromMap(s))
              .toList() ??
          [],
    );
  }
}

class ActivitySession {
  final DateTime startTime;
  final DateTime endTime;
  final int stepCount;
  final double intensity;

  ActivitySession({
    required this.startTime,
    required this.endTime,
    required this.stepCount,
    required this.intensity,
  });

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'stepCount': stepCount,
      'intensity': intensity,
    };
  }

  factory ActivitySession.fromMap(Map<String, dynamic> map) {
    return ActivitySession(
      startTime: DateTime.parse(
        map['startTime'] ?? DateTime.now().toIso8601String(),
      ),
      endTime: DateTime.parse(
        map['endTime'] ?? DateTime.now().toIso8601String(),
      ),
      stepCount: map['stepCount'] ?? 0,
      intensity: (map['intensity'] ?? 0.0).toDouble(),
    );
  }
}
