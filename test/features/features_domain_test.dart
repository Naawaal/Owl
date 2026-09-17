// language: Dart, file: features_domain_test.dart, target: Flutter / Owl MOBA HUD
import 'package:flutter_test/flutter_test.dart';
import 'package:owl/features/ai_coach/ai_coach.dart';
import 'package:owl/features/game_profiles/game_profiles.dart';
import 'package:owl/features/overlay/overlay.dart';
import 'package:owl/features/settings/settings.dart';
import 'package:owl/features/timers/timers.dart';

void main() {
  group('1. Game Profiles Feature', () {
    test('Wild Rift preset contains required objectives and accurate timings', () {
      expect(wildRiftPreset.id, 'wild_rift');
      expect(wildRiftPreset.objectives.length, 6);

      // Verify major objectives
      final dragon = wildRiftPreset.findObjective('wr_elemental_dragon');
      expect(dragon, isNotNull);
      expect(dragon!.isMajor, isTrue);
      expect(dragon.initialSpawnSeconds, 300);
      expect(dragon.respawnIntervalSeconds, 300);
      expect(dragon.initialSpawnFormatted, '05:00');

      final baron = wildRiftPreset.findObjective('wr_baron_nashor');
      expect(baron, isNotNull);
      expect(baron!.isMajor, isTrue);
      expect(baron.initialSpawnSeconds, 720);

      final buffs = wildRiftPreset.buffObjectives;
      expect(buffs.length, 2);
    });

    test('MLBB preset contains Turtle, Lord, Lithowanderer, Buffs', () {
      expect(mlbbPreset.id, 'mlbb');
      expect(mlbbPreset.objectives.length, 5);

      final turtle = mlbbPreset.findObjective('mlbb_turtle');
      expect(turtle, isNotNull);
      expect(turtle!.isMajor, isTrue);

      final lord = mlbbPreset.findObjective('mlbb_lord');
      expect(lord, isNotNull);
      expect(lord!.isMajor, isTrue);

      final litho = mlbbPreset.findObjective('mlbb_lithowanderer');
      expect(litho, isNotNull);
      expect(litho!.category, ObjectiveCategory.neutral);

      final purple = mlbbPreset.findObjective('mlbb_purple_buff');
      expect(purple, isNotNull);
      expect(purple!.category, ObjectiveCategory.buff);
    });

    test('Pokémon UNITE preset contains Rayquaza, Regis, Altaria, Swablu', () {
      expect(pokemonUnitePreset.id, 'pokemon_unite');
      expect(pokemonUnitePreset.objectives.length, 5);

      final rayquaza = pokemonUnitePreset.findObjective('pu_rayquaza');
      expect(rayquaza, isNotNull);
      expect(rayquaza!.isMajor, isTrue);
      expect(rayquaza.initialSpawnSeconds, 480);

      final eleki = pokemonUnitePreset.findObjective('pu_regieleki');
      expect(eleki, isNotNull);

      final altaria = pokemonUnitePreset.findObjective('pu_altaria_lane');
      expect(altaria, isNotNull);
      expect(altaria!.isMajor, isFalse);
    });

    test('GameProfile JSON serialization round-trip', () {
      final json = wildRiftPreset.toJson();
      final reconstructed = GameProfile.fromJson(json);
      expect(reconstructed.id, wildRiftPreset.id);
      expect(reconstructed.objectives.length, wildRiftPreset.objectives.length);
      expect(reconstructed, equals(wildRiftPreset));
    });

    test('findGameProfileById helper resolves profiles', () {
      expect(findGameProfileById('wild_rift'), equals(wildRiftPreset));
      expect(findGameProfileById('mlbb'), equals(mlbbPreset));
      expect(findGameProfileById('pokemon_unite'), equals(pokemonUnitePreset));
      expect(findGameProfileById('unknown_game'), isNull);
    });
  });

  group('2. Timers Feature', () {
    test('ActiveTimer status calculations and progress ratios', () {
      final runningTimer = ActiveTimer(
        id: 't_1',
        objectiveId: 'wr_baron_nashor',
        name: 'Baron Nashor',
        remainingSeconds: 150,
        totalSeconds: 210,
        targetEpochMs: DateTime.now().millisecondsSinceEpoch + 150000,
        isRunning: true,
        isUrgent: false,
      );

      expect(runningTimer.status, TimerStatus.running);
      expect(runningTimer.progressRatio, closeTo(60 / 210, 0.01));
      expect(runningTimer.cooldownRatio, closeTo(150 / 210, 0.01));
      expect(runningTimer.formattedRemaining, '02:30');
      expect(runningTimer.isReady, isFalse);

      final warningTimer = runningTimer.copyWith(remainingSeconds: 25);
      expect(warningTimer.status, TimerStatus.warning);

      final urgentTimer = runningTimer.copyWith(remainingSeconds: 8, isUrgent: true);
      expect(urgentTimer.status, TimerStatus.urgent);

      final readyTimer = runningTimer.copyWith(remainingSeconds: 0);
      expect(readyTimer.status, TimerStatus.ready);
      expect(readyTimer.isReady, isTrue);
      expect(readyTimer.formattedRemaining, '00:00');
    });

    test('ActiveTimer serialization round-trip', () {
      const timer = ActiveTimer(
        id: 't_2',
        objectiveId: 'mlbb_turtle',
        name: 'Turtle',
        remainingSeconds: 45,
        totalSeconds: 120,
        targetEpochMs: 1726000000000,
        isRunning: true,
        isUrgent: false,
      );

      final json = timer.toJson();
      final reconstructed = ActiveTimer.fromJson(json);
      expect(reconstructed, equals(timer));
    });
  });

  group('3. AI Coach Feature', () {
    test('AIProvider metadata and models', () {
      expect(AIProvider.gemini.displayName, 'Google Gemini');
      expect(AIProvider.gemini.defaultModel, 'gemini-3-flash-preview');
      expect(AIProvider.gemini.availableModels, contains('gemini-3-flash-preview'));

      expect(AIProvider.openai.displayName, 'OpenAI');
      expect(AIProvider.claude.displayName, 'Anthropic Claude');
      expect(AIProvider.openrouter.displayName, 'OpenRouter');

      expect(AIProvider.sambanova.displayName, 'SambaNova');
      expect(AIProvider.sambanova.defaultModel, 'Meta-Llama-3.3-70B-Instruct');
      expect(AIProvider.sambanova.availableModels, contains('DeepSeek-R1-0528'));
      expect(AIProvider.sambanova.apiKeyStorageKey, 'owl_api_key_sambanova');

      expect(AIProvider.xkiro.displayName, 'xKiro');
      expect(AIProvider.xkiro.defaultModel, 'deepseek/deepseek-v4.1-flash');
      expect(AIProvider.xkiro.availableModels, contains('qwen/qwen3.7-flash:free'));
      expect(AIProvider.xkiro.apiKeyStorageKey, 'owl_api_key_xkiro');

      expect(AIProvider.groq.displayName, 'Groq');
      expect(AIProvider.groq.defaultModel, 'openai/gpt-oss-120b');
      expect(AIProvider.groq.availableModels, contains('qwen/qwen3.6-27b'));
      expect(AIProvider.groq.apiKeyStorageKey, 'owl_api_key_groq');
    });

    test('CoachPrompt generates well-formed LLM prompt', () {
      const prompt = CoachPrompt(
        gameName: 'Wild Rift',
        matchTimeSeconds: 495, // 08:15
        role: 'Jungler',
        currentSituation: 'Enemy team grouped around Dragon pit with low health.',
        promptType: 'objectiveContest',
        heroChampion: 'Lee Sin',
      );

      expect(prompt.formattedMatchTime, '08:15');
      final formatted = prompt.toFormattedPrompt();
      expect(formatted, contains('Wild Rift'));
      expect(formatted, contains('08:15'));
      expect(formatted, contains('Lee Sin'));
      expect(formatted, contains('Enemy team grouped'));

      final json = prompt.toJson();
      final reconstructed = CoachPrompt.fromJson(json);
      expect(reconstructed, equals(prompt));
    });

    test('CoachResponse parsing structured JSON and raw fallback', () {
      const jsonRaw =
          '{"action": "Rush Elder Dragon", "reason": "Enemy jungler dead for 25s", "warning": "Watch for Lux ult steal"}';
      final parsed = CoachResponse.fromRawText(jsonRaw);
      expect(parsed.action, 'Rush Elder Dragon');
      expect(parsed.reason, 'Enemy jungler dead for 25s');
      expect(parsed.warning, 'Watch for Lux ult steal');

      const plainRaw = 'Action: Freeze Mid Wave\nReason: Wait for support roam.\nWarning: Ward brush.';
      final parsedPlain = CoachResponse.fromRawText(plainRaw);
      expect(parsedPlain.action, 'Freeze Mid Wave');
      expect(parsedPlain.reason, 'Wait for support roam.');
      expect(parsedPlain.warning, 'Ward brush.');
    });
  });

  group('4. Overlay Feature', () {
    test('OverlayConfig defaults and serialization', () {
      const config = OverlayConfig.defaultConfig;
      expect(config.opacity, 0.85);
      expect(config.scale, 1.0);
      expect(config.snapToEdge, isTrue);
      expect(config.isClickThrough, isFalse);
      expect(config.isExpanded, isTrue);

      final modified = config.copyWith(opacity: 0.6, isClickThrough: true);
      expect(modified.opacity, 0.6);
      expect(modified.isClickThrough, isTrue);

      final json = modified.toJson();
      final reconstructed = OverlayConfig.fromJson(json);
      expect(reconstructed, equals(modified));
    });
  });

  group('5. Settings Feature', () {
    test('AppSettings defaults and serialization', () {
      const settings = AppSettings.defaultSettings;
      expect(settings.soundEnabled, isTrue);
      expect(settings.hapticsEnabled, isTrue);
      expect(settings.selectedGameId, 'wild_rift');
      expect(settings.activeAiProvider, AIProvider.gemini);

      final modified = settings.copyWith(
        soundEnabled: false,
        selectedGameId: 'mlbb',
        activeAiProvider: AIProvider.claude,
      );
      expect(modified.soundEnabled, isFalse);
      expect(modified.selectedGameId, 'mlbb');
      expect(modified.activeAiProvider, AIProvider.claude);

      final json = modified.toJson();
      final reconstructed = AppSettings.fromJson(json);
      expect(reconstructed, equals(modified));
    });
  });
}
