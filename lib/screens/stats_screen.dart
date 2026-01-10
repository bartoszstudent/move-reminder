import 'package:flutter/material.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _activityService = ActivityService();
  final _authService = AuthService();

  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final stats = await _activityService.getActivityStats(user.uid);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Statystyki')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_stats == null || _stats!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Statystyki')),
        body: Center(child: Text('Brak danych do wyświetlenia')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Statystyki'),
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadStats(),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              'Statystyki z ostatnich 30 dni',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 20),

            _buildStatCard(
              title: 'Całkowite kroki',
              value: '${_stats!['totalSteps']}',
              icon: Icons.directions_run,
              color: Colors.blue,
            ),

            SizedBox(height: 15),

            _buildStatCard(
              title: 'Średnia dziennie',
              value: '${_stats!['averageStepsPerDay']}',
              icon: Icons.trending_up,
              color: Colors.green,
            ),

            SizedBox(height: 15),

            _buildStatCard(
              title: 'Spalone kalorie',
              value: '${_stats!['totalCalories']} kcal',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),

            SizedBox(height: 15),

            _buildStatCard(
              title: 'Średnia kalorii dziennie',
              value: '${_stats!['averageCaloriesPerDay']} kcal',
              icon: Icons.bar_chart,
              color: Colors.red,
            ),

            SizedBox(height: 15),

            _buildStatCard(
              title: 'Dni śledzonych',
              value: '${_stats!['daysTracked']}',
              icon: Icons.calendar_today,
              color: Colors.purple,
            ),

            SizedBox(height: 15),

            _buildStatCard(
              title: 'Łączny czas bezruchu',
              value: '${_stats!['totalInactivityMinutes']} min',
              icon: Icons.schedule,
              color: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
