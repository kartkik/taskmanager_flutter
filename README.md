# Flutter Task Manager App 📱

A modern, offline-first Flutter **Task Manager** application powered by **Firebase Cloud Firestore** and **Hive Local Persistent Storage**, built with state-of-the-art Material 3 UI/UX design and **Provider** state management.

---

## ✨ Key Features & Capabilities

### 1. 📝 Comprehensive Task Management (CRUD)
- **Create Tasks**: Set title, description, priority, and due date/time.
- **Edit Tasks**: Update existing task details in real-time.
- **Delete Tasks**: Swipe-to-delete with confirmation dialog and undo snackbar notifications.
- **Mark Completion**: Toggle task completion with visual strike-through and badge updates.
- **Task Details View**: Detailed metadata breakdown including creation date, last updated date, due date status, and sync status.

### 2. ⚡ Offline-First Architecture & Bidirectional Firestore Sync
- **Local Storage (Hive)**: Tasks are instantly saved locally in Hive NoSQL database, ensuring 100% responsiveness and offline availability.
- **Firebase Cloud Firestore Sync**: When internet connectivity is active, changes seamlessly sync with Cloud Firestore.
- **Automatic Re-connection Sync**: Network status is monitored using `connectivity_plus`. When connectivity is restored after working offline, pending changes are automatically uploaded to Firestore.
- **Sync Status Banner**: Visible status indicator displaying connection state (`Online`, `Offline Mode`, `Syncing...`, `Unsynced changes count`).

### 3. 🔍 Local Search, Filter & Sort
- **Real-Time Search**: Instant search by task title or description.
- **Status Filtering**: Filter tasks by `All`, `Pending`, or `Completed`.
- **Multi-Field Sorting**: Sort tasks by `Due Date`, `Priority (High → Low)`, `Created Date`, or `Title`.
- **Zero Network Overhead**: All search, filtering, and sorting execute locally in memory without triggering expensive remote Firestore calls.

### 4. 🎨 Premium Material 3 UI / UX Design
- **Custom Color System**: Modern Slate & Indigo palette with vibrant priority indicators (Emerald Green, Amber, Crimson Red).
- **Dark Mode & Light Mode**: Seamless dark mode support using `ThemeProvider`.
- **Rich Typography**: Styled using `GoogleFonts` Inter font family.
- **Interactive Feedback**: Micro-animations, dismissible swipe cards, empty state illustrations, and loading feedback.

---

## 🏗️ Architecture & Project Structure

The project follows a clean, layered architecture separating UI, State Management, Data Repositories, and Core Services:

```
lib/
├── main.dart                      # App entry point, Service & Provider setup
├── firebase_options.dart          # Firebase project credentials & configuration
├── models/
│   ├── task_model.dart            # Task Dart model & JSON/Firestore serializers
│   ├── task_priority.dart        # Priority enum (low, medium, high) with colors & icons
│   └── task_filter.dart          # Filter & Sort enums
├── services/
│   ├── local_storage_service.dart # Hive database CRUD & local persistence
│   ├── firebase_service.dart      # Remote Firestore collection & stream handlers
│   ├── connectivity_service.dart  # connectivity_plus network monitoring
│   └── sync_service.dart          # Bidirectional offline/online sync manager
├── repositories/
│   └── task_repository.dart       # Single source of truth (Hive + Firestore sync)
├── providers/
│   ├── task_provider.dart         # Task state, search, filter, and sort logic
│   └── theme_provider.dart        # Theme mode state (Light, Dark, System)
├── ui/
│   ├── theme/
│   │   ├── app_colors.dart        # Color palette & gradient definitions
│   │   └── app_theme.dart         # Material 3 light and dark theme data
│   ├── screens/
│   │   ├── task_list_screen.dart   # Main dashboard with search, filters, task cards
│   │   ├── add_edit_task_screen.dart # Validated task form with date/time picker
│   │   ├── task_detail_screen.dart # Complete task metadata & action buttons
│   │   └── settings_screen.dart    # Theme selector, network status & statistics
│   └── widgets/
│       ├── task_card.dart          # Dismissible task list item tile
│       ├── sync_banner.dart        # Top connectivity & sync banner
│       ├── filter_bar.dart         # Filter status chips & sort selector
│       ├── priority_badge.dart     # Priority level tag badge
│       └── empty_task_state.dart   # Zero-state illustration widget
└── utils/
    └── date_formatter.dart        # Human-readable date & overdue formatting helpers
```

---

## 🔥 Firebase Setup & Configuration

This app is pre-configured to connect to Firebase Cloud Firestore. Credentials are stored in `lib/firebase_options.dart`.

To connect your own Firebase project:
1. Open `lib/firebase_options.dart`.
2. Replace `apiKey`, `appId`, `messagingSenderId`, `projectId`, and `storageBucket` with your Firebase Web credentials.
3. In Firebase Console $\rightarrow$ **Firestore Database** $\rightarrow$ **Rules**, allow read/write access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.10+ recommended)
- Dart SDK 3.10+
- Android Studio / VS Code with Flutter extension

### Installation & Run Instructions

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/<your-username>/taskmanager.git
   cd taskmanager
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Unit Tests**:
   ```bash
   flutter test
   ```

4. **Launch the Application**:
   ```bash
   flutter run
   ```

---

## 🧪 Unit Testing

The codebase includes unit tests verifying task serialization (`fromJson`/`toJson`), model immutability, date formatting, and filter/sort logic:

```bash
flutter test
```

---

## 🛠️ Technologies Used
- **Framework**: Flutter & Dart (Null Safety)
- **State Management**: `provider`
- **Local Persistence**: `hive` & `hive_flutter`
- **Remote Database**: `cloud_firestore` & `firebase_core`
- **Network Status**: `connectivity_plus`
- **Date Formatting**: `intl`
- **Typography**: `google_fonts`
- **UUID Generation**: `uuid`
