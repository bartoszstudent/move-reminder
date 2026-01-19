import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../models/activity_model.dart';
import '../models/tip_model.dart';
import '../services/auth_service.dart';
import '../services/sensor_service.dart';
import '../services/activity_service.dart';
import '../services/notification_service.dart';
import '../services/tips_service.dart';
import '../widgets/activity_card.dart';
import '../widgets/tip_card.dart';
import '../services/background_step_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SensorService _sensorService;
  late ActivityService _activityService;
  late AuthService _authService;
  late NotificationService _notificationService;
  late TipsService _tipsService;

  UserModel? _currentUser;
  ActivityData? _todayActivity;
  Timer? _saveTimer;
  Timer? _inactivityCheckTimer;
  StreamSubscription? _sensorSubscription;
  List<ActivityData> _weeklyActivities = [];

  int _stepCount = 0;
  int _previousStepCount = 0;
  int _inactivityMinutes = 0;
  double _calories = 0;
  double _activityPercentage = 0;
  bool _sensorsInitialized = false;
  bool _inactivityNotificationSent =
      false; // Track if notification already sent

  DateTime? _lastActivityTime;
  List<ActivityTip> _tips = [];

  @override
  void initState() {
    super.initState();
    _sensorService = SensorService();
    _activityService = ActivityService();
    _authService = AuthService();
    _notificationService = NotificationService();
    _tipsService = TipsService();

    _initialize();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _inactivityCheckTimer?.cancel();
    _sensorSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    // Reset activity counters
    _stepCount = 0;
    _inactivityMinutes = 0;
    _calories = 0;
    _activityPercentage = 0;
    _lastActivityTime = DateTime.now(); // Initialize to now

    // Initialize notifications
    await _notificationService.initialize();

    // Initialize background step tracking asynchronously (don't wait)
    BackgroundStepService.initBackgroundTracking();

    // Get current user - with timeout to prevent blocking auth stream
    try {
      _currentUser = await _authService.getCurrentUser().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
    } catch (e) {
      // Error getting current user
    }

    if (_currentUser != null) {
      try {
        // Load today's activity with timeout
        _todayActivity = await _activityService
            .getTodayActivity(_currentUser!.uid)
            .timeout(const Duration(seconds: 5));

        if (_todayActivity != null) {
          _stepCount = _todayActivity!.steps;
          _inactivityMinutes = _todayActivity!.inactivityMinutes;
          _calories = _todayActivity!.calories.toDouble();
          _activityPercentage = _todayActivity!.activityPercentage;
        }
      } catch (e) {
        // Error loading activity data
      }

      try {
        // Load tips with timeout
        _tips = await _tipsService.getActivityTips().timeout(
          const Duration(seconds: 5),
          onTimeout: () => [],
        );
        if (_tips.isEmpty) {
          _tips = [
            TipsService.getDefaultTip(0),
            TipsService.getDefaultTip(1),
            TipsService.getDefaultTip(2),
          ];
        }
      } catch (e) {
        _tips = [
          TipsService.getDefaultTip(0),
          TipsService.getDefaultTip(1),
          TipsService.getDefaultTip(2),
        ];
      }

      try {
        // Load weekly activity with timeout
        _weeklyActivities = await _activityService
            .getWeeklyActivity(_currentUser!.uid)
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        _weeklyActivities = [];
      }

      // Start listening to accelerometer
      _listenToSensor();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _listenToSensor() {
    _sensorsInitialized = false;
    _sensorSubscription?.cancel();

    // Initialize sensor step count with current loaded value
    _sensorService.setStepCount(_stepCount);
    _previousStepCount = _stepCount; // Synchronize with current step count

    _sensorSubscription = _sensorService.getAccelerometerStream().listen((
      AccelerometerEvent event,
    ) {
      // On first sensor reading, don't reset step count
      if (!_sensorsInitialized) {
        _sensorsInitialized = true;
        return;
      }

      _stepCount = _sensorService.detectSteps(event);
      _calories = _sensorService.calculateCalories(_stepCount);
      _activityPercentage =
          (_stepCount / (_currentUser?.dailyActivityGoal ?? 10000)) * 100;

      // Check if new steps detected (step count increased)
      if (_stepCount > _previousStepCount) {
        // New steps detected - reset inactivity
        _lastActivityTime = DateTime.now();
        _inactivityMinutes = 0;
        _inactivityNotificationSent = false; // Reset notification flag
      }

      // Check if goal reached
      if (_stepCount == _currentUser?.dailyActivityGoal) {
        _notificationService.showActivityGoalNotification(
          steps: _stepCount,
          goal: _currentUser!.dailyActivityGoal,
        );
      }

      _previousStepCount = _stepCount;

      if (mounted) {
        setState(() {});
      }
    });

    // Start periodic save timer - save every 30 seconds
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _saveActivityData();
    });

    // Start inactivity check timer - check every 1 minute
    _inactivityCheckTimer?.cancel();
    _inactivityCheckTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _checkInactivity();
    });

    // Also save immediately on first change
    _saveActivityData();
  }

  void _checkInactivity() {
    if (_lastActivityTime == null) return;

    _inactivityMinutes = DateTime.now()
        .difference(_lastActivityTime!)
        .inMinutes;

    // Show notification if threshold exceeded and not already sent
    final threshold = _currentUser?.inactivityThreshold ?? 30;
    if (_inactivityMinutes >= threshold) {
      if (!_inactivityNotificationSent) {
        _notificationService.showInactivityNotification(
          inactivityMinutes: _inactivityMinutes,
        );
        _inactivityNotificationSent = true;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveActivityData() async {
    if (_currentUser == null) return;

    try {
      final today = DateTime.now();
      final activityId =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Load existing activity to get cumulative inactivity
      int cumulativeInactivity = 0;
      if (_todayActivity != null) {
        cumulativeInactivity = _todayActivity!.cumulativeInactivityMinutes;
      }

      // Add current inactivity period to cumulative
      cumulativeInactivity += _inactivityMinutes;

      final activityData = ActivityData(
        id: activityId,
        userId: _currentUser!.uid,
        date: today,
        steps: _stepCount,
        calories: _calories.toInt(),
        inactivityMinutes: _inactivityMinutes,
        cumulativeInactivityMinutes: cumulativeInactivity,
        activityPercentage: _activityPercentage,
        sessions: [],
      );

      await _activityService.saveActivityData(
        userId: _currentUser!.uid,
        activityData: activityData,
      );

      // Update baseline for background tracking
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('steps_baseline_${_currentUser!.uid}', _stepCount);
      await prefs.setInt('last_saved_steps_${_currentUser!.uid}', _stepCount);
      await prefs.setString(
        'last_activity_${_currentUser!.uid}',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // Error saving activity data
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Move Reminder'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              // Save activity data before logout
              await _saveActivityData();
              await _authService.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _todayActivity = await _activityService.getTodayActivity(
            _currentUser!.uid,
          );
          setState(() {});
        },
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Welcome card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cześć, ${_currentUser!.displayName}!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Dziś: $_stepCount / ${_currentUser!.dailyActivityGoal} kroków',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Stats grid
            Row(
              children: [
                Expanded(
                  child: ActivityCard(
                    icon: Icons.directions_run,
                    label: 'Kroki',
                    value: '$_stepCount',
                    subtitle: 'Cel: ${_currentUser!.dailyActivityGoal}',
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ActivityCard(
                    icon: Icons.local_fire_department,
                    label: 'Kalorie',
                    value: '${_calories.toStringAsFixed(0)}',
                    subtitle: 'kcal spalonych',
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ActivityCard(
                    icon: Icons.schedule,
                    label: 'Bezruch',
                    value: '$_inactivityMinutes',
                    subtitle: 'minut bez aktywności',
                    color: Colors.purple,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ActivityCard(
                    icon: Icons.percent,
                    label: 'Postęp',
                    value: '${_activityPercentage.toStringAsFixed(0)}%',
                    subtitle: 'dziennego celu',
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            SizedBox(height: 25),

            // Activity history
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historia ostatnich 7 dni',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/history'),
                  icon: Icon(Icons.arrow_forward, size: 18),
                  label: Text('Więcej'),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (_weeklyActivities.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Brak danych',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              )
            else
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _weeklyActivities.length,
                  itemBuilder: (context, index) {
                    final activity = _weeklyActivities[index];
                    final date = activity.date;
                    final dayName = [
                      'Pon',
                      'Wto',
                      'Śro',
                      'Czw',
                      'Pią',
                      'Sob',
                      'Nie',
                    ][date.weekday - 1];

                    return GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/history'),
                      child: Container(
                        width: 70,
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: activity.steps > 0
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.05),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${activity.date.day}',
                              style: TextStyle(fontSize: 10),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '${activity.steps}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            SizedBox(height: 25),

            // Activity progress
            Text(
              'Postęp dzisiejszej aktywności',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _activityPercentage / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _activityPercentage >= 100 ? Colors.green : Colors.blue,
                ),
              ),
            ),

            SizedBox(height: 25),

            // Tips section
            Text(
              'Porady aktywności',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 10),
            ..._tips.map(
              (tip) => Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: TipCard(tip: tip),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
