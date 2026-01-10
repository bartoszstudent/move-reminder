import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';
import '../models/activity_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _activityService = ActivityService();
  final _authService = AuthService();

  List<ActivityData> _weeklyActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pl_PL');
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final activities = await _activityService.getWeeklyActivity(user.uid);
      setState(() {
        _weeklyActivities = activities;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Historia aktywności')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_weeklyActivities.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Historia aktywności')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey.shade400),
              SizedBox(height: 16),
              Text('Brak danych z ostatniego tygodnia'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Historia aktywności'),
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadHistory(),
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: _weeklyActivities.length,
          itemBuilder: (context, index) {
            final activity = _weeklyActivities[index];
            final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'pl_PL');

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateFormat.format(activity.date),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${activity.activityPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHistoryStatItem(
                        icon: Icons.directions_run,
                        label: 'Kroki',
                        value: '${activity.steps}',
                        color: Colors.blue,
                      ),
                      _buildHistoryStatItem(
                        icon: Icons.local_fire_department,
                        label: 'Kalorie',
                        value: '${activity.calories} kcal',
                        color: Colors.orange,
                      ),
                      _buildHistoryStatItem(
                        icon: Icons.schedule,
                        label: 'Bezruch',
                        value: '${activity.inactivityMinutes} min',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  if (activity.sessions.isNotEmpty) ...[
                    SizedBox(height: 12),
                    Text(
                      'Sesje aktywności (${activity.sessions.length})',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    ...activity.sessions.map(
                      (session) => Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${DateFormat('HH:mm').format(session.startTime)} - ${DateFormat('HH:mm').format(session.endTime)}',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            Text(
                              '${session.stepCount} kroków',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
