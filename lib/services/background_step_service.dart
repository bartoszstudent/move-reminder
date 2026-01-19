import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health/health.dart';
import '../services/activity_service.dart';
import '../services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

const String backgroundStepTaskId = 'backgroundStepTask';

class BackgroundStepService {
  static final BackgroundStepService _instance =
      BackgroundStepService._internal();

  factory BackgroundStepService() {
    return _instance;
  }

  BackgroundStepService._internal();

  static void callbackDispatcher() {
    Workmanager().executeTask((taskName, inputData) async {
      if (taskName == backgroundStepTaskId) {
        await _backgroundStepTask();
      }
      return true;
    });
  }

  static Future<void> _backgroundStepTask() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser;

      if (user == null) {
        return;
      }

      // Get baseline (last known step count)
      int baseline = prefs.getInt('steps_baseline_${user.uid}') ?? 0;
      int lastSavedSteps = prefs.getInt('last_saved_steps_${user.uid}') ?? 0;

      // Get steps from Health (Google Fit on Android, HealthKit on iOS)
      int googleFitSteps = await _getHealthSteps();

      // Calculate delta (difference)
      int delta = googleFitSteps - baseline;
      if (delta < 0) delta = 0; // Don't allow negative deltas

      // New total steps
      int newTotalSteps = lastSavedSteps + delta;

      // Save to Firebase with delta
      if (delta > 0) {
        await ActivityService().saveActivityDataDelta(
          userId: user.uid,
          deltaSteps: delta,
        );
      }

      // Update baseline
      await prefs.setInt('steps_baseline_${user.uid}', googleFitSteps);
      await prefs.setInt('last_saved_steps_${user.uid}', newTotalSteps);

      // Check inactivity (30 minutes without new steps)
      DateTime? lastActivityTime = DateTime.tryParse(
        prefs.getString('last_activity_${user.uid}') ?? '',
      );

      if (delta == 0 && lastActivityTime != null) {
        int inactiveMinutes = DateTime.now()
            .difference(lastActivityTime)
            .inMinutes;

        if (inactiveMinutes >= 30) {
          await NotificationService().showInactivityNotification(
            inactivityMinutes: inactiveMinutes,
          );
        }
      }
    } catch (e) {
      // Background step task error
    }
  }

  static Future<int> _getHealthSteps() async {
    try {
      final health = Health();

      // Request health permissions
      final permissions = [HealthDataAccess.READ];
      final types = [HealthDataType.STEPS];

      bool requested = await health.requestAuthorization(
        types,
        permissions: permissions,
      );

      if (!requested) {
        return 0;
      }

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final steps = await health.getHealthDataFromTypes(
        startTime: startOfDay,
        endTime: now,
        types: types,
      );

      int totalSteps = 0;
      for (var dataPoint in steps) {
        if (dataPoint.type == HealthDataType.STEPS) {
          totalSteps += (dataPoint.value as int);
        }
      }

      return totalSteps;
    } catch (e) {
      return 0;
    }
  }

  /// Initialize background step tracking
  static Future<void> initBackgroundTracking() async {
    try {
      // Initialize workmanager with timeout
      await Workmanager()
          .initialize(callbackDispatcher, isInDebugMode: true)
          .timeout(Duration(seconds: 10));

      // Register periodic task (15 minutes)
      await Workmanager()
          .registerPeriodicTask(
            backgroundStepTaskId,
            backgroundStepTaskId,
            frequency: Duration(minutes: 15),
          )
          .timeout(Duration(seconds: 10));
    } catch (e) {
      // Initialization error - don't crash app
    }
  }

  /// Stop background step tracking
  static Future<void> stopBackgroundTracking() async {
    try {
      await Workmanager().cancelAll();
    } catch (e) {
      // Stop error
    }
  }
}
