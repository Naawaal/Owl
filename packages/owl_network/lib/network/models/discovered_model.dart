// language: Dart, file: packages/owl_network/lib/network/models/discovered_model.dart, target: Flutter / Owl MOBA HUD

/// Normalized model metadata discovered dynamically from models.dev or live provider endpoints.
class DiscoveredModel {
  final String id;
  final String name;
  final String providerId;
  final bool isFree;
  final int? contextLength;
  final String? description;
  final double? inputPrice;
  final double? outputPrice;

  const DiscoveredModel({
    required this.id,
    required this.name,
    required this.providerId,
    this.isFree = false,
    this.contextLength,
    this.description,
    this.inputPrice,
    this.outputPrice,
  });

  /// Formatted compact context badge (e.g., "1M", "128K", "32K").
  String? get formattedContext {
    final c = contextLength;
    if (c == null || c <= 0) return null;
    if (c >= 900000) {
      final m = c >= 1040000 ? c / 1048576 : c / 1000000;
      final rounded = (m * 10).round() / 10;
      return '${rounded.truncateToDouble() == rounded ? rounded.toInt() : rounded}M';
    }
    if (c >= 1000) {
      final kBinary = (c / 1024).round();
      if ((c % 1024 == 0) || (c / 1024 - kBinary).abs() < 0.05) {
        return '${kBinary}K';
      }
      return '${(c / 1000).round()}K';
    }
    return '$c';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'providerId': providerId,
      'isFree': isFree,
      'contextLength': contextLength,
      'description': description,
      'inputPrice': inputPrice,
      'outputPrice': outputPrice,
    };
  }

  factory DiscoveredModel.fromMap(Map<String, dynamic> map) {
    return DiscoveredModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? map['id'] as String? ?? '',
      providerId: map['providerId'] as String? ?? '',
      isFree: map['isFree'] as bool? ?? false,
      contextLength: (map['contextLength'] as num?)?.toInt(),
      description: map['description'] as String?,
      inputPrice: (map['inputPrice'] as num?)?.toDouble(),
      outputPrice: (map['outputPrice'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          providerId == other.providerId;

  @override
  int get hashCode => Object.hash(id, providerId);

  @override
  String toString() =>
      'DiscoveredModel(id: $id, name: $name, provider: $providerId, free: $isFree)';
}
