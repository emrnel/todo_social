// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_social/features/home/presentation/screens/my_todos_tab.dart';
import 'package:todo_social/features/home/presentation/screens/feed_tab.dart';
import 'package:todo_social/features/social/presentation/screens/search_screen.dart';
import 'package:todo_social/features/social/presentation/screens/user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final GlobalKey _fabKey = GlobalKey();

  // Ana ekranların listesi
  final List<Widget> _screens = const [
    MyTodosTab(),
    FeedTab(),
    _SearchTabWrapper(),
    _ProfileTabWrapper(),
  ];

  // AppBar başlıkları
  final List<String> _titles = const [
    'My Todos',
    'Feed',
    'Search',
    'My Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // FAB sadece My Todos ve Feed tab'larında görünsün
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton(
              key: _fabKey,
              onPressed: () async {
                final router = GoRouter.of(context);
                final RenderBox button =
                    _fabKey.currentContext!.findRenderObject() as RenderBox;
                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(Offset.zero, ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero),
                        ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );

                final value = await showMenu(
                  context: context,
                  position: position,
                  items: const [
                    PopupMenuItem(
                      value: 'todo',
                      child: Row(
                        children: [
                          Icon(Icons.check_box, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Add Todo')
                        ],
                      ),
                    ),
                    PopupMenuItem(
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
                );

                if (!mounted) return;
                if (value == 'todo') {
                  router.push('/add-todo');
                } else if (value == 'routine') {
                  router.push('/add-routine');
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
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
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Wrapper widget for SearchScreen to remove AppBar
class _SearchTabWrapper extends StatelessWidget {
  const _SearchTabWrapper();

  @override
  Widget build(BuildContext context) {
    return const SearchScreenContent();
  }
}

// Wrapper widget for ProfileScreen to remove AppBar
class _ProfileTabWrapper extends StatelessWidget {
  const _ProfileTabWrapper();

  @override
  Widget build(BuildContext context) {
    return const UserProfileScreen(username: null);
  }
}
