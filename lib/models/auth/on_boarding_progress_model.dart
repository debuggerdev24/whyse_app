class OnBoardingProgressModel {
  String? onboardingId;
  String? currentStep;
  bool? isCompleted;
  String? email;
  DateTime? dateOfBirth;
  int? age;
  bool? isUnder16;
  dynamic parentEmail;
  dynamic consentStatus;
  UserProfile? userProfile;
  List<User>? userInterests;
  List<User>? userTopics;
  List<UserGoal>? userGoals;

  OnBoardingProgressModel({
    this.onboardingId,
    this.currentStep,
    this.isCompleted,
    this.email,
    this.dateOfBirth,
    this.age,
    this.isUnder16,
    this.parentEmail,
    this.consentStatus,
    this.userProfile,
    this.userInterests,
    this.userTopics,
    this.userGoals,
  });

  factory OnBoardingProgressModel.fromJson(Map<String, dynamic> json) =>
      OnBoardingProgressModel(
        onboardingId: json["onboardingId"],
        currentStep: json["currentStep"],
        isCompleted: json["isCompleted"],
        email: json["email"],
        dateOfBirth: json["dateOfBirth"] != null
            ? DateTime.tryParse(json["dateOfBirth"])
            : null,
        age: json["age"],
        isUnder16: json["isUnder16"],
        parentEmail: json["parentEmail"],
        consentStatus: json["consentStatus"],
        userProfile: json["userProfile"] != null
            ? UserProfile.fromJson(json["userProfile"])
            : null,
        userInterests: json["userInterests"] != null
            ? List<User>.from(
                (json["userInterests"] as List).map((x) => User.fromJson(x)),
              )
            : null,
        userTopics: json["userTopics"] != null
            ? List<User>.from(
                (json["userTopics"] as List).map((x) => User.fromJson(x)),
              )
            : null,
        userGoals: json["userGoals"] != null
            ? List<UserGoal>.from(
                (json["userGoals"] as List).map((x) => UserGoal.fromJson(x)),
              )
            : null,
      );
}

class UserGoal {
  String? id;
  String? userId;
  String? onboardingId;
  String? goalId;
  dynamic goalType;
  String? title;
  String? description;
  bool? isCustom;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserGoal({
    this.id,
    this.userId,
    this.onboardingId,
    this.goalId,
    this.goalType,
    this.title,
    this.description,
    this.isCustom,
    this.createdAt,
    this.updatedAt,
  });

  factory UserGoal.fromJson(Map<String, dynamic> json) => UserGoal(
    id: json["id"],
    userId: json["userId"],
    onboardingId: json["onboardingId"],
    goalId: json["goalId"],
    goalType: json["goalType"],
    title: json["title"],
    description: json["description"],
    isCustom: json["isCustom"],
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.tryParse(json["updatedAt"])
        : null,
  );
}

class User {
  String? id;
  String? userId;
  String? onboardingId;
  String? interestId;
  dynamic customName;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? topicId;

  User({
    this.id,
    this.userId,
    this.onboardingId,
    this.interestId,
    this.customName,
    this.createdAt,
    this.updatedAt,
    this.topicId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    userId: json["userId"],
    onboardingId: json["onboardingId"],
    interestId: json["interestId"],
    customName: json["customName"],
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.tryParse(json["updatedAt"])
        : null,
    topicId: json["topicId"],
  );
}

class UserProfile {
  String? id;
  String? userId;
  String? onboardingId;
  String? firstName;
  String? lastName;
  String? email;
  String? country;
  String? preferredLanguage;
  int? dailyReadingGoal;
  dynamic authProvider;
  dynamic providerId;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserProfile({
    this.id,
    this.userId,
    this.onboardingId,
    this.firstName,
    this.lastName,
    this.email,
    this.country,
    this.preferredLanguage,
    this.dailyReadingGoal,
    this.authProvider,
    this.providerId,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json["id"],
    userId: json["userId"],
    onboardingId: json["onboardingId"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    country: json["country"],
    preferredLanguage: json["preferredLanguage"],
    dailyReadingGoal: json["dailyReadingGoal"],
    authProvider: json["authProvider"],
    providerId: json["providerId"],
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.tryParse(json["updatedAt"])
        : null,
  );
}
