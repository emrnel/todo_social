// lib/features/social/presentation/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/navigation/routes.dart';
import 'package:todo_social/features/social/presentation/providers/social_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
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
                final results = state.searchResults;
                if (state.isSearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.searchErrorMessage != null) {
                  return Center(
                      child: Text('Hata: ${state.searchErrorMessage}'));
                }
                if (results.isEmpty) {
                  return const Center(child: Text('Sonuç bulunamadı'));
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final user = results[index];
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text('@${user.username}'),
                      onTap: () =>
                          context.push(Routes.userProfilePath(user.username)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
