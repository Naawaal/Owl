// language: Dart, file: voice_changer_service.dart, target: Flutter / Owl Game Turbo
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoicePreset {
  final String id;
  final String name;
  final String description;

  const VoicePreset({
    required this.id,
    required this.name,
    required this.description,
  });
}

const List<VoicePreset> kTacticalVoicePresets = [
  VoicePreset(
    id: 'commander',
    name: 'Commander',
    description: 'Deep pitch shift with warm harmonic saturation',
  ),
  VoicePreset(
    id: 'cybernetic',
    name: 'Cybernetic',
    description: 'Robotic vocoder with 50Hz ring modulation',
  ),
  VoicePreset(
    id: 'radio',
    name: 'Tactical Radio',
    description: 'Military comms bandpass filter (400Hz - 3.4kHz)',
  ),
  VoicePreset(
    id: 'studio',
    name: 'Studio Clean',
    description: 'Low-latency normalized voice passthrough',
  ),
];

class VoiceChangerState {
  final bool isActive;
  final String activePresetId;
  final String statusMessage;

  const VoiceChangerState({
    required this.isActive,
    required this.activePresetId,
    required this.statusMessage,
  });

  VoicePreset get currentPreset {
    return kTacticalVoicePresets.firstWhere(
      (p) => p.id == activePresetId,
      orElse: () => kTacticalVoicePresets.first,
    );
  }

  VoiceChangerState copyWith({
    bool? isActive,
    String? activePresetId,
    String? statusMessage,
  }) {
    return VoiceChangerState(
      isActive: isActive ?? this.isActive,
      activePresetId: activePresetId ?? this.activePresetId,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

final voiceChangerProvider =
    StateNotifierProvider<VoiceChangerNotifier, VoiceChangerState>((ref) {
  return VoiceChangerNotifier();
});

class VoiceChangerNotifier extends StateNotifier<VoiceChangerState> {
  VoiceChangerNotifier()
      : super(const VoiceChangerState(
          isActive: false,
          activePresetId: 'commander',
          statusMessage: 'Voice Changer Off',
        ));

  static const MethodChannel _channel =
      MethodChannel('com.example.owl/voice_changer');

  Future<bool> toggleVoice([bool? targetState]) async {
    final newState = targetState ?? !state.isActive;
    try {
      if (newState) {
        final success = await _channel.invokeMethod<bool>(
              'startVoiceProcessing',
              {'preset': state.activePresetId},
            ) ??
            true;

        state = state.copyWith(
          isActive: success,
          statusMessage: success
              ? '${state.currentPreset.name} Active'
              : 'Microphone permission needed',
        );
        return success;
      } else {
        await _channel.invokeMethod('stopVoiceProcessing');
        state = state.copyWith(
          isActive: false,
          statusMessage: 'Voice Changer Off',
        );
        return true;
      }
    } catch (_) {
      // Test / Simulated fallback
      state = state.copyWith(
        isActive: newState,
        statusMessage: newState
            ? '${state.currentPreset.name} Active (Simulated)'
            : 'Voice Changer Off',
      );
      return true;
    }
  }

  Future<void> setPreset(String presetId) async {
    state = state.copyWith(activePresetId: presetId);
    try {
      await _channel.invokeMethod('setPreset', {'preset': presetId});
      if (state.isActive) {
        state = state.copyWith(
          statusMessage: '${state.currentPreset.name} Active',
        );
      }
    } catch (_) {}
  }
}
