class FamilyRole {
  const FamilyRole({
    required this.value,
    required this.label,
    required this.unique,
  });

  final String value;
  final String label;
  final bool unique;

  factory FamilyRole.fromJson(Map<String, dynamic> json) {
    return FamilyRole(
      value: json['value'] as String,
      label: json['label'] as String,
      unique: json['unique'] as bool? ?? false,
    );
  }
}
