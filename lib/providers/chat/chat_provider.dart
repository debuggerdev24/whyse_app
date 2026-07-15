import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/models/chat/chat_history_model.dart';
import 'package:redstreakapp/models/chat/chat_stream_event.dart';
import 'package:redstreakapp/services/chat/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService chatService = ChatService();

  bool isChatHistoryLoading = true;
  bool isStreaming = false;
  bool isBotTyping = false;
  String? streamError;

  ChatHistoryModel? chatHistory;
  List<ChatMessage> messages = [];

  int limit = 50;
  int page = 1;

  CancelToken? _streamCancelToken;

  Future<void> loadChatHistory() async {
    isChatHistoryLoading = true;
    streamError = null;
    notifyListeners();

    final result = await chatService.fetchChatHistory(limit: limit, page: page);

    result.fold(
      (error) {
        Logger.error('Chat history failed: ${error.errorMsg}');
        isChatHistoryLoading = false;
        notifyListeners();
      },
      (data) {
        chatHistory = ChatHistoryModel.fromJson(
          Map<String, dynamic>.from(data['data'] as Map),
        );
        messages = List<ChatMessage>.from(chatHistory!.messages);
        isChatHistoryLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || isStreaming) return;

    streamError = null;

    final userMessage = ChatMessage(
      id: 'local-user-${DateTime.now().microsecondsSinceEpoch}',
      isUserMessage: true,
      segments: [
        MessageSegment(
          type: ChatMessageSegmentType.text,
          content: text,
          items: const [],
        ),
      ],
      content: text,
      createdAt: DateTime.now(),
    );

    final botId = 'local-bot-${DateTime.now().microsecondsSinceEpoch}';
    var botMessage = ChatMessage(
      id: botId,
      isUserMessage: false,
      segments: const [],
      content: '',
      createdAt: DateTime.now(),
    );

    messages = [...messages, userMessage, botMessage];
    isStreaming = true;
    isBotTyping = true;
    notifyListeners();

    _streamCancelToken?.cancel();
    _streamCancelToken = CancelToken();

    try {
      await for (final event in chatService.streamMessage(
        message: text,
        cancelToken: _streamCancelToken,
      )) {
        switch (event) {
          case ChatStreamSegmentEvent(:final segment):
            isBotTyping = false;
            botMessage = _appendSegment(botMessage, segment);
          case ChatStreamTextDeltaEvent(:final delta):
            isBotTyping = false;
            botMessage = _appendTextDelta(botMessage, delta);
          case ChatStreamCompleteEvent(:final message):
            isBotTyping = false;
            if (message != null) {
              // Keep local id so the typewriter widget state is preserved.
              botMessage = message.copyWith(id: botId);
            } else if (botMessage.segments.isEmpty &&
                botMessage.content.trim().isEmpty) {
              // Keep empty only if nothing streamed yet.
            }
          case ChatStreamErrorEvent(:final message):
            streamError = message;
            isBotTyping = false;
            if (botMessage.segments.isEmpty &&
                botMessage.content.trim().isEmpty) {
              botMessage = botMessage.copyWith(
                segments: [
                  MessageSegment(
                    type: ChatMessageSegmentType.text,
                    content: 'Sorry, something went wrong. Please try again.',
                    items: const [],
                  ),
                ],
                content: 'Sorry, something went wrong. Please try again.',
              );
            }
          case ChatStreamUnknownEvent():
            // Logged in service; ignore for UI.
            break;
        }

        messages = [
          ...messages.sublist(0, messages.length - 1),
          botMessage,
        ];
        notifyListeners();
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        Logger.info('Chat stream cancelled');
      } else {
        streamError = e.message ?? 'Failed to send message';
        Logger.error('Chat stream dio error: $streamError');
        _ensureBotErrorMessage(botId);
      }
    } catch (e) {
      streamError = e.toString();
      Logger.error('Chat stream error: $e');
      _ensureBotErrorMessage(botId);
    } finally {
      isStreaming = false;
      isBotTyping = false;
      _streamCancelToken = null;
      notifyListeners();
    }
  }

  void _ensureBotErrorMessage(String botId) {
    final index = messages.lastIndexWhere((m) => m.id == botId);
    if (index < 0) return;
    final current = messages[index];
    if (current.segments.isNotEmpty || current.content.trim().isNotEmpty) {
      return;
    }
    final updated = current.copyWith(
      segments: [
        MessageSegment(
          type: ChatMessageSegmentType.text,
          content: 'Sorry, something went wrong. Please try again.',
          items: const [],
        ),
      ],
      content: 'Sorry, something went wrong. Please try again.',
    );
    messages = [
      ...messages.sublist(0, index),
      updated,
      ...messages.sublist(index + 1),
    ];
  }

  ChatMessage _appendSegment(ChatMessage message, MessageSegment segment) {
    if (segment.type == ChatMessageSegmentType.text &&
        segment.content.trim().isEmpty &&
        segment.items.isEmpty) {
      return message;
    }
    if (segment.type == ChatMessageSegmentType.cards && segment.items.isEmpty) {
      return message;
    }

    final segments = [...message.segments, segment];
    return message.copyWith(
      segments: segments,
      content: segments
          .where((s) => s.type == ChatMessageSegmentType.text)
          .map((s) => s.content)
          .join(),
    );
  }

  ChatMessage _appendTextDelta(ChatMessage message, String delta) {
    if (delta.isEmpty) return message;
    final segments = [...message.segments];
    if (segments.isNotEmpty &&
        segments.last.type == ChatMessageSegmentType.text) {
      final last = segments.last;
      segments[segments.length - 1] = last.copyWith(
        content: '${last.content}$delta',
      );
    } else {
      segments.add(
        MessageSegment(
          type: ChatMessageSegmentType.text,
          content: delta,
          items: const [],
        ),
      );
    }
    return message.copyWith(
      segments: segments,
      content: segments
          .where((s) => s.type == ChatMessageSegmentType.text)
          .map((s) => s.content)
          .join(),
    );
  }

  @override
  void dispose() {
    _streamCancelToken?.cancel();
    super.dispose();
  }
}
