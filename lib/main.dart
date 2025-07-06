import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localstorage/localstorage.dart';
import 'providers/time_entry_provider.dart';
import 'providers/project_task_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final LocalStorage projectStorage = LocalStorage('projects');
  final LocalStorage taskStorage = LocalStorage('tasks');
  final LocalStorage timeEntryStorage = LocalStorage('time_entries');

  // Attendre que le stockage soit prêt
  await projectStorage.ready;
  await taskStorage.ready;
  await timeEntryStorage.ready;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProjectTaskProvider(
            projectStorage: projectStorage,
            taskStorage: taskStorage,
          )..loadData(),
        ),
        ChangeNotifierProvider(
          create: (context) => TimeEntryProvider(
            storage: timeEntryStorage,
          )..loadData(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Time Tracker',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}