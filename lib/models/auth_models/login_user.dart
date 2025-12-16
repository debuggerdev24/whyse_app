class LoginUser {
  String? refresh;
  String? access;
  String? id;
  String? email;
  String? username;
  bool? isEmailVerified;
  bool? isPhoneVerified;

  LoginUser({
    this.refresh,
    this.access,
    this.id,
    this.email,
    this.username,
    this.isEmailVerified,
    this.isPhoneVerified,
  });

  LoginUser.fromJson(Map<String, dynamic> json) {
    refresh = json['refresh'];
    access = json['access'];
    id = json['id'];
    email = json['email'];
    username = json['username'];
    isEmailVerified = json['is_email_verified'];
    isPhoneVerified = json['is_phone_verified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['refresh'] = refresh;
    data['access'] = access;
    data['id'] = id;
    data['email'] = email;
    data['username'] = username;
    data['is_email_verified'] = isEmailVerified;
    data['is_phone_verified'] = isPhoneVerified;
    return data;
  }
}
