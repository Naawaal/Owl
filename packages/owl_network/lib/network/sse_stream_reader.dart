// language: Dart, file: lib/core/network/sse_stream_reader.dart, target: Flutter / Owl MOBA HUD

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

/// Represents a single Server-Sent Event (SSE) message payload.
class SseEvent {
  final String? id;
  final String? event;
  final String data;
  final int? retry;

  const SseEvent({
    required this.data,
    this.id,
    this.event,
    this.retry,
  });

  /// True if the event signals stream termination (standard in OpenAI / DeepSeek / Groq APIs).
  bool get isDone => data.trim() == '[DONE]';

  @override
  String toString() =>
      'SseEvent(id: $id, event: $event, data: $data, retry: $retry)';
}

/// A [StreamTransformer] that converts a stream of byte chunks (`List<int>` or `Uint8List`)
/// into parsed [SseEvent] objects according to the W3C SSE standard.
class SseStreamTransformer<T extends List<int>>
    extends StreamTransformerBase<T, SseEvent> {
  const SseStreamTransformer();

  @override
  Stream<SseEvent> bind(Stream<T> stream) {
    return stream
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .transform(const _SseEventAssembler());
  }
}

/// Internal transformer that assembles lines into full [SseEvent] instances.
class _SseEventAssembler extends StreamTransformerBase<String, SseEvent> {
  const _SseEventAssembler();

  @override
  Stream<SseEvent> bind(Stream<String> stream) {
    final controller = StreamController<SseEvent>();

    String? currentId;
    String? currentEvent;
    int? currentRetry;
    final dataBuffer = StringBuffer();

    void dispatchCurrentEvent() {
      if (dataBuffer.isNotEmpty) {
        final rawData = dataBuffer.toString();
        // Remove trailing newline if present from multiple data: lines
        final normalizedData = rawData.endsWith('\n')
            ? rawData.substring(0, rawData.length - 1)
            : rawData;

        controller.add(
          SseEvent(
            id: currentId,
            event: currentEvent,
            data: normalizedData,
            retry: currentRetry,
          ),
        );
        dataBuffer.clear();
      }
      currentId = null;
      currentEvent = null;
      currentRetry = null;
    }

    stream.listen(
      (line) {
        // SSE comments start with a colon
        if (line.startsWith(':')) {
          return;
        }

        // Empty line indicates event boundary
        if (line.isEmpty) {
          dispatchCurrentEvent();
          return;
        }

        final colonIndex = line.indexOf(':');
        String field;
        String value;

        if (colonIndex == -1) {
          field = line;
          value = '';
        } else {
          field = line.substring(0, colonIndex);
          var valueIndex = colonIndex + 1;
          // Leading space after colon is ignored per SSE specification
          if (valueIndex < line.length && line[valueIndex] == ' ') {
            valueIndex++;
          }
          value = line.substring(valueIndex);
        }

        switch (field) {
          case 'data':
            dataBuffer.write(value);
            dataBuffer.write('\n');
            break;
          case 'id':
            currentId = value;
            break;
          case 'event':
            currentEvent = value;
            break;
          case 'retry':
            currentRetry = int.tryParse(value);
            break;
          default:
            // Unknown fields are ignored per SSE spec
            break;
        }
      },
      onError: (error, stackTrace) {
        controller.addError(error, stackTrace);
      },
      onDone: () {
        // Flush any lingering un-dispatched event before closing
        dispatchCurrentEvent();
        controller.close();
      },
      cancelOnError: false,
    );

    return controller.stream;
  }
}

/// Utility methods for reading SSE streams from LLM APIs.
class SseStreamReader {
  SseStreamReader._();

  /// Converts a raw byte stream into an asynchronous stream of [SseEvent] items.
  static Stream<SseEvent> parseByteStream<T extends List<int>>(
    Stream<T> byteStream,
  ) {
    return byteStream.transform(SseStreamTransformer<T>());
  }

  /// Converts a raw [Uint8List] stream into parsed [SseEvent] items.
  static Stream<SseEvent> parseUint8Stream(Stream<Uint8List> stream) {
    return stream.transform(const SseStreamTransformer<Uint8List>());
  }

  /// Extracts clean data payloads directly, automatically ignoring [DONE] and comments.
  static Stream<String> extractDataStream<T extends List<int>>(
    Stream<T> byteStream,
  ) async* {
    await for (final event in parseByteStream<T>(byteStream)) {
      if (event.isDone) {
        break;
      }
      if (event.data.isNotEmpty) {
        yield event.data;
      }
    }
  }
}
