class SearchUser {
  final String id;
  final String? email;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? displayName;

  const SearchUser({
    required this.id,
    this.email,
    this.username,
    this.firstName,
    this.lastName,
    this.displayName,
  });

  factory SearchUser.fromJson(Map<String, dynamic> json) {
    return SearchUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      username: json['username'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      displayName: json['displayName'] as String?,
    );
  }

  String get initials {
    final first = (firstName ?? '').isNotEmpty ? firstName![0] : '';
    final last = (lastName ?? '').isNotEmpty ? lastName![0] : '';
    if (first.isEmpty && last.isEmpty) return '?';
    return '$first$last'.toUpperCase();
  }

  String get fullName => displayName ?? '$firstName $lastName'.trim();
}
