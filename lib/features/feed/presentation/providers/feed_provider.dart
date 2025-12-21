import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/features/feed/data/models/feed_item_model.dart';
import 'package:todo_social/features/feed/data/repositories/feed_repository.dart';
import 'package:todo_social/core/api/api_service.dart';

class FeedState {
  final List<FeedItemModel> feedItems;
  final bool isLoading;
  final String? errorMessage;

  FeedState({
    this.feedItems = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FeedState copyWith({
    List<FeedItemModel>? feedItems,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FeedState(
      feedItems: feedItems ?? this.feedItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final FeedRepository _feedRepository;

  FeedNotifier(this._feedRepository) : super(FeedState());

  Future<void> fetchFeed() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _feedRepository.getFeed();
      state = state.copyWith(feedItems: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleLike(int todoId) async {
    final currentItem = state.feedItems.firstWhere(
      (item) => item.id == todoId && item.type == 'todo',
    );

    final isCurrentlyLiked = currentItem.isLiked ?? false;

    // Optimistic update
    final updatedItems = state.feedItems.map((item) {
      if (item.id == todoId && item.type == 'todo') {
        return item.copyWith(
          isLiked: !isCurrentlyLiked,
          likeCount: isCurrentlyLiked
              ? (item.likeCount ?? 1) - 1
              : (item.likeCount ?? 0) + 1,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(feedItems: updatedItems);

    try {
      if (isCurrentlyLiked) {
        await _feedRepository.unlikeTodo(todoId);
      } else {
        await _feedRepository.likeTodo(todoId);
      }
      // Refresh feed to get accurate data
      await fetchFeed();
    } catch (e) {
      // Revert on error
      state = state.copyWith(
        feedItems: state.feedItems,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return FeedRepository(dio);
});

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final feedRepository = ref.watch(feedRepositoryProvider);
  return FeedNotifier(feedRepository);
});
