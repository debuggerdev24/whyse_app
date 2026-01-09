class InterestModel {
  String id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  InterestModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InterestModel.fromJson(Map<String, dynamic> json) => InterestModel(
    id: json["id"],
    name: json["name"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
  );
}
