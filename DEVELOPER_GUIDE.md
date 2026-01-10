# Porada dla Dewelopera - Move Reminder

## Struktura projektu

Move Reminder jest aplikacją Flutter do monitorowania aktywności fizycznej. Projekt jest zorganizowany w następujący sposób:

### Główne katalogi:

- `lib/main.dart` - Punkt wejścia z routingiem
- `lib/models/` - Modele danych (User, Activity, Tips)
- `lib/services/` - Usługi biznesowe (Auth, Sensors, Activity, Tips, Notifications)
- `lib/screens/` - Ekrany UI (Login, Home, Settings, Stats, History)
- `lib/widgets/` - Komponenty do ponownego użytku
- `lib/utils/` - Narzędzia i stałe (możliwość dodania)

## Ścieżka programu - "Happy Path"

```
1. main.dart - Inicjalizacja Firebase i AuthWrapper
   ↓
2. AuthWrapper - Sprawdzenie czy użytkownik zalogowany
   ├─ NIE → LoginScreen
   │    ├─ Rejestracja nowego użytkownika (AuthService.signUp)
   │    └─ Lub zalogowanie (AuthService.signIn)
   │         → Dane zapisane w Firebase Auth + Firestore
   │
   └─ TAK → HomeScreen
        ├─ SensorService.getAccelerometerStream() - obsługa akcelerometru
        ├─ ActivityService.getTodayActivity() - pobranie dzisiejszych danych
        ├─ TipsService.getActivityTips() - porady z API
        ├─ NotificationService - powiadomienia
        │
        └─ Nawigacja:
             ├─ /settings → SettingsScreen
             │   └─ Zmiana celu i progu, łącze do historii i statystyk
             ├─ /history → HistoryScreen
             │   └─ Historia ostatniego tygodnia
             ├─ /stats → StatsScreen
             │   └─ Statystyki z 30 dni
             └─ Logout → wrócz do LoginScreen
```

## Kluczowe usługi

### AuthService
- `signUp()` - Rejestracja nowego użytkownika
- `signIn()` - Logowanie istniejącego użytkownika
- `signOut()` - Wylogowanie
- `getCurrentUser()` - Pobranie profilu bieżącego użytkownika
- `updateUserPreferences()` - Aktualizacja celu i progu

### SensorService
- `getAccelerometerStream()` - Stream z dane akcelerometru
- `detectSteps()` - Detekcja kroków z akcelerogramu
- `calculateCalories()` - Obliczanie spalonych kalorii
- `calculateIntensity()` - Poziom intensywności ruchu

### ActivityService
- `saveActivityData()` - Zapis dziennych danych
- `getTodayActivity()` - Pobranie dzisiejszych danych
- `getWeeklyActivity()` - Historia z ostatniego tygodnia
- `getActivityStats()` - Statystyki z 30 dni

### NotificationService
- `showInactivityNotification()` - Powiadomienie o bezruchu
- `showActivityTipNotification()` - Porada aktywności
- `showActivityGoalNotification()` - Osiągnięcie celu

### TipsService
- `getRandomActivityTip()` - Pobór porady z API
- `getActivityTips()` - Wiele porad
- `getDefaultTip()` - Fallback porady

## Przepływ danych

```
Firebase Auth ← → AuthService ← → User Model
                   ↓
Firestore ← → ActivityService ← → Activity Model
(users/{uid}/activities)          ↓
                                 HomeScreen
                                 (real-time update)
                                 ↓
                    SensorService ← Accelerometer
                    (krokami, kalorie, bezruch)
                    ↓
            NotificationService
            (powiadomienia)
```

## Jak dodać nową funkcjonalność

### 1. Nowy ekran
```dart
// 1. Utwórz screen w lib/screens/
class NewScreen extends StatefulWidget {
  @override
  State<NewScreen> createState() => _NewScreenState();
}

// 2. Dodaj route w main.dart
routes: {
  '/newroute': (context) => const NewScreen(),
}

// 3. Nawiguj z innego ekranu
Navigator.of(context).pushNamed('/newroute');
```

### 2. Nowa usługa
```dart
// 1. Utwórz serwis w lib/services/
class NewService {
  Future<Data> getData() async {
    // Implementacja
  }
}

// 2. Importuj w ekranach
import '../services/new_service.dart';

// 3. Użyj w State
final _service = NewService();
```

### 3. Nowy model
```dart
// 1. Utwórz model w lib/models/
class NewModel {
  Map<String, dynamic> toMap() {}
  factory NewModel.fromMap(Map<String, dynamic> map) {}
}
```

## Obsługa błędów

Każda usługa implementuje obsługę błędów:

```dart
try {
  // Operacja
  return result;
} catch (e) {
  print('Error: $e');
  return null; // lub domyślna wartość
}
```

W ekranach:
```dart
if (data == null) {
  return Center(child: Text('Błąd ładowania'));
}
```

## Performance Tips

1. **Akcelerometr**: Słucha w background, aktualnie w `initState`
2. **Firebase**: Używa Collections i Documents - struktura jest płytka
3. **Notifications**: Jedno powiadomienie na typ (ID: 0, 1, 2)
4. **API**: Bezruch może być problemem - dodaj timeout

## Przyszłe ulepszenia

1. **Provider State Management** - zastąpić setState
2. **Local Database** - SQLite dla offline support
3. **Background Service** - Keep tracking kiedy aplikacja jest zamknięta
4. **Wearables** - Integracja z smartwatchami
5. **Social Features** - Leaderboards, challenges
6. **ML/AI** - Automatyczne rozpoznawanie aktywności
7. **Map Integration** - Śledzenie trasy spacerów

## Testowanie

### Unit Tests
```dart
test('Step calculation', () {
  final sensor = SensorService();
  expect(sensor.calculateCalories(1000), 50.0);
});
```

### Integration Tests
```dart
testWidgets('Login flow', (tester) async {
  await tester.pumpWidget(MyApp());
  // Interakcje testowe
});
```

### Manual Testing Checklist
- [ ] Rejestracja nowego użytkownika
- [ ] Logowanie i logout
- [ ] Akcelerometr śledzí kroki (na urządzeniu!)
- [ ] Powiadomienia pojawiają się w prawo
- [ ] Historia pokazuje ostatni tydzień
- [ ] Statystyki są poprawne
- [ ] Ustawienia zapisują się w Firebase

## Debugowanie

### Firebase Emulator (lokalnie)
```bash
firebase emulators:start
```

### Flutter Debugger
```bash
flutter run -v  # Verbose logging
```

### Firebase Console
- Sprawdzaj Firestore Documents w real-time
- Sprawdzaj Logs w realtime

## Konwencje kodowania

- `PascalCase` dla klas i models
- `camelCase` dla zmiennych i funkcji
- `_privateMethod()` dla prywatnych metod
- Komentarze dla skomplikowanej logiki
- Maksimum 80 znaków na linię

## Bezpieczeństwo

- ✅ Firebase Auth - bezpieczne hasła
- ✅ Firestore Rules - tylko własne dane
- ⚠️ API Keys - hardcoded (w produkcji: environment variables)
- ⚠️ Sensor data - przechowywane w Firebase (można szyfrować)

---

**Autor**: Bartosz  
**Ostatnia aktualizacja**: Grudzień 2025
