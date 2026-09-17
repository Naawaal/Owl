import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/game_profiles/presentation/game_discovery_provider.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl/features/settings/presentation/widgets/common/settings_tile_components.dart';
import 'package:owl_core/owl_core.dart';
import 'package:owl_design/owl_design.dart';
import 'package:owl_network/owl_network.dart';

class SettingsAiProviderSection extends ConsumerWidget {
  final GameTurboSettings settings;
  final GameTurboSettingsNotifier notifier;
  final TextEditingController keyController;
  final bool obscureKey;
  final VoidCallback onToggleObscureKey;
  final String? keyValidationError;
  final String? keyTestResult;
  final bool isValidatingKey;
  final VoidCallback onTestAndSaveKey;
  final void Function(String provider) onSelectProvider;

  const SettingsAiProviderSection({
    super.key,
    required this.settings,
    required this.notifier,
    required this.keyController,
    required this.obscureKey,
    required this.onToggleObscureKey,
    required this.keyValidationError,
    required this.keyTestResult,
    required this.isValidatingKey,
    required this.onTestAndSaveKey,
    required this.onSelectProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ColorTokens.of(context);
    final discoveryService = ref.watch(modelDiscoveryServiceProvider);
    final modelsAsync = ref.watch(discoveredModelsForCurrentProvider);
    final isRefreshing = ref.watch(isCatalogRefreshingProvider);

    final rawDiscovered = modelsAsync.valueOrNull ??
        (settings.showOnlyFreeModels
            ? discoveryService.filterFreeOnly(
                discoveryService.getFallbackModels(settings.activeAiProvider))
            : discoveryService.getFallbackModels(settings.activeAiProvider));

    final selectedModel = rawDiscovered.any((m) => m.id == settings.activeModel)
        ? settings.activeModel
        : (rawDiscovered.isNotEmpty
            ? rawDiscovered.first.id
            : settings.activeModel);

    final providerDisplayName = switch (settings.activeAiProvider) {
      'openai' => 'OpenAI',
      'claude' => 'Claude',
      'deepseek' => 'OpenRouter',
      'sambanova' => 'SambaNova',
      'xkiro' => 'xKiro',
      'groq' => 'Groq',
      _ => 'Google Gemini',
    };

    return ListView(
      padding: EdgeInsets.fromLTRB(
        22,
        22,
        22,
        22 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        const SettingsPaneHeader(
          title: 'AI Provider & Model Configuration',
          description:
              'Select your cloud LLM tactical inference provider, configure encrypted API credentials, and choose specific model checkpoints.',
        ),
        const SizedBox(height: 16),
        SettingsCard(
          children: [
            const Opacity(
              opacity: 0.0,
              child: SizedBox(height: 0, child: Text('Active AI Provider')),
            ),

            // Provider Selector Grid
            Container(
              decoration: BoxDecoration(
                color: colors.isLight
                    ? Colors.transparent
                    : ColorPrimitives.scrimBlack15,
                border: Border(
                  bottom: BorderSide(
                    color: colors.textPrimary.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: IntrinsicWidth(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        _buildProviderItem(
                          context: context,
                          id: 'gemini',
                          name: 'Google Gemini',
                          tag: 'RECOMMENDED',
                          hint: 'Sub-50ms flash inference',
                          isSelected: settings.activeAiProvider == 'gemini',
                          onTap: () => onSelectProvider('gemini'),
                        ),
                        const SizedBox(width: 8),
                        _buildProviderItem(
                          context: context,
                          id: 'openai',
                          name: 'OpenAI',
                          tag: 'GPT-4O',
                          hint: 'High reasoning depth',
                          isSelected: settings.activeAiProvider == 'openai',
                          onTap: () => onSelectProvider('openai'),
                        ),
                        const SizedBox(width: 8),
                        _buildProviderItem(
                          context: context,
                          id: 'claude',
                          name: 'Claude',
                          tag: 'ANTHROPIC',
                          hint: 'Accurate tactical logic',
                          isSelected: settings.activeAiProvider == 'claude',
                          onTap: () => onSelectProvider('claude'),
                        ),
                        const SizedBox(width: 8),
                        _buildProviderItem(
                          context: context,
                          id: 'deepseek',
                          name: 'OpenRouter',
                          tag: 'FREE TIER',
                          hint: 'Free & community models',
                          isSelected: settings.activeAiProvider == 'deepseek',
                          onTap: () => onSelectProvider('deepseek'),
                        ),
                        const SizedBox(width: 8),
                        _buildProviderItem(
                          context: context,
                          id: 'sambanova',
                          name: 'SambaNova',
                          tag: 'FREE QUOTA',
                          hint: 'Fast Llama 3.3 & R1',
                          isSelected: settings.activeAiProvider == 'sambanova',
                          onTap: () => onSelectProvider('sambanova'),
                        ),
                        const SizedBox(width: 8),
                        _buildProviderItem(
                          context: context,
                          id: 'xkiro',
                          name: 'xKiro Gateway',
                          tag: 'FREE / PRO',
                          hint: 'Free DeepSeek & Qwen',
                          isSelected: settings.activeAiProvider == 'xkiro',
                          onTap: () => onSelectProvider('xkiro'),
                        ),
                        const SizedBox(width: 8),
                        _buildProviderItem(
                          context: context,
                          id: 'groq',
                          name: 'Groq',
                          tag: 'FREE TIER',
                          hint: 'Sub-50ms LPU engine',
                          isSelected: settings.activeAiProvider == 'groq',
                          onTap: () => onSelectProvider('groq'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // API Key Input Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 580;
                  final inputColors = ColorTokens.of(context);

                  Widget statusBadge;
                  if (keyTestResult != null) {
                    statusBadge = _buildKeyStatusBadge(
                      context,
                      keyTestResult!,
                      inputColors.emeraldLive,
                      inputColors.emeraldLive.withValues(alpha: 0.13),
                      inputColors.emeraldLive.withValues(alpha: 0.33),
                    );
                  } else if (keyController.text.isNotEmpty) {
                    statusBadge = _buildKeyStatusBadge(
                      context,
                      '✓ Key Active',
                      inputColors.emeraldLive,
                      inputColors.emeraldLive.withValues(alpha: 0.13),
                      inputColors.emeraldLive.withValues(alpha: 0.33),
                    );
                  } else {
                    statusBadge = _buildKeyStatusBadge(
                      context,
                      '● Key Missing',
                      inputColors.tacticalAmber,
                      inputColors.tacticalAmber.withValues(alpha: 0.13),
                      inputColors.tacticalAmber.withValues(alpha: 0.4),
                    );
                  }

                  final descriptionCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$providerDisplayName API Key',
                            style: TypographyTokens.settingsRowTitleOf(context)
                                .copyWith(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          statusBadge,
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Stored in on-device Keystore (AES-256). Calls route directly from device to provider API.',
                        style: TypographyTokens.settingsRowDescOf(context)
                            .copyWith(
                          fontSize: 10.5,
                          color: inputColors.textPrimary.withValues(alpha: 0.53),
                          height: 1.35,
                        ),
                      ),
                    ],
                  );

                  final inputRow = Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 34,
                          child: TextField(
                            controller: keyController,
                            obscureText: obscureKey,
                            style: TypographyTokens.keyInputOf(context).copyWith(
                              fontSize: 11,
                            ),
                            decoration: InputDecoration(
                              hintText: switch (settings.activeAiProvider) {
                                'groq' => 'Enter Groq API Key (gsk_...)',
                                'gemini' => 'Enter Gemini API Key (AIza...)',
                                'openai' => 'Enter OpenAI API Key (sk-...)',
                                'claude' =>
                                  'Enter Anthropic API Key (sk-ant-...)',
                                'sambanova' => 'Enter SambaNova Cloud Key',
                                'xkiro' => 'Enter xKiro Gateway Key',
                                _ => 'Enter API Key',
                              },
                              hintStyle: TypographyTokens.keyInputOf(context)
                                  .copyWith(
                                fontSize: 11,
                                color: inputColors.textPrimary
                                    .withValues(alpha: 0.27),
                              ),
                              filled: true,
                              fillColor: inputColors.isDark
                                  ? ColorComponentTokens.keyInputBg
                                  : inputColors.inputBg,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: inputColors.textPrimary
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: inputColors.textPrimary
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: ColorTokens.turboBlue
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              suffixIcon: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  obscureKey
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 14,
                                  color: inputColors.textPrimary
                                      .withValues(alpha: 0.53),
                                ),
                                onPressed: onToggleObscureKey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: isValidatingKey ? null : onTestAndSaveKey,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: ColorPrimitives.selectBlue12,
                            border: Border.all(
                              color: ColorTokens.turboBlue.withValues(alpha: 0.4),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isValidatingKey)
                                const SizedBox(
                                  width: 11,
                                  height: 11,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: ColorTokens.turboBlue,
                                  ),
                                )
                              else
                                Icon(
                                  LucideIcons.checkCheck,
                                  size: 12,
                                  color: inputColors.textPrimary,
                                ),
                              const SizedBox(width: 7),
                              Text(
                                isValidatingKey ? 'Testing...' : 'Save & Test',
                                style: TypographyTokens.buttonTextOf(context)
                                    .copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );

                  final errorWidget = keyValidationError != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            '⚠️ $keyValidationError',
                            style: TypographyTokens.dialogActionOf(context)
                                .copyWith(
                              fontSize: 10,
                              color: inputColors.telemetryCritical,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox.shrink();

                  if (isCompact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        descriptionCol,
                        const SizedBox(height: 10),
                        inputRow,
                        errorWidget,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: descriptionCol),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 300,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [inputRow, errorWidget],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Model Checkpoint Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Select Active Tactical Model',
                                  style: TypographyTokens.settingsRowTitleOf(
                                          context)
                                      .copyWith(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: ColorTokens.turboBlue
                                        .withValues(alpha: 0.12),
                                    borderRadius: RadiusTokens.pillBadge,
                                    border: Border.all(
                                      color: ColorTokens.turboBlue
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Text(
                                    'MODELS.DEV',
                                    style: TypographyTokens.tacticalBadgeOf(
                                            context)
                                        .copyWith(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: ColorTokens.turboBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isRefreshing
                                  ? '↻ Ingesting models.dev & live gateway endpoints...'
                                  : 'Active LLM checkpoints discovered upstream • ${rawDiscovered.length} available',
                              style: TypographyTokens.settingsRowDescOf(
                                      context)
                                  .copyWith(
                                fontSize: 10.5,
                                color: colors.textPrimary.withValues(alpha: 0.53),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          HapticHelper.selectionClick();
                          notifier.toggleShowOnlyFreeModels(
                              !settings.showOnlyFreeModels);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: settings.showOnlyFreeModels
                                ? colors.emeraldLive.withValues(alpha: 0.14)
                                : colors.textPrimary.withValues(alpha: 0.04),
                            borderRadius: RadiusTokens.pillBadge,
                            border: Border.all(
                              color: settings.showOnlyFreeModels
                                  ? colors.emeraldLive
                                  : colors.textPrimary.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 7,
                                color: settings.showOnlyFreeModels
                                    ? colors.emeraldLive
                                    : colors.textPrimary.withValues(alpha: 0.35),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Free Only',
                                style: TypographyTokens.bodySmallOf(context)
                                    .copyWith(
                                  fontSize: 10.5,
                                  fontWeight: settings.showOnlyFreeModels
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: settings.showOnlyFreeModels
                                      ? colors.emeraldLive
                                      : colors.textPrimary
                                          .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: isRefreshing
                            ? null
                            : () {
                                HapticHelper.selectionClick();
                                refreshModelCatalog(ref);
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: ColorTokens.turboBlue.withValues(alpha: 0.1),
                            borderRadius: RadiusTokens.pillBadge,
                            border: Border.all(
                              color:
                                  ColorTokens.turboBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isRefreshing)
                                const SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.8,
                                    color: ColorTokens.turboBlue,
                                  ),
                                )
                              else
                                const Icon(
                                  LucideIcons.refreshCw,
                                  size: 10,
                                  color: ColorTokens.turboBlue,
                                ),
                              const SizedBox(width: 5),
                              Text(
                                isRefreshing ? 'Syncing...' : 'Sync',
                                style: TypographyTokens.bodySmallOf(context)
                                    .copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: ColorTokens.turboBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (rawDiscovered.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.textPrimary.withValues(alpha: 0.03),
                        borderRadius: RadiusTokens.card,
                        border: Border.all(
                          color: colors.borderGlass,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.alertCircle,
                            size: 15,
                            color: colors.tacticalAmber,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No zero-cost models found for $providerDisplayName with "Free Only" enabled. Disable filter or switch to SambaNova, OpenRouter, xKiro, or Groq.',
                              style: TypographyTokens.bodySmallOf(context)
                                  .copyWith(
                                fontSize: 11,
                                color:
                                    colors.textPrimary.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: rawDiscovered.map((m) {
                          final isSelected = m.id == selectedModel;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildModelCard(
                              context: context,
                              model: m,
                              isSelected: isSelected,
                              onTap: () {
                                notifier.setActiveModel(m.id);
                                final key = keyController.text.trim();
                                unawaited(
                                  ref
                                      .read(gameDiscoveryServiceProvider)
                                      .setAiCredentials(
                                        apiKey: key.isNotEmpty ? key : null,
                                        provider: settings.activeAiProvider,
                                        model: m.id,
                                      )
                                      .catchError((_) => false),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProviderItem({
    required BuildContext context,
    required String id,
    required String name,
    required String tag,
    required String hint,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 180,
      child: GestureDetector(
        onTap: () {
          HapticHelper.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? ColorTokens.turboBlue.withValues(alpha: 0.12)
                : ColorTokens.of(context).textPrimary.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? ColorTokens.turboBlue
                  : ColorTokens.of(context)
                      .textPrimary
                      .withValues(alpha: 0.08),
              width: isSelected ? 1.4 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ColorTokens.turboBlue.withValues(alpha: 0.22),
                      blurRadius: 12,
                    )
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.buttonTextOf(context).copyWith(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w700,
                        color: isSelected
                            ? ColorTokens.turboBlue
                            : ColorTokens.of(context)
                                .textPrimary
                                .withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tag,
                    style: TypographyTokens.telemetryBadge.copyWith(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: ColorTokens.of(context).keyInputText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                hint,
                style: TypographyTokens.bodySmallOf(context).copyWith(
                  fontSize: 9.5,
                  color: ColorTokens.of(context)
                      .textPrimary
                      .withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyStatusBadge(
    BuildContext context,
    String text,
    Color textColor,
    Color bgColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TypographyTokens.tacticalBadgeOf(context).copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildModelCard({
    required BuildContext context,
    required DiscoveredModel model,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = ColorTokens.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticHelper.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorTokens.turboBlue.withValues(alpha: 0.12)
              : (colors.isDark
                  ? ColorPrimitives.segTrackBlack40
                  : colors.surfaceElevated),
          borderRadius: RadiusTokens.card,
          border: Border.all(
            color: isSelected ? ColorTokens.turboBlue : colors.borderGlass,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: ColorTokens.turboBlue.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  model.name,
                  style: TypographyTokens.buttonTextOf(context).copyWith(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? ColorTokens.turboBlue
                        : colors.textPrimary,
                  ),
                ),
                if (model.formattedContext != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: colors.textPrimary.withValues(alpha: 0.08),
                      borderRadius: RadiusTokens.tag,
                    ),
                    child: Text(
                      model.formattedContext!,
                      style: TypographyTokens.tacticalBadgeOf(context).copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (model.isFree)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.emeraldLive.withValues(alpha: 0.15),
                      borderRadius: RadiusTokens.pillBadge,
                      border: Border.all(
                        color: colors.emeraldLive.withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            size: 9, color: colors.emeraldLive),
                        const SizedBox(width: 3.5),
                        Text(
                          'FREE TIER',
                          style:
                              TypographyTokens.tacticalBadgeOf(context).copyWith(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: colors.emeraldLive,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ColorTokens.turboBlue.withValues(alpha: 0.09),
                      borderRadius: RadiusTokens.pillBadge,
                      border: Border.all(
                        color: ColorTokens.turboBlue.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.zap,
                            size: 9, color: ColorTokens.turboBlue),
                        const SizedBox(width: 3.5),
                        Text(
                          'PRO MODEL',
                          style:
                              TypographyTokens.tacticalBadgeOf(context).copyWith(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: ColorTokens.turboBlue,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    model.id,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.bodySmallOf(context).copyWith(
                      fontSize: 9.5,
                      color: colors.textPrimary.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
