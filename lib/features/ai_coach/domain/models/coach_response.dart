// language: Dart, file: coach_response.dart, target: Flutter / Owl MOBA HUD
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Immutable domain model representing actionable tactical advice returned by the AI Coach.
@immutable
class CoachResponse {
  /// Immediate high-priority action or command (e.g. 'Rotate to Dragon pit', 'Freeze lane').
  final String action;

  /// Strategic rationale behind the suggested action.
  final String reason;

  /// Counter-risk or threat warning (e.g. 'Enemy jungler missing', 'Don't commit Flash').
  final String? warning;

  /// Unaltered raw text output from the provider.
  final String rawText;

  /// Timestamp when the recommendation was generated.
  final DateTime timestamp;

  const CoachResponse({
    required this.action,
    required this.reason,
    required this.rawText,
    this.warning,
    required this.timestamp,
  });

  /// Factory parser that turns arbitrary LLM raw response text (JSON or markdown/text)
  /// into a structured [CoachResponse].
  factory CoachResponse.fromRawText(String raw, [DateTime? time]) {
    final now = time ?? DateTime.now();
    final trimmed = raw.trim();

    // 1. Attempt JSON block parsing
    try {
      String jsonStr = trimmed;
      if (trimmed.contains('{') && trimmed.contains('}')) {
        final startIndex = trimmed.indexOf('{');
        final endIndex = trimmed.lastIndexOf('}') + 1;
        jsonStr = trimmed.substring(startIndex, endIndex);
      }
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return CoachResponse(
          action: decoded['action']?.toString() ?? 'Hold Position',
          reason: decoded['reason']?.toString() ?? 'Maintain map control.',
          warning: decoded['warning']?.toString(),
          rawText: raw,
          timestamp: now,
        );
      }
    } catch (_) {
      // Fall through to heuristic string extraction
    }

    // 2. Line-by-line heuristic parsing for Action: / Reason: / Warning:
    String? extractedAction;
    String? extractedReason;
    String? extractedWarning;

    final lines = trimmed.split('\n');
    for (final line in lines) {
      final l = line.trim();
      final lower = l.toLowerCase();
      if (lower.startsWith('action:')) {
        extractedAction = l.substring(7).trim();
      } else if (lower.startsWith('reason:')) {
        extractedReason = l.substring(7).trim();
      } else if (lower.startsWith('warning:')) {
        extractedWarning = l.substring(8).trim();
      }
    }

    if (extractedAction != null || extractedReason != null) {
      return CoachResponse(
        action: extractedAction ?? 'Tactical Directive',
        reason: extractedReason ?? trimmed,
        warning: extractedWarning,
        rawText: raw,
        timestamp: now,
      );
    }

    // 3. Fallback: single block of advice
    return CoachResponse(
      action: trimmed.length > 60 ? '${trimmed.substring(0, 57)}...' : trimmed,
      reason: trimmed,
      warning: null,
      rawText: raw,
      timestamp: now,
    );
  }

  /// Creates a copy of this [CoachResponse] with specified fields replaced.
  CoachResponse copyWith({
    String? action,
    String? reason,
    String? warning,
    String? rawText,
    DateTime? timestamp,
  }) {
    return CoachResponse(
      action: action ?? this.action,
      reason: reason ?? this.reason,
      warning: warning ?? this.warning,
      rawText: rawText ?? this.rawText,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'reason': reason,
      if (warning != null) 'warning': warning,
      'rawText': rawText,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Deserializes from a JSON-compatible map.
  factory CoachResponse.fromMap(Map<String, dynamic> map) {
    return CoachResponse(
      action: map['action'] as String? ?? 'Hold Position',
      reason: map['reason'] as String? ?? '',
      warning: map['warning'] as String?,
      rawText: map['rawText'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory CoachResponse.fromJson(Map<String, dynamic> json) =>
      CoachResponse.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoachResponse &&
          runtimeType == other.runtimeType &&
          action == other.action &&
          reason == other.reason &&
          warning == other.warning &&
          rawText == other.rawText &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(
        action,
        reason,
        warning,
        rawText,
        timestamp,
      );

  @override
  String toString() =>
      'CoachResponse(action: $action, reason: $reason, warning: $warning)';
}
