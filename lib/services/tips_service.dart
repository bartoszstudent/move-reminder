import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/tip_model.dart';

class TipsService {
  static const String _apiBaseUrl = 'https://api.adviceslip.com/advice';

  Future<ActivityTip?> getRandomActivityTip() async {
    try {
      final response = await http
          .get(Uri.parse(_apiBaseUrl))
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => throw Exception('API timeout'),
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final slip = json['slip'];

        // Konwersja ogólnej porady na poradę aktywności
        return ActivityTip(
          id: slip['slip_id'].toString(),
          title: 'Porada aktywności',
          description: slip['advice'],
          category: 'motywacja',
          durationMinutes: 15,
          caloriesBurned: 100,
          imageUrl: '',
        );
      }
      return null;
    } catch (e) {
      print('Get tip error: $e');
      return null;
    }
  }

  Future<List<ActivityTip>> getActivityTips() async {
    try {
      final tips = <ActivityTip>[];

      // Pobierz kilka porad
      for (int i = 0; i < 3; i++) {
        final tip = await getRandomActivityTip();
        if (tip != null) {
          tips.add(tip);
        }
      }

      return tips;
    } catch (e) {
      print('Get tips error: $e');
      return [];
    }
  }

  // Alternatywne porawy w przypadku braku dostępu do API
  static const List<Map<String, dynamic>> _defaultTips = [
    {
      'title': 'Spacer',
      'description':
          'Zrób 15-minutowy spacer. Wstań z siedzenia i przejdź się.',
      'category': 'cardio',
      'durationMinutes': 15,
      'caloriesBurned': 80,
    },
    {
      'title': 'Rozciąganie',
      'description': 'Wykonaj ćwiczenia rozciągające przez 10 minut.',
      'category': 'elastyczność',
      'durationMinutes': 10,
      'caloriesBurned': 30,
    },
    {
      'title': 'Schody',
      'description': 'Wchodzenie i schodzenie po schodach przez 10 minut.',
      'category': 'cardio',
      'durationMinutes': 10,
      'caloriesBurned': 120,
    },
    {
      'title': 'Joga',
      'description': 'Proste ćwiczenia jogi poprawiające równowagę.',
      'category': 'elastyczność',
      'durationMinutes': 20,
      'caloriesBurned': 60,
    },
    {
      'title': 'Taniec',
      'description': 'Tańcz do ulubionej piosenki przez 15 minut.',
      'category': 'cardio',
      'durationMinutes': 15,
      'caloriesBurned': 150,
    },
  ];

  static ActivityTip getDefaultTip(int index) {
    final tip = _defaultTips[index % _defaultTips.length];
    return ActivityTip(
      id: 'default_$index',
      title: tip['title'],
      description: tip['description'],
      category: tip['category'],
      durationMinutes: tip['durationMinutes'],
      caloriesBurned: tip['caloriesBurned'],
      imageUrl: '',
    );
  }
}
