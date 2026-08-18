import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/task_repository.dart';
import 'services/connectivity_service.dart';
import 'services/firebase_service.dart';
import 'services/local_storage_service.dart';
import 'services/sync_service.dart';
import 'ui/screens/task_list_screen.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Local Storage (Hive)
  final localStorageService = LocalStorageService();
  await localStorageService.init();

  // 2. Initialize Firebase (if valid options provided)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase connected successfully!');

    // Bonus: Anonymous authentication for Firestore security compliance
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
        debugPrint('Signed in anonymously to Firebase Auth');
      }
    } catch (authError) {
      debugPrint('Anonymous auth notice: $authError');
    }
  } catch (e) {
    debugPrint('Firebase initialization notice (running local storage mode): $e');
  }

  // 3. Initialize Core Services & Repository
  final firebaseService = FirebaseService();
  final connectivityService = ConnectivityService();
  final syncService = SyncService(
    localStorageService: localStorageService,
    firebaseService: firebaseService,
  );

  final taskRepository = TaskRepository(
    localStorageService: localStorageService,
    firebaseService: firebaseService,
    connectivityService: connectivityService,
    syncService: syncService,
  );

  runApp(
    MyApp(
      taskRepository: taskRepository,
      connectivityService: connectivityService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final TaskRepository taskRepository;
  final ConnectivityService connectivityService;

  const MyApp({
    super.key,
    required this.taskRepository,
    required this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            repository: taskRepository,
            connectivityService: connectivityService,
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Task Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const TaskListScreen(),
          );
        },
      ),
    );
  }
}
