import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:redstreakapp/core/helper/log_helper.dart';
import 'package:redstreakapp/core/network/base_api_service.dart';
import 'package:redstreakapp/core/network/end_points.dart';
import 'package:redstreakapp/models/chat/chat_history_model.dart';
import 'package:redstreakapp/models/chat/chat_stream_event.dart';

class ChatService {
  static final _apiHelper = BaseApiHelper(enableApiLogging: true);

  Future<Either<ApiException, Map<String, dynamic>>> fetchChatHistory({
    required int limit,
    required int page,
  }) async {
    return await _apiHelper.get(
      EndPoints.chatHistory(limit: limit, page: page),
    );
  }

  /// POSTs to `/mobile/chat/stream` and yields parsed SSE events.
  Stream<ChatStreamEvent> streamMessage({
    required String message,
    CancelToken? cancelToken,
  }) async* {
    final dio = DioClient.instance.dio;
    Response<ResponseBody> response;

    try {
      response = await dio.post<ResponseBody>(
        EndPoints.chatStream,
        data: {'message': message},
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(seconds: 60),
        ),
      );
    } on DioException catch (e) {
      yield ChatStreamErrorEvent(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to start chat stream',
      );
      return;
    }

    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      yield ChatStreamErrorEvent(
        'Chat stream failed with status $status',
      );
      return;
    }

    final body = response.data;
    if (body == null) {
      yield ChatStreamErrorEvent('Empty chat stream response');
      return;
    }

    final parser = _SseParser();
    await for (final chunk in body.stream) {
      final text = utf8.decode(chunk, allowMalformed: true);
      for (final event in parser.add(text)) {
        Logger.debug(
          'SSE event=${event.event} data=${event.data}',
          tag: 'ChatStream',
        );
        final parsed = _mapSseEvent(event);
        if (parsed != null) yield parsed;
      }
    }

    for (final event in parser.flush()) {
      Logger.debug(
        'SSE flush event=${event.event} data=${event.data}',
        tag: 'ChatStream',
      );
      final parsed = _mapSseEvent(event);
      if (parsed != null) yield parsed;
    }
  }

  ChatStreamEvent? _mapSseEvent(_RawSseEvent event) {
    final data = event.data.trim();
    if (data.isEmpty) return null;

    if (data == '[DONE]' || data.toLowerCase() == 'done') {
      return const ChatStreamCompleteEvent(null);
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(data);
    } catch (_) {
      // Plain-text token chunk.
      return ChatStreamTextDeltaEvent(data);
    }

    if (decoded is String) {
      return ChatStreamTextDeltaEvent(decoded);
    }
    if (decoded is! Map) {
      return null;
    }

    return _mapJsonEvent(
      Map<String, dynamic>.from(decoded),
      sseEventName: event.event,
    );
  }

  ChatStreamEvent? _mapJsonEvent(
    Map<String, dynamic> map, {
    String? sseEventName,
  }) {
    // Unwrap common envelopes: { data: {...} } / { payload: {...} }
    final nested = map['data'] ?? map['payload'] ?? map['segment'];
    if (nested is Map &&
        (map['type'] == null ||
            map['type'].toString().toLowerCase() == 'segment' ||
            map['type'].toString().toLowerCase() == 'event')) {
      final typeHint =
          map['type']?.toString() ?? map['event']?.toString() ?? sseEventName;
      final nestedMap = Map<String, dynamic>.from(nested);
      if (typeHint != null &&
          nestedMap['type'] == null &&
          (typeHint.toLowerCase() == 'text' ||
              typeHint.toLowerCase() == 'cards')) {
        nestedMap['type'] = typeHint;
      }
      return _mapJsonEvent(nestedMap, sseEventName: sseEventName);
    }

    final type = (map['type'] ?? map['event'] ?? sseEventName ?? '')
        .toString()
        .toLowerCase();

    if (type == 'error' || map['error'] != null || map['errors'] != null) {
      final message = map['message']?.toString() ??
          map['error']?.toString() ??
          map['msg']?.toString() ??
          'Chat stream error';
      return ChatStreamErrorEvent(message);
    }

    if (type == 'done' ||
        type == 'complete' ||
        type == 'message.complete' ||
        type == 'message.end' ||
        type == 'chat.end') {
      final messageJson = map['message'];
      if (messageJson is Map) {
        return ChatStreamCompleteEvent(
          ChatMessage.fromJson(Map<String, dynamic>.from(messageJson)),
        );
      }
      if (map['segments'] is List || map['role'] != null) {
        return ChatStreamCompleteEvent(ChatMessage.fromJson(map));
      }
      return const ChatStreamCompleteEvent(null);
    }

    if (type.contains('delta') ||
        map.containsKey('delta') ||
        map.containsKey('token')) {
      final delta =
          map['delta']?.toString() ??
          map['token']?.toString() ??
          map['content']?.toString() ??
          '';
      if (delta.isEmpty) return null;
      return ChatStreamTextDeltaEvent(delta);
    }

    if (type == 'text' || type == 'cards') {
      return ChatStreamSegmentEvent(MessageSegment.fromJson(map));
    }

    if (type == 'segment' || type == 'section') {
      final segmentJson = map['segment'] ?? map['section'] ?? map;
      if (segmentJson is Map) {
        return ChatStreamSegmentEvent(
          MessageSegment.fromJson(Map<String, dynamic>.from(segmentJson)),
        );
      }
    }

    if (map['segments'] is List || map['role'] != null) {
      return ChatStreamCompleteEvent(ChatMessage.fromJson(map));
    }

    if (map['items'] is List) {
      return ChatStreamSegmentEvent(
        MessageSegment.fromJson({
          ...map,
          'type': map['type'] ?? 'cards',
        }),
      );
    }

    if (map['content'] is String && map['items'] == null) {
      return ChatStreamSegmentEvent(
        MessageSegment.fromJson({
          ...map,
          'type': map['type'] ?? 'text',
        }),
      );
    }

    Logger.warning('Unhandled chat stream payload: $map', tag: 'ChatStream');
    return ChatStreamUnknownEvent(map);
  }
}

