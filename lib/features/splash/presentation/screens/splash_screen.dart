import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: Import storage and auth services later

// This screen checks authentication status and navigates.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the auth check immediately
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Simulate checking for a token
    await Future.delayed(const Duration(seconds: 2)); 

    // TODO: Read token from secure storage.
    // final token = await ref.read(storageServiceProvider).readToken();
    const String? token = null; // Assume not logged in for now

    // Check if the widget is still mounted before navigating
    if (!mounted) return;

    if (token != null) {
      // If token exists, go to home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // If no token, go to login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // A simple loading indicator UI
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
