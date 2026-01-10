# Move Reminder

Aplikacja mobilna do monitorowania aktywności fizycznej z wykorzystaniem akcelerometru, powiadomieniami o bezruchu, porady fitness i systemem kont z Firebase.

## Cechy aplikacji

- **Monitorowanie Aktywności**: Śledzenie kroków i kalorii w czasie rzeczywistym za pomocą akcelerometru
- **Powiadomienia**: Automatyczne powiadomienia o przedłużonym bezruchu
- **Porady Fitness**: Codzienne porady aktywności z zewnętrznego API (Advice Slip API)
- **Logowanie i Konta**: Rejestracja i logowanie użytkowników przez Firebase
- **Statystyki**: Historia aktywności i szczegółowe statystyki z ostatnich 30 dni
- **Ustawienia**: Konfiguracja celu dziennych kroków i progu powiadomień
- **Interfejs**: Nowoczesny UI z Material Design

## Architektura

```
lib/
├── main.dart                    # Punkt wejścia aplikacji
├── firebase_options.dart        # Konfiguracja Firebase
├── models/                      # Modele danych
│   ├── user_model.dart
│   ├── activity_model.dart
│   └── tip_model.dart
├── services/                    # Usługi biznesowe
│   ├── auth_service.dart       # Autentykacja Firebase
│   ├── activity_service.dart   # Zarządzanie danymi aktywności
│   ├── sensor_service.dart     # Obsługa akcelerometru
│   ├── notification_service.dart # Powiadomienia
│   └── tips_service.dart       # Pobieranie porad
├── screens/                     # Ekrany aplikacji
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── settings_screen.dart
│   ├── stats_screen.dart
│   └── history_screen.dart
└── widgets/                     # Komponenty UI
    ├── activity_card.dart
    └── tip_card.dart
```

## Wymagania

- Flutter 3.9.2+
- Dart SDK
- Firebase Project
- Android 5.0+ / iOS 12.0+

## Instalacja

1. **Klonowanie repozytorium**
```bash
git clone <repo-url>
cd projekt_pierwsza_wersja
```

2. **Instalacja zależności**
```bash
flutter pub get
```

3. **Konfiguracja Firebase**

Wykonaj `flutterfire configure` aby skonfigurować Firebase dla twojego projektu:
```bash
flutterfire configure --project=move-reminder-project
```

Zastąp dummy keys w `lib/firebase_options.dart` rzeczywistymi wartościami z Firebase Console.

4. **Budowanie aplikacji**

Dla Androida:
```bash
flutter run --release
```

Dla iOS:
```bash
cd ios
pod install
cd ..
flutter run --release
```

## Zależności

- `firebase_core` - Inicjalizacja Firebase
- `firebase_auth` - Autentykacja użytkowników
- `cloud_firestore` - Baza danych
- `sensors_plus` - Dostęp do akcelerometru
- `flutter_local_notifications` - Powiadomienia
- `http` - HTTP requesty do API
- `provider` - State management
- `permission_handler` - Uprawnienia
- `fl_chart` - Wykresy
- `intl` - Obsługa dat

## Konfiguracja Firebase

### Firestore Database Structure

```
users/
├── {uid}/
│   ├── email: string
│   ├── displayName: string
│   ├── dailyActivityGoal: int (default: 10000)
│   ├── inactivityThreshold: int (default: 30)
│   ├── createdAt: timestamp
│   └── activities/ (subcollection)
│       └── {date}/
│           ├── steps: int
│           ├── calories: int
│           ├── inactivityMinutes: int
│           ├── activityPercentage: double
│           └── sessions: array
```

### Firebase Rules

Ustawić Security Rules dla Firestore:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      match /activities/{activity=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

## Uprawnienia

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

### iOS (Info.plist)
```xml
<key>NSMotionUsageDescription</key>
<string>Aplikacja potrzebuje dostępu do akcelerometru do śledzenia ruchu</string>
<key>NSUserNotificationUsageDescription</key>
<string>Aplikacja wysyła powiadomienia o nieaktywności</string>
```

## API Zewnętrzne

Aplikacja korzysta z:
- **Advice Slip API** - https://api.adviceslip.com/advice (publiczne, bez klucza)

## Główne funkcjonalności

### 1. Logowanie i Rejestracja
- Rejestracja nowych użytkowników
- Logowanie z email i hasłem
- Przechowywanie danych w Firebase Auth

### 2. Monitoring Aktywności
- Analiza akcelerometru
- Licznik kroków
- Obliczanie spalonych kalorii
- Śledzenie czasu bezruchu

### 3. Powiadomienia
- Powiadomienia o bezruchu
- Powiadomienia o osiągnięciu celu
- Porady aktywności

### 4. Historia i Statystyki
- Historia aktywności z ostatniego tygodnia
- Szczegółowe statystyki z 30 dni
- Sesje aktywności

### 5. Ustawienia
- Konfiguracja dziennego celu
- Konfiguracja progu powiadomień
- Wylogowywanie

## Użycie

### Ekran logowania
- Utwórz konto lub zaloguj się
- Email i hasło są wymagane

### Ekran główny
- Wyświetla dzisiejszą aktywność w czasie rzeczywistym
- Pokazuje kroki, kalorie, bezruch i postęp
- Lista porad aktywności

### Ustawienia
- Zmiana celu dziennych kroków
- Zmiana progu powiadomień o bezruchu
- Dostęp do historii i statystyk

### Historia
- Przegląd aktywności z ostatniego tygodnia
- Szczegóły sesji aktywności

### Statystyki
- Łączne kroki z 30 dni
- Średnia dzienna
- Spalone kalorie
- Liczba dni śledzonych

## Rozwijanie

### Dodawanie nowych ekranów
1. Utwórz nowy widget w `screens/`
2. Dodaj route w `main.dart`
3. Zaimplementuj logikę biznesową

### Dodawanie nowych usług
1. Utwórz nowy serwis w `services/`
2. Importuj w ekranach/widgetach
3. Użyj w `initState` lub построj

## Troubleshooting

### Firebase nie inicjalizuje się
- Sprawdź `firebase_options.dart` - klucze muszą być prawidłowe
- Uruchom `flutterfire configure` ponownie

### Akcelerometr nie działa
- Sprawdź uprawnienia w ustawieniach aplikacji
- Testuj na prawdziwym urządzeniu, nie w emulatorem

### Powiadomienia nie pojawiają się
- Sprawdź uprawnienia POST_NOTIFICATIONS
- Na Androidzie 13+ wymagane jest uprawnienie w runtime

## Licencja

MIT

## Autor

Bartosz

## Kontakt

Pytania? Utwórz Issue w repozytorium.
