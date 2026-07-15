import 'package:redstreakapp/models/chat/chat_history_model.dart';

sealed class ChatStreamEvent {
  const ChatStreamEvent();
}

class ChatStreamSegmentEvent extends ChatStreamEvent {
  const ChatStreamSegmentEvent(this.segment);
  final MessageSegment segment;
}

class ChatStreamTextDeltaEvent extends ChatStreamEvent {
  const ChatStreamTextDeltaEvent(this.delta);
  final String delta;
}

class ChatStreamCompleteEvent extends ChatStreamEvent {
  const ChatStreamCompleteEvent(this.message);
  final ChatMessage? message;
}

class ChatStreamErrorEvent extends ChatStreamEvent {
  const ChatStreamErrorEvent(this.message);
  final String message;
}

class ChatStreamUnknownEvent extends ChatStreamEvent {
  const ChatStreamUnknownEvent(this.raw);
  final Map<String, dynamic> raw;
}
