import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveActivityData({
    required String userId,
    required ActivityData activityData,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc(activityData.id)
          .set(activityData.toMap());
    } catch (e) {
      // Save activity error
    }
  }

  Future<ActivityData?> getTodayActivity(String userId) async {
    try {
      final today = DateTime.now();
      final activityId =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc(activityId)
          .get();

      if (doc.exists) {
        return ActivityData.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<ActivityData>> getWeeklyActivity(String userId) async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(Duration(days: 7));

      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .where('date', isGreaterThanOrEqualTo: weekAgo.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return query.docs
          .map((doc) => ActivityData.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateActivitySession({
    required String userId,
    required String activityId,
    required ActivitySession session,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc(activityId)
          .update({
            'sessions': FieldValue.arrayUnion([session.toMap()]),
          });
    } catch (e) {
      // Update activity session error
    }
  }

  Future<Map<String, dynamic>> getActivityStats(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));

      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .where(
            'date',
            isGreaterThanOrEqualTo: thirtyDaysAgo.toIso8601String(),
          )
          .get();

      int totalSteps = 0;
      int totalCalories = 0;
      int totalInactivity = 0;
      int daysTracked = query.docs.length;

      for (var doc in query.docs) {
        final activity = ActivityData.fromMap(doc.data(), doc.id);
        totalSteps += activity.steps;
        totalCalories += activity.calories;
        totalInactivity += activity.cumulativeInactivityMinutes;
      }

      return {
        'totalSteps': totalSteps,
        'averageStepsPerDay': daysTracked > 0 ? totalSteps ~/ daysTracked : 0,
        'totalCalories': totalCalories,
        'averageCaloriesPerDay': daysTracked > 0
            ? totalCalories ~/ daysTracked
            : 0,
        'totalInactivityMinutes': totalInactivity,
        'daysTracked': daysTracked,
      };
    } catch (e) {
      return {};
    }
  }

  /// Save activity with delta steps (for background tracking)
  Future<void> saveActivityDataDelta({
    required String userId,
    required int deltaSteps,
  }) async {
    try {
      final today = DateTime.now();
      final activityId =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Get existing activity
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc(activityId)
          .get();

      if (doc.exists) {
        // Update existing activity with delta
        final currentData = doc.data()!;
        final currentSteps = currentData['steps'] as int? ?? 0;
        final newSteps = currentSteps + deltaSteps;

        await doc.reference.update({
          'steps': newSteps,
          'lastUpdated': DateTime.now().toIso8601String(),
        });
      } else {
        // Create new activity with delta
        final newActivity = ActivityData(
          id: activityId,
          userId: userId,
          date: today,
          steps: deltaSteps,
          calories: 0,
          inactivityMinutes: 0,
          cumulativeInactivityMinutes: 0,
          activityPercentage: 0.0,
          sessions: [],
        );

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('activities')
            .doc(activityId)
            .set(newActivity.toMap());
      }
    } catch (e) {
      // Save delta activity error
    }
  }
}
