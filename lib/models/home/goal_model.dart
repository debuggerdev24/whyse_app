class GoalModel {
  String id;
  String title;
  String description;
  bool isDefault;
  DateTime createdAt;
  DateTime updatedAt;

  GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    isDefault: json["isDefault"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );
}
