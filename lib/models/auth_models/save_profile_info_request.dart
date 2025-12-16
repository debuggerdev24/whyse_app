class SaveProfileInfoRequest {
  String? onboardingId;
  String? country;
  String? preferredLanguage;

  SaveProfileInfoRequest({
    this.onboardingId,
    this.country,
    this.preferredLanguage,
  });

  SaveProfileInfoRequest.fromJson(Map<String, dynamic> json) {
    onboardingId = json['onboardingId'];
    country = json['country'];
    preferredLanguage = json['preferredLanguage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['onboardingId'] = onboardingId;
    data['country'] = country;
    data['preferredLanguage'] = preferredLanguage;
    return data;
  }
}
