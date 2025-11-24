# Space Invaders - Deployment Guide

## Подготовка к деплою

### 1. Flutter Web

```bash
# Сборка для production
flutter build web --release

# Или с кастомным base href
flutter build web --release --base-href /space_invaders/
```

**Деплой на GitHub Pages:**
```bash
# После сборки
cd build/web
git init
git add .
git commit -m "Deploy Space Invaders"
git branch -M gh-pages
git remote add origin <your-repo-url>
git push -u origin gh-pages
```

**Деплой на Firebase Hosting:**
```bash
# Установить Firebase CLI
npm install -g firebase-tools

# Логин
firebase login

# Инициализация (если еще не инициализировано)
firebase init hosting

# Деплой
firebase deploy --only hosting
```

### 2. Android APK

```bash
# Сборка APK
flutter build apk --release

# Или APK bundle для Play Store
flutter build appbundle --release

# APK будет в: build/app/outputs/flutter-apk/app-release.apk
```

**Требования для Google Play Store:**
- Минимальный SDK: Android 21 (Android 5.0)
- Target SDK: Android 33+
- Signed APK с ключом
- Иконка приложения (уже есть в android/app/src/main/res/)
- Screenshots для Play Store

### 3. iOS

```bash
# Открыть проект в Xcode
open ios/Runner.xcworkspace

# Или собрать через командную строку (требует Mac)
flutter build ios --release
```

**Требования для App Store:**
- Mac с Xcode
- Apple Developer Account ($99/год)
- Signed app с provisioning profile
- Иконки приложения (уже настроены)
- App Store Connect настройки

### 4. Desktop (Windows/Mac/Linux)

**Windows:**
```bash
flutter build windows --release
# Результат в: build/windows/runner/Release/
```

**macOS:**
```bash
flutter build macos --release
# Результат в: build/macos/Build/Products/Release/
```

**Linux:**
```bash
flutter build linux --release
# Результат в: build/linux/x64/release/bundle/
```

### 5. Общие команды тестирования

Перед любым релизом прогоняем полный набор проверок:

```bash
# Юнит- и сервисные тесты
flutter test

# Интеграционные тесты (запускаются на подключённом эмуляторе/устройстве)
flutter test integration_test

# Анализ кода
flutter analyze
```

Файл `integration_test/game_flow_test.dart` проверяет базовый геймплей (старт игры и выстрел).

## Проверка перед деплоем

- [ ] Все тесты проходят: `flutter test`
- [ ] Анализ кода: `flutter analyze`
- [ ] Пройдены интеграционные тесты: `flutter test integration_test`
- [ ] Тестирование на реальных устройствах
- [ ] Проверка производительности
- [ ] Тестирование на разных размерах экрана
- [ ] Проверка звуков (включение/выключение)
- [ ] Проверка сохранения статистики
- [ ] Проверка настройки
- [ ] Проверка web-версии в основных браузерах (Chrome, Safari, Edge)
- [ ] Проверка нативных билдов (Android APK, iOS IPA, Windows/Mac/Linux) минимум на одном устройстве/эмуляторе

## Оптимизация

### Уменьшение размера APK

```bash
# Использовать split-per-abi для разных архитектур
flutter build apk --split-per-abi

# Это создаст отдельные APK для:
# - arm64-v8a (64-bit ARM)
# - armeabi-v7a (32-bit ARM)
# - x86_64 (64-bit x86)
```

### Оптимизация Web

```bash
# Minify и tree-shaking
flutter build web --release --web-renderer canvaskit

# Или использовать HTML renderer (меньше размер)
flutter build web --release --web-renderer html
```

## Версионирование

Обновить версию в `pubspec.yaml`:
```yaml
version: 1.0.0+1
# Формат: <version>+<build_number>
```

## Релиз чеклист

### Android
- [ ] Обновить version code в `pubspec.yaml`
- [ ] Обновить version name
- [ ] Собрать signed APK
- [ ] Проверить на разных устройствах
- [ ] Подготовить описание для Play Store
- [ ] Сделать скриншоты
- [ ] Загрузить в Play Console

### iOS
- [ ] Обновить version в `pubspec.yaml`
- [ ] Обновить build number в Xcode
- [ ] Archive в Xcode
- [ ] Проверить на реальных устройствах
- [ ] Подготовить для App Store Connect
- [ ] Загрузить через Xcode или Transporter

### Web
- [ ] Собрать production build
- [ ] Проверить на разных браузерах
- [ ] Проверить адаптивность
- [ ] Оптимизировать размер
- [ ] Задеплоить на хостинг
- [ ] Проверить доступность

## CI/CD (опционально)

### GitHub Actions пример

Создать `.github/workflows/build.yml`:
```yaml
name: Build and Deploy

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build web --release
      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

## Полезные ссылки

- [Flutter Deployment](https://docs.flutter.dev/deployment)
- [Android Deployment](https://docs.flutter.dev/deployment/android)
- [iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [Web Deployment](https://docs.flutter.dev/deployment/web)

