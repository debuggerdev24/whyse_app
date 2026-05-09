import 'package:redstreakapp/core/utils/network_image_url.dart';

class CreatedStoryTopicsModel {
    String id,topic,learningGoal,type,updatedAt,createdOn,createdBy,thumbnailUrl;
    List<String> interests;
    int noOfStories,noOfStoriesGenerated;
    bool isOwnTopic;
    

    CreatedStoryTopicsModel({
        required this.id,
        required this.topic,
        required this.learningGoal,
        required this.type,
        required this.interests,
        required this.noOfStories,
        required this.noOfStoriesGenerated,
        required this.createdBy,
        required this.isOwnTopic,
        required this.createdOn,
        required this.updatedAt,
        required this.thumbnailUrl,
    });

    factory CreatedStoryTopicsModel.fromJson(Map<String, dynamic> json) {
      String pickThumbnail() {
        for (final key in [
          'thumbnailUrl',
          'thumbnail',
          'coverImage',
          'coverUrl',
          'imageUrl',
        ]) {
          final v = json[key]?.toString().trim();
          if (v != null && v.isNotEmpty) return resolveNetworkImageUrl(v);
        }
        return '';
      }

      return CreatedStoryTopicsModel(
        id: json["id"]?.toString() ?? "",
        topic: json["topic"]?.toString() ?? "",
        learningGoal: json["learningGoal"]?.toString() ?? "",
        type: json["type"]?.toString() ?? "",
        interests: json["interests"] == null
            ? []
            : List<String>.from(
                json["interests"].map((x) => x.toString()),
              ),
        noOfStories: json["noOfStories"] ?? 0,
        noOfStoriesGenerated: json["noOfStoriesGenerated"] ?? 0,
        createdBy: json["createdBy"]?.toString() ?? "",
        isOwnTopic: json["isOwnTopic"] ?? false,
        createdOn: json["createdOn"]?.toString() ?? "",
        updatedAt: json["updatedAt"]?.toString() ?? "",
        thumbnailUrl: pickThumbnail(),
      );
    }
}
