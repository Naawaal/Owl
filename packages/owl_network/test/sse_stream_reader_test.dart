// language: Dart, file: test/core/network/sse_stream_reader_test.dart, target: Flutter / Owl MOBA HUD

import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:owl_network/owl_network.dart';

void main() {
  group('SseStreamReader', () {
    test('parses simple single SSE data event', () async {
      final input = utf8.encode('data: {"text":"hello"}\n\n');
      final stream = Stream.value(input);

      final events = await SseStreamReader.parseByteStream(stream).toList();
      expect(events.length, equals(1));
      expect(events.first.data, equals('{"text":"hello"}'));
      expect(events.first.isDone, isFalse);
    });

    test('parses multiple SSE chunks and handles [DONE]', () async {
      const payload =
          ': ping\n\n'
          'event: message\n'
          'data: chunk1\n\n'
          'data: chunk2\n\n'
          'data: [DONE]\n\n';

      final input = utf8.encode(payload);
      final stream = Stream.value(input);

      final events = await SseStreamReader.parseByteStream(stream).toList();
      expect(events.length, equals(3));
      expect(events[0].event, equals('message'));
      expect(events[0].data, equals('chunk1'));
      expect(events[1].data, equals('chunk2'));
      expect(events[2].data, equals('[DONE]'));
      expect(events[2].isDone, isTrue);
    });

    test('extractDataStream terminates cleanly on [DONE]', () async {
      const payload =
          'data: tactical advice 1\n\n'
          'data: tactical advice 2\n\n'
          'data: [DONE]\n\n'
          'data: should not appear\n\n';

      final input = utf8.encode(payload);
      final stream = Stream.value(input);

      final dataList = await SseStreamReader.extractDataStream(stream).toList();
      expect(dataList, equals(['tactical advice 1', 'tactical advice 2']));
    });

    test('handles multi-line data payloads', () async {
      const payload =
          'data: line 1\n'
          'data: line 2\n\n';

      final input = utf8.encode(payload);
      final stream = Stream.value(input);

      final events = await SseStreamReader.parseByteStream(stream).toList();
      expect(events.length, equals(1));
      expect(events.first.data, equals('line 1\nline 2'));
    });
  });
}