class _RawSseEvent {
  const _RawSseEvent({this.event, required this.data});
  final String? event;
  final String data;
}

class _SseParser {
  final StringBuffer _buffer = StringBuffer();

  Iterable<_RawSseEvent> add(String chunk) sync* {
    _buffer.write(chunk);
    yield* _consume(flushRemainder: false);
  }

  Iterable<_RawSseEvent> flush() sync* {
    yield* _consume(flushRemainder: true);
  }

  Iterable<_RawSseEvent> _consume({required bool flushRemainder}) sync* {
    var text = _buffer.toString().replaceAll('\r\n', '\n');
    _buffer.clear();

    while (true) {
      final separator = text.indexOf('\n\n');
      if (separator < 0) break;
      final block = text.substring(0, separator);
      text = text.substring(separator + 2);
      final parsed = _parseBlock(block);
      if (parsed != null) yield parsed;
    }

    if (flushRemainder) {
      final parsed = _parseBlock(text);
      if (parsed != null) yield parsed;
    } else if (text.isNotEmpty) {
      _buffer.write(text);
    }
  }

  _RawSseEvent? _parseBlock(String block) {
    final trimmed = block.trim();
    if (trimmed.isEmpty) return null;

    String? eventName;
    final dataLines = <String>[];

    for (final rawLine in trimmed.split('\n')) {
      final line = rawLine.trimRight();
      if (line.isEmpty || line.startsWith(':')) continue;
      if (line.startsWith('event:')) {
        eventName = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trimLeft());
      } else if (!line.contains(':')) {
        // Some servers send bare JSON lines without the `data:` prefix.
        dataLines.add(line);
      }
    }

    if (dataLines.isEmpty) return null;
    return _RawSseEvent(event: eventName, data: dataLines.join('\n'));
  }
}
