// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/core/navigation/routes.dart';
import 'package:todo_social/features/home/presentation/screens/my_todos_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey _fabKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Social'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          MyTodosTab(),
          Center(child: Text('Feed Tab')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {
          // Calculate position to show menu near the FAB
          final RenderBox button = _fabKey.currentContext!.findRenderObject() as RenderBox;
          final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
          final RelativeRect position = RelativeRect.fromRect(
            Rect.fromPoints(
              button.localToGlobal(Offset.zero, ancestor: overlay),
              button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
            ),
            Offset.zero & overlay.size,
          );

          showMenu(
            context: context,
            position: position,
            items: [
              const PopupMenuItem(
                value: 'todo',
                child: Row(
                  children: [
                    Icon(Icons.check_box, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Add Todo')
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'routine',
                child: Row(
                  children: [
                    Icon(Icons.repeat, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Add Routine')
                  ],
                ),
              ),
            ],
          ).then((value) {
            if (value == 'todo') {
              context.push('/add-todo');
            } else if (value == 'routine') {
              context.push('/add-routine');
            }
          });
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
