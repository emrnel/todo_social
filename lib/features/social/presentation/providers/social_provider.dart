import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_service.dart';
import '../../../user/data/models/user_profile_model.dart';
import '../../../user/data/repositories/user_repository.dart';
import '../../../../data/models/user_model.dart';

// State
class SocialState {
  final List<UserModel> searchResults;
  final bool isSearchLoading;
  final UserProfileModel? userProfile;
  final bool isProfileLoading;
  final UserModel? currentUser;
  final bool isCurrentUserLoading;

  SocialState({
    this.searchResults = const [],
    this.isSearchLoading = false,
    this.userProfile,
    this.isProfileLoading = false,
    this.currentUser,
    this.isCurrentUserLoading = false,
  });

  SocialState copyWith({
    List<UserModel>? searchResults,
    bool? isSearchLoading,
    UserProfileModel? userProfile,
    bool? isProfileLoading,
    UserModel? currentUser,
    bool? isCurrentUserLoading,
  }) {
    return SocialState(
      searchResults: searchResults ?? this.searchResults,
      isSearchLoading: isSearchLoading ?? this.isSearchLoading,
      userProfile: userProfile ?? this.userProfile,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      currentUser: currentUser ?? this.currentUser,
      isCurrentUserLoading: isCurrentUserLoading ?? this.isCurrentUserLoading,
    );
  }
}

// Notifier
class SocialNotifier extends StateNotifier<SocialState> {
  final UserRepository _userRepository;

  SocialNotifier(this._userRepository) : super(SocialState());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: [], isSearchLoading: false);
      return;
    }
    state = state.copyWith(isSearchLoading: true);
    try {
      final users = await _userRepository.searchUsers(query);
      state = state.copyWith(searchResults: users, isSearchLoading: false);
    } catch (e) {
      state = state.copyWith(isSearchLoading: false, searchResults: []);
      // TODO: Handle error state in UI
    }
  }

  Future<void> fetchUserProfile(String username) async {
    state = state.copyWith(isProfileLoading: true);
    try {
      final profile = await _userRepository.getUserProfile(username);
      state = state.copyWith(userProfile: profile, isProfileLoading: false);
    } catch (e) {
      state = state.copyWith(isProfileLoading: false);
      // TODO: Handle error state in UI
    }
  }

  Future<void> toggleFollow() async {
    final originalProfile = state.userProfile;
    if (originalProfile == null) return;

    final newStatus = !originalProfile.isFollowing;
    final newFollowerCount = newStatus 
        ? originalProfile.followerCount + 1 
        : originalProfile.followerCount - 1;

    // Optimistic update
    state = state.copyWith(
      userProfile: originalProfile.copyWith(
        isFollowing: newStatus,
        followerCount: newFollowerCount,
      ),
    );

    try {
      if (newStatus) {
        await _userRepository.followUser(originalProfile.user.id);
      } else {
        await _userRepository.unfollowUser(originalProfile.user.id);
      }
    } catch (e) {
      // Revert on failure
      state = state.copyWith(userProfile: originalProfile);
      // TODO: Show an error message to the user
    }
  }

  Future<void> fetchMyProfile() async {
    state = state.copyWith(isCurrentUserLoading: true);
    try {
      final user = await _userRepository.getMyProfile();
      state = state.copyWith(currentUser: user, isCurrentUserLoading: false);
    } catch (e) {
      state = state.copyWith(isCurrentUserLoading: false);
      // TODO: Handle error state in UI
    }
  }
}

// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return UserRepository(dio);
});

// Provider for SocialNotifier
final socialProvider = StateNotifierProvider<SocialNotifier, SocialState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return SocialNotifier(userRepository);
});
