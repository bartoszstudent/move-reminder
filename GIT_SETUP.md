# 🚀 Wrzucenie na GitHub

Projekt jest już zainicjalizowany w git! Aby wrzucić na GitHub:

## Krok 1: Stwórz repozytorium na GitHub
1. Przejdź na https://github.com/new
2. Nazwijcie repozytorium: `move-reminder` (lub inną nazwę)
3. Ustaw opis: "Flutter app for activity tracking with background monitoring"
4. Zaznacz "Add a README file" - NIE (już mamy)
5. Kliknij "Create repository"

## Krok 2: Dodaj remote i push na GitHub
Po utworzeniu repozytorium, GitHub pokaże instrukcje. Uruchom:

```powershell
cd C:\Users\barte\projekt_pierwsza_wersja

# Dodaj remote (zamień USERNAME na twój GitHub login)
git remote add origin https://github.com/USERNAME/move-reminder.git

# Zmień branch na main (opcjonalnie)
git branch -M main

# Wrzuć kod
git push -u origin master
# lub jeśli zmieniliście na main:
# git push -u origin main
```

## Krok 3: Opcjonalnie - Setup SSH
Jeśli chcesz uniknąć logowania za każdym razem:

```powershell
# Wygeneruj SSH key
ssh-keygen -t ed25519 -C "bartecki557@gmail.com"

# Dodaj do GitHub: Settings → SSH and GPG keys → New SSH key
# Skopiuj zawartość pliku:
cat $env:USERPROFILE\.ssh\id_ed25519.pub

# Potem używaj:
git remote set-url origin git@github.com:USERNAME/move-reminder.git
```

## Przyszłe aktualizacje
```powershell
cd C:\Users\barte\projekt_pierwsza_wersja
git add .
git commit -m "Your message here"
git push
```

## 📝 Commit History
- `40d2f7d` - Initial commit: Move Reminder app with Firebase auth, step tracking, and background monitoring

Powodzenia! 🎉
