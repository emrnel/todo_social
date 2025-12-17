import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/features/feed/presentation/providers/feed_provider.dart';

class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({super.key});

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      Future.microtask(() => ref.read(feedProvider.notifier).fetchFeed());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);

    if (state.isLoading && state.feedItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.errorMessage != null && state.feedItems.isEmpty) {
      return Center(child: Text('Error: ${state.errorMessage}'));
    }
    if (state.feedItems.isEmpty) {
      return const Center(child: Text('Feed is empty'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: state.feedItems.length,
      itemBuilder: (context, index) {
        final item = state.feedItems[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(item.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@${item.username}'),
                if (item.description != null && item.description!.isNotEmpty)
                  Text(item.description!),
              ],
            ),
            trailing: Icon(
              item.isCompleted
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: item.isCompleted ? Colors.green : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}
