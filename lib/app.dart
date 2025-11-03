// lib/app.dart
import 'package:flutter/material.dart';
import 'package:todo_social/features/splash/presentation/screens/splash_screen.dart'; // Import splash screen
import 'package:todo_social/features/auth/presentation/screens/login_screen.dart';   // Import login screen
import 'package:todo_social/features/home/presentation/screens/home_screen.dart';   // Import home screen
import 'package:todo_social/features/auth/presentation/screens/register_screen.dart';   // Import register screen


// This is the root widget 'App' that main.dart calls.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title used by the OS
      title: 'Todo Social', 
      
      // Hides the debug banner
      debugShowCheckedModeBanner: false, 
      
      // Defines the overall visual theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      // Define all named routes for navigation
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
         '/register': (context) => const RegisterScreen()
      },
      
      // The first route to show when the app starts
      initialRoute: '/', 
    );
  }
}
