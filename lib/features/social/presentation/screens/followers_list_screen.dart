import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/api/api_service.dart';

class FollowersListScreen extends ConsumerStatefulWidget {
  final int userId;
  final String username;
  final bool isFollowers; // true for followers, false for following

  const FollowersListScreen({
    super.key,
    required this.userId,
    required this.username,
    this.isFollowers = true,
  });

  @override
  ConsumerState<FollowersListScreen> createState() => _FollowersListScreenState();
}

class _FollowersListScreenState extends ConsumerState<FollowersListScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final endpoint = widget.isFollowers
          ? '/social/users/${widget.userId}/followers'
          : '/social/users/${widget.userId}/following';

      final response = await apiService.get(endpoint);
      final data = response.data as Map<String, dynamic>;

      if (data['success'] == true) {
        setState(() {
          users = widget.isFollowers
              ? (data['data']['followers'] as List)
              : (data['data']['following'] as List);
          isLoading = false;
        });
      } else {
        setState(() {
          error = data['message'] ?? 'Bir hata oluştu';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFollowers
              ? '${widget.username} - Takipçiler'
              : '${widget.username} - Takip Edilenler',
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Hata: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchUsers,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.isFollowers ? Icons.people_outline : Icons.person_add_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.isFollowers
                                ? 'Henüz takipçi yok'
                                : 'Henüz kimseyi takip etmiyor',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user['profilePicture'] != null
                                ? NetworkImage(user['profilePicture'])
                                : null,
                            child: user['profilePicture'] == null
                                ? Text(user['username'][0].toUpperCase())
                                : null,
                          ),
                          title: Text(
                            user['username'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: user['bio'] != null ? Text(user['bio']) : null,
                          onTap: () {
                            // Navigate to user profile
                            Navigator.pushNamed(
                              context,
                              '/user-profile',
                              arguments: user['id'],
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
