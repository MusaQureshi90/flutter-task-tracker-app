import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/storage_helper.dart';
import 'providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isLoggedIn = await StorageHelper.getLoginState();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: InternshipApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class InternshipApp extends StatefulWidget {
  final bool isLoggedIn;
  const InternshipApp({super.key, required this.isLoggedIn});

  @override
  State<InternshipApp> createState() => _InternshipAppState();
}

class _InternshipAppState extends State<InternshipApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Tracker | Flutter',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      home: widget.isLoggedIn
          ? HomeScreen(toggleTheme: toggleTheme)
          : LoginScreen(
              onLogin: () async {
                await StorageHelper.saveLoginState(true);
                if (!context.mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(toggleTheme: toggleTheme),
                  ),
                );
              },
            ),
    );
  }
}