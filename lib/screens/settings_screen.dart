import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();

  UserModel? _currentUser;
  late int _dailyGoal;
  late int _inactivityThreshold;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _currentUser = await _authService.getCurrentUser();
    if (_currentUser != null) {
      _dailyGoal = _currentUser!.dailyActivityGoal;
      _inactivityThreshold = _currentUser!.inactivityThreshold;
    }
    setState(() {});
  }

  Future<void> _saveSettings() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      await _authService.updateUserPreferences(
        uid: _currentUser!.uid,
        dailyActivityGoal: _dailyGoal,
        inactivityThreshold: _inactivityThreshold,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ustawienia zapisane!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Ustawienia')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Ustawienia'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // User info
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil użytkownika',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.deepPurple,
                      child: Text(
                        _currentUser!.displayName[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser!.displayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _currentUser!.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 25),

          // Activity Goals
          Text(
            'Cele aktywności',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),

          // Daily goal slider
          Container(
            padding: EdgeInsets.all(15),
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
                    Text('Dzienny cel kroków'),
                    Text(
                      '$_dailyGoal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Slider(
                  value: _dailyGoal.toDouble(),
                  min: 1000,
                  max: 50000,
                  divisions: 49,
                  onChanged: (value) {
                    setState(() => _dailyGoal = value.toInt());
                  },
                  activeColor: Colors.deepPurple,
                ),
              ],
            ),
          ),

          SizedBox(height: 15),

          // Inactivity threshold
          Container(
            padding: EdgeInsets.all(15),
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
                    Text('Próg powiadomienia o bezruchu'),
                    Text(
                      '$_inactivityThreshold min',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Slider(
                  value: _inactivityThreshold.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  onChanged: (value) {
                    setState(() => _inactivityThreshold = value.toInt());
                  },
                  activeColor: Colors.deepPurple,
                ),
              ],
            ),
          ),

          SizedBox(height: 25),

          // Save button
          ElevatedButton(
            onPressed: _isLoading ? null : _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Zapisz ustawienia',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),

          SizedBox(height: 25),

          // Other settings
          Text(
            'Inne',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),

          ListTile(
            leading: Icon(Icons.history, color: Colors.deepPurple),
            title: Text('Historia aktywności'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.of(context).pushNamed('/history'),
          ),

          ListTile(
            leading: Icon(Icons.bar_chart, color: Colors.deepPurple),
            title: Text('Statystyki'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.of(context).pushNamed('/stats'),
          ),

          ListTile(
            leading: Icon(Icons.info_outline, color: Colors.deepPurple),
            title: Text('O aplikacji'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Move Reminder',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Move Reminder',
              );
            },
          ),
        ],
      ),
    );
  }
}
