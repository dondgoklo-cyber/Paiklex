# Monolith Task Manager

![Monolith Logo](https://img.shields.io/badge/Monolith-Task_Manager-4285F4?style=for-the-badge)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?logo=dart)](https://dart.dev)

**Local-First Task Manager for all platforms** - Your tasks, projects, habits, and reminders, always with you, even offline.

---

## 📋 Features

### ✅ Core Features
- **Tasks** - Create, edit, delete, and organize tasks with rich metadata
- **Projects** - Organize tasks into projects with custom colors
- **Habits** - Build and track habits with streak counting
- **Reminders** - Set time-based notifications for tasks and habits
- **Kanban View** - Visual task management with drag-and-drop
- **Calendar View** - See tasks and events on a calendar
- **Search** - Full-text search across tasks with tag filtering
- **Inbox** - Quick access to unorganized tasks

### ✅ Advanced Features
- **Priority Levels** - P1 (Urgent) to P4 (Low) priority system
- **Subtasks** - Two levels of nested tasks
- **Tags** - Flexible categorization with filtering
- **Recurring Tasks** - Daily, weekly, monthly, yearly repetition
- **Deadlines** - Today, tomorrow, yesterday, overdue indicators
- **Streak Tracking** - Keep track of consecutive habit completions
- **Undo Support** - Undo delete, archive, and complete actions
- **Local Notifications** - Get notified about upcoming tasks

### ✅ Platform Support
- ✅ Android
- ✅ iOS
- ✅ Web (PWA)
- ✅ Windows
- ✅ macOS
- ✅ Linux

---

## 🏗️ Architecture

### Clean Architecture Layers
```
lib/
├── core/                    # Core utilities and base classes
│   ├── errors/             # Failure types and error handling
│   ├── utils/              # Logger, date utils, NLP parser, undo manager
│   └── constants/          # App constants
│
├── database/               # Database layer
│   ├── app_database.dart   # Drift database with all tables
│   └── migrations.dart     # Database migrations
│
├── features/               # Feature modules
│   ├── tasks/              # Tasks feature
│   │   ├── domain/         # Entities, repositories, use cases
│   │   ├── data/           # Models, data sources, repositories impl
│   │   └── presentation/   # Cubits, widgets, screens
│   │
│   ├── projects/           # Projects feature
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   │
│   ├── habits/             # Habits feature
│   ├── reminders/          # Reminders feature
│   ├── kanban/             # Kanban view
│   ├── calendar_view/      # Calendar view
│   ├── search/             # Search feature
│   └── settings/           # Settings feature
│
├── shared/                 # Shared widgets and utilities
│   ├── widgets/            # Reusable widgets
│   └── theme/              # App theming
│
└── app/                    # App configuration
    ├── di.dart             # Dependency injection
    ├── router.dart         # GoRouter configuration
    └── app.dart            # Main app widget
```

### Key Technologies
- **State Management**: `flutter_bloc` + `equatable`
- **Database**: `Drift` (MOOR) with SQLite
- **Routing**: `go_router`
- **DI**: Manual `GetIt` (no code generation)
- **Functional**: `fpdart` for Either pattern
- **Notifications**: `flutter_local_notifications` + `timezone`
- **Calendar**: `table_calendar`
- **Localization**: `flutter_gen` with ARB files
- **File Operations**: `file_picker` + `share_plus`

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.19+
- Dart SDK 3.3+
- Android Studio / Xcode / VS Code

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/dondgoklo-cyber/Paiklex.git
   cd Paiklex
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code:**
   ```bash
   flutter gen-l10n
   dart run build_runner build
   ```

4. **Run the app:**
   ```bash
   # Android
   flutter run -d android
   
   # iOS
   flutter run -d ios
   
   # Web
   flutter run -d chrome
   
   # Windows
   flutter run -d windows
   
   # macOS
   flutter run -d macos
   
   # Linux
   flutter run -d linux
   ```

---

## 📦 Building for Production

### Android
```bash
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
# Open Xcode and archive from there
```

### Web
```bash
flutter build web --release
# Files will be at: build/web/
```

### Windows
```bash
flutter build windows --release
# Executable will be at: build/windows/x64/runner/Release/
```

### macOS
```bash
flutter build macos --release
# App will be at: build/macos/Build/Products/Release/
```

### Linux
```bash
flutter build linux --release
# Executable will be at: build/linux/x64/release/bundle/
```

---

## 📝 Usage

### Quick Start
1. Launch the app
2. Tap the **+** button to add your first task
3. Use the bottom navigation to switch between views
4. Swipe left/right on tasks to delete or complete

### Keyboard Shortcuts (Desktop)
- `Ctrl/Cmd + N` - New task
- `Ctrl/Cmd + F` - Search
- `Ctrl/Cmd + ,` - Settings
- `Delete` - Delete selected task
- `Space` - Toggle task completion

### Gestures (Mobile)
- **Swipe left** - Delete task
- **Swipe right** - Complete task
- **Long press** - Multi-select mode
- **Pull down** - Refresh

---

## 🎨 Theming

The app supports:
- **Light Mode** - Clean, bright interface
- **Dark Mode** - Easy on the eyes at night
- **System Mode** - Follows system preference
- **Custom Colors** - Per-project color customization

---

## 🌍 Localization

Supported languages:
- **English** (en)
- **Russian** (ru)

To add a new language:
1. Add a new ARB file in `lib/l10n/`
2. Add translations for all keys
3. Run `flutter gen-l10n`

---

## 📊 NLP Parsing

The app supports natural language parsing for task creation:

### English Examples
- "Buy milk tomorrow" → Due: tomorrow
- "Call mom every Monday" → Recurring: weekly (Monday)
- "Finish project #work #urgent" → Tags: work, urgent
- "High priority task" → Priority: High
- "In 2 hours" → Due: current time + 2 hours

### Russian Examples
- "Купить молоко завтра" → Срок: завтра
- "Позвонить маме каждый понедельник" → Повтор: еженедельно (понедельник)
- "Завершить проект #работа #срочно" → Теги: работа, срочно
- "Высокий приоритет" → Приоритет: Высокий
- "Через 2 часа" → Срок: текущее время + 2 часа

---

## 🔄 Sync Across Devices

### Export Data
1. Go to **Settings** → **Data**
2. Tap **Export Data**
3. Choose location and save JSON file

### Import Data
1. Go to **Settings** → **Data**
2. Tap **Import Data**
3. Select the JSON file to import

### Auto-Sync (Future)
- Cloud sync coming soon
- End-to-end encrypted
- Conflict resolution

---

## 📈 Performance Metrics

| Metric | Target | Status |
|--------|--------|--------|
| APK Size | < 25MB | ✅ |
| Cold Start | < 2s | ✅ |
| Scroll FPS | ≥ 55 | ✅ |
| Offline Support | 100% | ✅ |

---

## 🧪 Testing

Run all tests:
```bash
flutter test
```

Run unit tests:
```bash
flutter test test/
```

Run widget tests:
```bash
flutter test test/features/
```

Run integration tests:
```bash
flutter test integration_test/
```

---

## 🤝 Contributing

### Code Style
- Follow existing code patterns
- Use `lowerCamelCase` for variables and functions
- Use `PascalCase` for classes and types
- Use `snake_case` for file names
- Always use `final` for immutable variables
- Use `const` constructors where possible

### Rules
- ❌ No `print()` - Use `AppLogger` instead
- ❌ No `@injectable` - Use manual `GetIt`
- ❌ No `freezed` - Use manual `copyWith`
- ❌ No `while(true)` in Streams
- ❌ No `File()` without `kIsWeb` check
- ❌ No `DateTime.now()` in DB without `.toUtc()`
- ❌ No paid packages
- ✅ All tables use `@DataClassName`
- ✅ All dates in UTC in database
- ✅ All UI dates use `.toLocal()`
- ✅ All strings use `AppLocalizations`
- ✅ All navigation uses `context.push()`

### Commit Messages
Use conventional commits:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `test:` - Test changes
- `chore:` - Build/config changes

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Inspired by GTD methodology
- Designed for productivity

---

## 📞 Contact

For questions, issues, or feedback:
- GitHub: [dondgoklo-cyber/Paiklex](https://github.com/dondgoklo-cyber/Paiklex)
- Issues: [GitHub Issues](https://github.com/dondgoklo-cyber/Paiklex/issues)
- Discussions: [GitHub Discussions](https://github.com/dondgoklo-cyber/Paiklex/discussions)

---

**Made with ❤️ and Flutter**
