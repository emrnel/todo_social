import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_service.dart';
import '../../data/models/feed_item_model.dart';
import '../../data/repositories/feed_repository.dart';

class FeedState {
  final List<FeedItemModel> feedItems;
  final bool isLoading;

  FeedState({
    this.feedItems = const [],
    this.isLoading = false,
  });

  FeedState copyWith({
    List<FeedItemModel>? feedItems,
    bool? isLoading,
  }) {
    return FeedState(
      feedItems: feedItems ?? this.feedItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final FeedRepository _feedRepository;

  FeedNotifier(this._feedRepository) : super(FeedState());

  Future<void> fetchFeed() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _feedRepository.getFeed();
      state = state.copyWith(feedItems: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // TODO: Handle error state in UI
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
