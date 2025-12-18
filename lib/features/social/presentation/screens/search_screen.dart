// lib/features/social/presentation/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/navigation/routes.dart';
import 'package:todo_social/features/social/presentation/providers/social_provider.dart';
import 'package:todo_social/features/auth/presentation/providers/auth_provider.dart';

// Standalone version with AppBar (for navigation from routes)
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
      ),
      body: const SearchScreenContent(),
    );
  }
}

// Content-only version (for use in tabs without AppBar)
class SearchScreenContent extends ConsumerStatefulWidget {
  const SearchScreenContent({super.key});

  @override
  ConsumerState<SearchScreenContent> createState() =>
      _SearchScreenContentState();
}

class _SearchScreenContentState extends ConsumerState<SearchScreenContent> {
  final _searchController = TextEditingController();

  void _performSearch(String query) {
    ref.read(socialProvider.notifier).searchUsers(query.trim());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Kullanıcı ara...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: _performSearch,
          ),
        ),
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(socialProvider);
              final authState = ref.watch(authProvider);
              final currentUserId = authState.currentUser?.id;

              // Filter out current user from search results
              final results = state.searchResults.where((user) {
                return currentUserId == null || user.id != currentUserId;
              }).toList();

              if (state.isSearchLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.searchErrorMessage != null) {
                return Center(child: Text('Hata: ${state.searchErrorMessage}'));
              }
              if (results.isEmpty && _searchController.text.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Kullanıcı aramak için yukarıdaki arama kutusunu kullanın',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }
              if (results.isEmpty) {
                return const Center(child: Text('Sonuç bulunamadı'));
              }
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final user = results[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Text(
                        user.username[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title: Text('@${user.username}'),
                    subtitle: Text(user.email ?? 'Email yok'),
                    onTap: () =>
                        context.push(Routes.userProfilePath(user.username)),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
