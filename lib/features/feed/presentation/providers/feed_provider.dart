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
}

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return FeedRepository(dio);
});

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final feedRepository = ref.watch(feedRepositoryProvider);
  return FeedNotifier(feedRepository);
});
