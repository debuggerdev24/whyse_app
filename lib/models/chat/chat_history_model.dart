import 'package:redstreakapp/core/utils/network_image_url.dart';

enum ChatMessageSegmentType {
  text,
  cards;

  static ChatMessageSegmentType fromString(String value) {
    return ChatMessageSegmentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ChatMessageSegmentType.text,
    );
  }
}

enum CardItemType {
  story,
  spark;

  static CardItemType fromString(String value) {
    return CardItemType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CardItemType.story,
    );
  }
}

class ChatHistoryModel {
  final List<ChatMessage> messages;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;
  final int? nextPage;

  ChatHistoryModel({
    required this.messages,
    required this.total,
    required this.limit,
    required this.page,
    required this.totalPages,
    required this.hasMore,
    required this.nextPage,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((e) => ChatMessage.fromJson(e))
          .toList(),
      page: json['pagination']['page'] ?? 1,
      limit: json['pagination']['limit'] ?? 10,
      total: json['pagination']['total'] ?? 0,
      totalPages: json['pagination']['totalPages'] ?? 1,
      hasMore: json['pagination']['hasMore'] ?? false,
      nextPage: json['pagination']['nextPage'],
    );
  }
}

class ChatMessage {
  final String id;
  final bool isUserMessage;
  final List<MessageSegment> segments;
  final String content;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.isUserMessage,
    required this.segments,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      isUserMessage: json['role'].toString().toLowerCase() == 'user',
      segments: (json['segments'] as List<dynamic>? ?? [])
          .map((e) => MessageSegment.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  ChatMessage copyWith({
    String? id,
    bool? isUserMessage,
    List<MessageSegment>? segments,
    String? content,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      isUserMessage: isUserMessage ?? this.isUserMessage,
      segments: segments ?? this.segments,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get joinedText {
    final fromSegments = segments
        .where((s) => s.type == ChatMessageSegmentType.text)
        .map((s) => s.content)
        .where((c) => c.trim().isNotEmpty)
        .join();
    if (fromSegments.isNotEmpty) return fromSegments;
    return content;
  }
}

class MessageSegment {
  final ChatMessageSegmentType type;
  final String content;
  final List<CardItem> items;

  MessageSegment({
    required this.type,
    required this.content,
    required this.items,
  });

  factory MessageSegment.fromJson(Map<String, dynamic> json) {
    return MessageSegment(
      type: ChatMessageSegmentType.fromString(json['type']?.toString() ?? ''),
      content: json['content']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CardItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  MessageSegment copyWith({
    ChatMessageSegmentType? type,
    String? content,
    List<CardItem>? items,
  }) {
    return MessageSegment(
      type: type ?? this.type,
      content: content ?? this.content,
      items: items ?? this.items,
    );
  }
}

class CardItem {
  final String id;
  final CardItemType kind;
  final String title;
  final String imageUrl;
  final String ctaLabel;
  final String question;

  CardItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.imageUrl,
    required this.ctaLabel,
    required this.question,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) {
    final rawImage =
        json['imgUrl']?.toString() ?? json['imageUrl']?.toString() ?? '';
    return CardItem(
      id: json['id']?.toString() ?? '',
      kind: CardItemType.fromString(json['kind']?.toString() ?? ''),
      title: json['title']?.toString() ?? '',
      imageUrl: resolveNetworkImageUrl(rawImage),
      ctaLabel: json['ctaLabel']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
    );
  }
}
