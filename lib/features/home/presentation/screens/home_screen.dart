// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/navigation/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Social'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          Center(child: Text('My Todos Tab')),
          Center(child: Text('Feed Tab')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(Routes.addTodo);
        },
        child: const Icon(Icons.add),
      ),
      // FE-CORE-34: Add Search to BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // Needed for 4+ items
        onTap: (index) {
          if (index == 2) {
            // Search icon tapped
            context.go(Routes.search);
          } else if (index == 3) {
            // Profile icon tapped
            context.go(Routes.myProfile);
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'My Todos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Arama',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
