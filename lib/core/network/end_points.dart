import 'dart:core';

class EndPoints {
  EndPoints._();
  static const profile = "/mobile/profile/me";
  static const profileAvatar = "/mobile/profile/me/avatar";

  /// Initial OTP: `{ "channel": "email", "email" }` or `{ "channel": "phone", "phone" }`.
  static const profileContactRequest = "/mobile/profile/me/contact/request";

  /// Resend OTP: same body as [profileContactRequest].
  static const profileContactResend = "/mobile/profile/me/contact/resend";

  /// Verify OTP: `{ "channel": "email"|"phone", "email"|"phone", "otp" }`.
  static const profileContactVerify = "/mobile/profile/me/contact/verify";
  static const startOnBoarding = "/mobile/auth/start-onboarding";
  static const onBoardingProgress = "/mobile/auth/onboarding-progress";
  static const getDefaultInterest = "/mobile/auth/default-interests";
  static const getDefaultTopics = "/mobile/auth/default-topics";
  static String getDefaultTopicsWithSearch(String search) =>
      "$getDefaultTopics?search=${Uri.encodeComponent(search)}";
  static const getDefaultGoals = "/mobile/auth/default-goals";
  static const saveGoals = "/mobile/auth/save-goals";
  static const saveParentEmail = "/mobile/auth/save-parent-email";
  static const logIn = "/mobile/auth/login";
  static const logOut = "/mobile/auth/logout";
  static const saveTopics = "/mobile/auth/save-topics";
  static const saveInterest = "/mobile/auth/save-interests";
  static const saveReadings = "/mobile/auth/save-reading-goal";
  static const saveProfile = "/mobile/auth/save-profile-info";
  static const verifyEmail = "/mobile/auth/verify-email";
  static const createAccount = "/mobile/auth/create-account";
  static const saveAge = "/mobile/auth/save-age";
  static const socialLogin = "/mobile/auth/social-login";
  static const getStoryGoals = "/story-flow/goals";
  static const getStoryInterest = "/story-flow/interests";
  static const getStoryTopics = "/story-flow/topics";
  // static String getSearchTopics({required String query}) => "/api/v1/story-flow/topics?search=$query";
  static const getSearchTopics = "/story-flow/topics";
  static const getAllStories = "/story/mobile";
  static const forgotPassword = "/mobile/auth/forgot-password";
  static const resetPassword = "/mobile/auth/reset-password";
  static const createStoryIdea = "/story/ideas/generate-mobile";
  static const createStory = "/story/generate-from-idea";
  static const createStoryImage = "/story/generate-story-image";
  static const verifyForgotPassMail = "/mobile/auth/verify-recovery";
  static const verifyParentConsent = "/mobile/auth/parent-consent";
  static const refreshToken = "/mobile/auth/refresh-token";
  static const getMyGroups = "/mobile/groups";
  static const joinGroupByCode = "/mobile/groups/join-by-code";
  static const String createGroup = '/mobile/groups';
  static String getFriendsExcludingFamily({int page = 1, int limit = 20}) =>
      '/mobile/friends?page=$page&limit=$limit&excludeFamilyMembers=true';
  static const String addFamilyMember = '/mobile/family';
  static const String getFamilyMembersRoles = '/mobile/family/roles';

  static String getFamilyMembersRolesForEdit({
    required String excludeFamilyMemberId,
  }) => '/mobile/family/roles?excludeFamilyMemberId=$excludeFamilyMemberId';

  static String getFamilyMembers({int page = 1, int limit = 20}) =>
      '/mobile/family?page=$page&limit=$limit';

  static String updateFamilyMember({required String familyMemberId}) =>
      '/mobile/family/$familyMemberId';

  static String removeFamilyMember({required String familyMemberId}) =>
      '/mobile/family/$familyMemberId';

  static String searchUsers({int page = 1, int limit = 20, String? q}) {
    final buffer = StringBuffer('/users/search?page=$page&limit=$limit');
    final searchValue = (q ?? '').trim();
    buffer.write('&q=${Uri.encodeComponent(searchValue)}');
    return buffer.toString();
  }

  static String getGroupMembers({required String groupId}) =>
      "/groups/$groupId/members";
  static String addGroupMembers({required String groupId}) =>
      "/groups/$groupId/members";
  static String removeGroupMember({
    required String groupId,
    required String userId,
  }) => "/groups/$groupId/members/$userId";
  static String leaveGroup({required String groupId}) =>
      "/mobile/groups/$groupId/leave";

  // get home screen topics list, (user generated)s
  static String getMyTopics({int page = 1, int limit = 20}) =>
      "/story/topics?page=$page&limit=$limit&createdBy=self";

  static String getMyCompletedTopics({int page = 1, int limit = 20}) =>
      "/story/topics?page=$page&limit=$limit&createdBy=self&completed=true";

