import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/api/api_service.dart';
import 'package:todo_social/features/user/data/models/user_profile_model.dart';
import 'package:todo_social/features/user/data/repositories/user_repository.dart';
import 'package:todo_social/data/models/user_model.dart';

// State
class SocialState {
  final List<UserModel> searchResults;
  final bool isSearchLoading;
  final String? searchErrorMessage;
  final UserProfileModel? userProfile;
  final bool isProfileLoading;
  final String? profileErrorMessage;
  final UserModel? currentUser;
  final bool isCurrentUserLoading;
  final List<int> followingUserIds; // NEW: Track following user IDs

  SocialState({
    this.searchResults = const [],
    this.isSearchLoading = false,
    this.searchErrorMessage,
    this.userProfile,
    this.isProfileLoading = false,
    this.profileErrorMessage,
    this.currentUser,
    this.isCurrentUserLoading = false,
    this.followingUserIds = const [], // NEW
  });

  SocialState copyWith({
    List<UserModel>? searchResults,
    bool? isSearchLoading,
    String? searchErrorMessage,
    UserProfileModel? userProfile,
    bool? isProfileLoading,
    String? profileErrorMessage,
    UserModel? currentUser,
    bool? isCurrentUserLoading,
    List<int>? followingUserIds, // NEW
  }) {
    return SocialState(
      searchResults: searchResults ?? this.searchResults,
      isSearchLoading: isSearchLoading ?? this.isSearchLoading,
      searchErrorMessage: searchErrorMessage ?? this.searchErrorMessage,
      userProfile: userProfile ?? this.userProfile,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      profileErrorMessage: profileErrorMessage ?? this.profileErrorMessage,
      currentUser: currentUser ?? this.currentUser,
      isCurrentUserLoading: isCurrentUserLoading ?? this.isCurrentUserLoading,
      followingUserIds: followingUserIds ?? this.followingUserIds, // NEW
    );
  }
}

// Notifier
class SocialNotifier extends StateNotifier<SocialState> {
  final UserRepository _userRepository;

  SocialNotifier(this._userRepository) : super(SocialState());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(
          searchResults: [], isSearchLoading: false, searchErrorMessage: null);
      return;
    }
    state = state.copyWith(isSearchLoading: true, searchErrorMessage: null);
    try {
      final users = await _userRepository.searchUsers(query);
      state = state.copyWith(searchResults: users, isSearchLoading: false);
    } catch (e) {
      state = state.copyWith(
          isSearchLoading: false,
          searchResults: [],
          searchErrorMessage: e.toString());
    }
  }

  Future<void> fetchUserProfile(String username) async {
    state = state.copyWith(isProfileLoading: true, profileErrorMessage: null);
    try {
      final profile = await _userRepository.getUserProfile(username);
      state = state.copyWith(userProfile: profile, isProfileLoading: false);
    } catch (e) {
      state = state.copyWith(
          isProfileLoading: false, profileErrorMessage: e.toString());
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

    // Update following list
    List<int> newFollowingIds = List.from(state.followingUserIds);
    if (newStatus) {
      newFollowingIds.add(originalProfile.user.id);
    } else {
      newFollowingIds.remove(originalProfile.user.id);
    }
    state = state.copyWith(followingUserIds: newFollowingIds);

    try {
      if (newStatus) {
        await _userRepository.followUser(originalProfile.user.id);
      } else {
        await _userRepository.unfollowUser(originalProfile.user.id);
      }
    } catch (e) {
      // Revert on failure
      state = state.copyWith(
        userProfile: originalProfile,
        followingUserIds: state.followingUserIds,
      );
    }
  }

  Future<void> fetchMyProfile() async {
    state = state.copyWith(isCurrentUserLoading: true);
    try {
      final user = await _userRepository.getMyProfile();
      state = state.copyWith(currentUser: user, isCurrentUserLoading: false);
    } catch (e) {
      state = state.copyWith(isCurrentUserLoading: false);
    }
  }

  // NEW: Fetch following users
  Future<void> fetchFollowingUsers() async {
    try {
      final following = await _userRepository.getFollowingUsers();
      final followingIds = following.map((u) => u.id).toList();
      state = state.copyWith(followingUserIds: followingIds);
    } catch (e) {
      // Silent fail - not critical
    }
  }
}

// Provider for UserRepository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return UserRepository(dio);
});

// Provider for SocialNotifier
final socialProvider =
    StateNotifierProvider<SocialNotifier, SocialState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return SocialNotifier(userRepository);
});
