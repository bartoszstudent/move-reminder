# Konfiguracja Firebase dla Move Reminder

## Kroki konfiguracji

### 1. Utwórz Firebase Project

1. Przejdź do [Firebase Console](https://console.firebase.google.com)
2. Kliknij "Utwórz projekt"
3. Nazwij projekt: `move-reminder-project`
4. Postępuj zgodnie z instrukcjami

### 2. Dodaj aplikacje

#### Android:
1. W Firebase Console kliknij "Dodaj aplikację" → Android
2. Pakiet: `com.example.projekt_pierwsza_wersja`
3. Pobierz `google-services.json`
4. Umieść w `android/app/`

#### iOS:
1. W Firebase Console kliknij "Dodaj aplikację" → iOS
2. Bundle ID: `com.example.projektPierwszaWersja`
3. Pobierz `GoogleService-Info.plist`
4. Otwórz `ios/Runner.xcworkspace` w Xcode
5. Dodaj plik do Xcode (File → Add Files to Runner)

#### Web (opcjonalnie):
1. W Firebase Console kliknij "Dodaj aplikację" → Web
2. Skopiuj config
3. Umieść klucze w `lib/firebase_options.dart`

### 3. Konfiguruj FlutterFire

```bash
# Zainstaluj CLI
dart pub global activate flutterfire_cli

# Skonfiguruj projekt
flutterfire configure --project=move-reminder-project
```

To automatycznie zaktualizuje `lib/firebase_options.dart`.

### 4. Włącz usługi Firebase

W Firebase Console (Project Settings):

- **Authentication**:
  - Włącz "Email/Password"
  
- **Firestore Database**:
  - Utwórz bazę danych w trybie produkcji
  - Ustaw lokalizację: `europe-west1` lub bliżej
  - Skopiuj Security Rules poniżej

- **Realtime Database** (opcjonalnie):
  - Możesz wyłączyć

### 5. Firestore Security Rules

W Firebase Console → Firestore Database → Reguły:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Użytkownicy mogą czytać i pisać tylko swoje dane
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Subcollection aktywności
      match /activities/{activity=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

### 6. Dodaj uprawnienia

#### Android (android/app/src/main/AndroidManifest.xml):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

#### iOS (ios/Runner/Info.plist):

```xml
<key>NSMotionUsageDescription</key>
<string>Aplikacja potrzebuje dostępu do akcelerometru do monitorowania ruchu i kroków.</string>

<key>NSUserNotificationUsageDescription</key>
<string>Aplikacja wysyła powiadomienia o długim bezruchu.</string>

<key>UIBackgroundModes</key>
<array>
  <string>processing</string>
</array>
```

### 7. Konfiguracja natywna

#### Android (android/build.gradle):

Upewnij się, że máš:
```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}

plugins {
  id 'com.google.gms.google-services' version '4.3.15' apply false
}
```

#### Android (android/app/build.gradle):

```gradle
apply plugin: 'com.google.gms.google-services'
```

#### iOS (ios/Podfile):

Upewnij się, że target `Runner` ma:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_SENSORS=1',
        'PERMISSION_NOTIFICATIONS=1',
      ]
    end
  end
end
```

## Testowanie

### 1. Zainstaluj zależności
```bash
flutter pub get
```

### 2. Uruchom na emulatorze/urządzeniu
```bash
flutter run -v
```

### 3. Testy Firebase

1. Stwórz test account w Firebase Console
2. Zaloguj się w aplikacji
3. Sprawdź czy dane pojawiają się w Firestore
4. Testuj akcelerometr (na prawdziwym urządzeniu!)

## Rozwiązywanie problemów

### Błąd: "Could not find com.google.gms:google-services"
- Sprawdź `android/build.gradle` - brakuje dependency

### Błąd: "Permission denied" w Firestore
- Sprawdź Security Rules - mogą być zbyt restrykcyjne

### Akcelerometr zwraca 0
- Testuj na prawdziwym urządzeniu
- Sprawdź uprawnienia w ustawieniach

### Powiadomienia nie działają
- Android 13+: wymagane uprawnienie POST_NOTIFICATIONS
- iOS: sprawdź Info.plist

## Zmienne środowiskowe (opcjonalnie)

Możesz dodać `.env` file (z `flutter_dotenv`):

```env
FIREBASE_PROJECT_ID=move-reminder-project
API_ENDPOINT=https://api.adviceslip.com
```

## Wdrażanie

Gdy wszystko działa:

1. Zbuduj APK/AAB dla Android
2. Zbuduj IPA dla iOS
3. Wgraj do Google Play / App Store

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Wsparcie

Jeśli masz problemy:
1. Sprawdź logs: `flutter run -v`
2. Sprawdź Firebase Console
3. Czytaj dokumentację FlutterFire