  static const browseAllTopics = "/story/topics";
  static String getMyList({int page = 1, int limit = 10, String search = ''}) =>
      "/story/topics/my-list?page=$page&limit=$limit&search=${Uri.encodeComponent(search)}";
  static String storeImage({required String storyId}) =>
      "/story/mobile-story/$storyId/store-images";
  static String addOrRemoveToMyList({required String topicId}) =>
      "/story/topics/$topicId/toggle-list";
  static String getStoryIdeasByTopicId({required String topicId}) =>
      "/story/topics/$topicId/story-ideas";

  // Returns already-generated story ideas in the same format as the
  // generate-mobile endpoint (used for refreshing after a reading session).
  static String getMobileTopicStoryIdeas({required String topicId}) =>
      "/story/mobile/topics/$topicId/story-ideas";
  static String getStoryByStoryIdea({required String storyIdea}) =>
      "/story/ideas/$storyIdea/story";
  static String topicProgress({required String topicId}) =>
      "/story/topics/$topicId/progress";
  static String markAsRead({required String storyIdeaId}) =>
      "/story/ideas/$storyIdeaId/mark-read";
  static String pageProgress({required String storyIdeaId}) =>
      "/story/ideas/$storyIdeaId/page-progress";
  static String createQuiz({required String storyId}) =>
      "/story/mobile/$storyId/quiz/generate";
  static String getQuiz({required String storyId}) =>
      "/story/mobile/$storyId/quiz";
  static String submitQuiz({required String storyId}) =>
      "/story/mobile/$storyId/quiz/submit";

  /// Home → Continue Reading shelf.
  /// Backend returns `data.items` with pagination.
  static String getContinueReading({int page = 1, int limit = 10}) =>
      "/story/ideas/continue-reading?page=$page&limit=$limit";

  static String getFriends({int page = 1, int limit = 20}) =>
      "/mobile/friends?page=$page&limit=$limit";

  static String searchFriends({int page = 1, int limit = 20, String? q}) {
    final buffer = StringBuffer(
      '/mobile/friends/search?page=$page&limit=$limit',
    );
    if (q != null && q.trim().isNotEmpty) {
      buffer.write('&q=${Uri.encodeComponent(q.trim())}');
    }
    return buffer.toString();
  }

  static const sendFriendRequest = "/mobile/friends/request";

  static String getFriendRequests({int page = 1, int limit = 50}) =>
      "/mobile/friends/requests?page=$page&limit=$limit";

  static String updateFriendRequest({required String friendshipId}) =>
      "/mobile/friends/$friendshipId";

  static String removeFriend({required String friendshipId}) =>
      "/mobile/friends/$friendshipId";

  static String groupSharedTopics({required String groupId}) =>
      "/mobile/groups/$groupId/topics/shared";

  static String shareTopicsInGroup({required String groupId}) =>
      "/mobile/groups/$groupId/topics/share";

  static String getShareableTopics({int page = 1, int limit = 10}) =>
      "/mobile/groups/shareable-topics?page=$page&limit=$limit";

  static String getFriendsDetails({required String friendId}) =>
      '/mobile/friends/users/$friendId/profile?groupType=all';

  static String getUserProfileSectionList({
    required String userId,
    required String section,
    int page = 1,
    int limit = 20,
    String groupType = 'all',
  }) =>
      '/mobile/friends/users/$userId/profile/list?section=$section&page=$page&limit=$limit&groupType=$groupType';

  // Mobile Explorer endpoints
  static const explorerDiscoverInterests = '/mobile/explorer/discover-interests';
  static const explorerSeriesForYou = '/mobile/explorer/series/for-you';
  static const explorerSeriesPopular = '/mobile/explorer/series/popular';
  static const explorerSeriesInterest = '/mobile/explorer/series/interest';
  static const explorerSparkForYou = '/mobile/explorer/spark/for-you';
  static const explorerSparkPopular = '/mobile/explorer/spark/popular';
  static const explorerSparkInterest = '/mobile/explorer/spark/interest';

  // Curiosity Reading endpoints
  static getCuriosityReading({int page = 1, int limit = 10}) =>
      "/mobile/curiosity/feed?includeBody=true&limit=$limit&page=$page";

  static String getCuriosityReadingById({required String readingId}) =>
      '/mobile/curiosity/readings/$readingId?includeBody=true';

  static curiosityReadingInteract({required String readingId}) =>
      '/mobile/curiosity/readings/$readingId/interact';

  // Gamification & streaks
  static const streakScore = '/user/streak-score';
  static String streakScoreForMonth({required int month, required int year}) =>
      '/user/streak-score?month=$month&year=$year';
  static const buyStreakFreeze = '/streak/freeze/buy';
  static String leaderboard({
    String scope = 'global',
    int page = 1,
    int limit = 20,
  }) => '/leaderboard?scope=$scope&page=$page&limit=$limit';
}

