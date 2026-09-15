// language: Dart, file: overlay_config.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter/foundation.dart';

/// Immutable configuration controlling HUD overlay rendering, transparency, and positioning.
@immutable
class OverlayConfig {
  /// Transparency factor for the tactical floating overlay (0.2 to 1.0).
  final double opacity;

  /// Global scaling multiplier for overlay elements (0.6 to 1.5).
  final double scale;

  /// Whether the floating pill or window automatically magnetizes/snaps to screen edges.
  final bool snapToEdge;

  /// When true, enables touch passthrough to the background game window.
  final bool isClickThrough;

  /// Whether the tactical overlay is currently expanded into the full HUD or collapsed into a pill.
  final bool isExpanded;

  /// Horizontal position offset in logical pixels from screen left.
  final double xOffset;

  /// Vertical position offset in logical pixels from screen top.
  final double yOffset;

  const OverlayConfig({
    this.opacity = 0.85,
    this.scale = 1.0,
    this.snapToEdge = true,
    this.isClickThrough = false,
    this.isExpanded = true,
    this.xOffset = 16.0,
    this.yOffset = 24.0,
  });

  /// Factory default configuration calibrated for gaming ergonomics.
  static const OverlayConfig defaultConfig = OverlayConfig();

  /// Creates a copy of this [OverlayConfig] with specified fields replaced.
  OverlayConfig copyWith({
    double? opacity,
    double? scale,
    bool? snapToEdge,
    bool? isClickThrough,
    bool? isExpanded,
    double? xOffset,
    double? yOffset,
  }) {
    return OverlayConfig(
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
      snapToEdge: snapToEdge ?? this.snapToEdge,
      isClickThrough: isClickThrough ?? this.isClickThrough,
      isExpanded: isExpanded ?? this.isExpanded,
      xOffset: xOffset ?? this.xOffset,
      yOffset: yOffset ?? this.yOffset,
    );
  }

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'opacity': opacity,
      'scale': scale,
      'snapToEdge': snapToEdge,
      'isClickThrough': isClickThrough,
      'isExpanded': isExpanded,
      'xOffset': xOffset,
      'yOffset': yOffset,
    };
  }

  /// Deserializes from a JSON-compatible map.
  factory OverlayConfig.fromMap(Map<String, dynamic> map) {
    return OverlayConfig(
      opacity: (map['opacity'] as num?)?.toDouble() ?? 0.85,
      scale: (map['scale'] as num?)?.toDouble() ?? 1.0,
      snapToEdge: map['snapToEdge'] as bool? ?? true,
      isClickThrough: map['isClickThrough'] as bool? ?? false,
      isExpanded: map['isExpanded'] as bool? ?? true,
      xOffset: (map['xOffset'] as num?)?.toDouble() ?? 16.0,
      yOffset: (map['yOffset'] as num?)?.toDouble() ?? 24.0,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory OverlayConfig.fromJson(Map<String, dynamic> json) =>
      OverlayConfig.fromMap(json);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OverlayConfig &&
          runtimeType == other.runtimeType &&
          opacity == other.opacity &&
          scale == other.scale &&
          snapToEdge == other.snapToEdge &&
          isClickThrough == other.isClickThrough &&
          isExpanded == other.isExpanded &&
          xOffset == other.xOffset &&
          yOffset == other.yOffset;

  @override
  int get hashCode => Object.hash(
        opacity,
        scale,
        snapToEdge,
        isClickThrough,
        isExpanded,
        xOffset,
        yOffset,
      );

  @override
  String toString() =>
      'OverlayConfig(opacity: $opacity, scale: $scale, expanded: $isExpanded, pos: ($xOffset, $yOffset))';
}
