import 'dart:core';

class EndPoints {
  EndPoints._();
  static const profile = "/mobile/profile/me";
  static const profileAvatar = "/mobile/profile/me/avatar";
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
  static String createGroup = '/mobile/groups';
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
  }) =>
      "/groups/$groupId/members/$userId";
  static String leaveGroup({required String groupId}) =>
      "/mobile/groups/$groupId/leave";
  
  // get home screen topics list, (user generated)s
  static String getMyTopics({int page = 1, int limit = 20}) =>
      "/story/topics?page=$page&limit=$limit&createdBy=self";
  
  static const browseAllTopics = "/story/topics";
  static String getMyList({int page = 1, int limit = 10, String search = ''}) =>
      "/story/topics/my-list?page=$page&limit=$limit&search=${Uri.encodeComponent(search)}";
  static String storeImage({required String storyId}) =>
      "/story/mobile-story/$storyId/store-images";
  static String addOrRemoveToMyList({required String topicId}) =>
      "/story/topics/$topicId/toggle-list";
  static String getStoryIdeasByTopicId({required String topicId}) =>
      "/story/topics/$topicId/story-ideas";
  static String getStoryByStoryIdea({required String storyIdea}) =>
      "/story/ideas/$storyIdea/story";
  static String topicProgress({required String topicId}) =>
      "/story/topics/$topicId/progress";
  static String markAsRead({required String storyIdeaId}) =>
      "/story/ideas/$storyIdeaId/mark-read";
  static String pageProgress({required String storyIdeaId}) =>
      "/story/ideas/$storyIdeaId/page-progress";
  static String createQuiz({required String storyId}) =>
      "/story/$storyId/quiz/generate";
  static String getQuiz({required String storyId}) => "/story/$storyId/quiz";

  static String getFriends({int page = 1, int limit = 20}) =>
      "/mobile/friends?page=$page&limit=$limit";

  static String searchFriends({int page = 1, int limit = 20, String? q}) {
    final buffer = StringBuffer('/mobile/friends/search?page=$page&limit=$limit');
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
}
