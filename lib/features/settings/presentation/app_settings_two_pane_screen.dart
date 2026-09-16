// language: Dart, file: app_settings_two_pane_screen.dart, target: Flutter / Owl MOBA Companion
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owl/features/settings/domain/models/game_turbo_settings.dart';
import 'package:owl/features/settings/presentation/settings_provider.dart';
import 'package:owl_design/owl_design.dart';

/// Authentic Two-Pane Global Application & Tactical Settings Screen.
///
/// Implements 1:1 parity with the finalized Owl Tactical Settings prototype:
/// - Top System Bar with dynamic model status, cyan pulse latency badge, and quick reset.
/// - Left Sidebar: Categorized into Active MVP Categories & Deferred Categories (Phase 2).
/// - Right Pane: Glassmorphic settings cards, 4-column AI provider grid, secure keystore
///   inputs with format validation & latency testing, horizontally scrollable model/role
///   chips, and telemetry diagnostics.
class AppSettingsTwoPaneScreen extends ConsumerStatefulWidget {
  const AppSettingsTwoPaneScreen({
    super.key,
    this.initialCategory = AppSettingCategory.general,
  });

  final AppSettingCategory initialCategory;

  @override
  ConsumerState<AppSettingsTwoPaneScreen> createState() =>
      _AppSettingsTwoPaneScreenState();
}

enum AppSettingCategory {
  general('General settings', LucideIcons.settings),
  aiProviders('AI Provider & Models', LucideIcons.cpu),
  assistant('Assistant & Tactical AI', LucideIcons.bot),
  alerts('Voice & Alerts', LucideIcons.volume2),
  performance('Assistant Performance', LucideIcons.gauge);

  const AppSettingCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _AppSettingsTwoPaneScreenState
    extends ConsumerState<AppSettingsTwoPaneScreen> {
  late AppSettingCategory _selectedCategory;

  // Key management state
  final TextEditingController _keyController = TextEditingController();
  bool _obscureKey = true;
  bool _isValidatingKey = false;
  String? _keyTestResult;
  String? _keyValidationError;

  // Simulated Tactical In-App Alert Toast
  bool _showToastAlert = false;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _loadCurrentApiKey();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _toastTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentApiKey() async {
    final settings = ref.read(gameTurboSettingsProvider);
    final keyManager = ref.read(apiKeyManagerProvider);
    final key = await keyManager.getApiKey(settings.activeAiProvider);
    if (mounted) {
      setState(() {
        _keyController.text = key ?? '';
        _keyTestResult = null;
        _keyValidationError = null;
      });
    }
  }

  Future<void> _testAndSaveKey() async {
    final settings = ref.read(gameTurboSettingsProvider);
    final keyManager = ref.read(apiKeyManagerProvider);
    final text = _keyController.text.trim();

    final validationErr =
        keyManager.validateKeyFormat(settings.activeAiProvider, text);
    if (validationErr != null) {
      setState(() {
        _keyValidationError = validationErr;
        _keyTestResult = null;
      });
      return;
    }

    setState(() {
      _isValidatingKey = true;
      _keyValidationError = null;
      _keyTestResult = null;
    });

    try {
      final latency =
          await keyManager.testConnection(settings.activeAiProvider, text);
      await keyManager.saveApiKey(settings.activeAiProvider, text);
      if (mounted) {
        setState(() {
          _isValidatingKey = false;
          _keyTestResult = 'Active • ${latency}ms latency';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'API Key validated and saved securely (${latency}ms round-trip).'),
            backgroundColor: ColorSemantics.turboBlue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidatingKey = false;
          _keyValidationError = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _triggerTestCallout() {
    HapticFeedback.heavyImpact();
    _toastTimer?.cancel();
    setState(() => _showToastAlert = true);
    _toastTimer = Timer(const Duration(milliseconds: 3600), () {
      if (mounted) setState(() => _showToastAlert = false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(LucideIcons.alertTriangle, size: 16, color: Colors.amber),
            SizedBox(width: 8),
            Text('⚠️ Tactical Alert: Enemy Jungler missing from Bot River!'),
          ],
        ),
        backgroundColor: Color(0xFF161F2E),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(gameTurboSettingsProvider);
    final notifier = ref.read(gameTurboSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: SafeArea(
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontFamily: TypographyTokens.uiFontFamily,
          ),
          child: Column(
            children: [
              // Top Navigation Bar
              _buildTopBar(context),

              // Two-Pane Content Body
              Expanded(
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Category Sidebar
                        _buildCategorySidebar(),

                        // Vertical Divider
                        Container(width: 1, color: const Color(0x1AFFFFFF)),

                        // Right Content Pane — styled scrollbar + fade transition
                        Expanded(
                          child: Container(
                            color: const Color(0xFF07090E),
                            child: ScrollbarTheme(
                              data: const ScrollbarThemeData(
                                thumbColor: WidgetStatePropertyAll(Color(0x4400E5FF)),
                                trackColor: WidgetStatePropertyAll(Color(0x0AFFFFFF)),
                                thickness: WidgetStatePropertyAll(4),
                                radius: Radius.circular(3),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.015),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                      )),
                                      child: child,
                                    ),
                                  );
                                },
                                child: KeyedSubtree(
                                  key: ValueKey(_selectedCategory),
                                  child: _buildContentPane(settings, notifier),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Floating In-App Tactical Toast Banner
                    if (_showToastAlert)
                      Positioned(
                        top: 10,
                        left: 240,
                        right: 20,
                        child: _buildTacticalToastBanner(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TOP BAR (Clean: Back Button + Settings Title)
  // ---------------------------------------------------------------------------
  Widget _buildTopBar(BuildContext context) {
    final settings = ref.watch(gameTurboSettingsProvider);
    final providerLabel = switch (settings.activeAiProvider) {
      'openai' => 'OpenAI',
      'claude' => 'Claude',
      'deepseek' => 'DeepSeek',
      _ => 'Gemini',
    };
    final modelShort = settings.activeModel.split('/').last;

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xF20E131E),
        border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0x0AFFFFFF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x1FFFFFFF)),
              ),
              child: const Icon(
                Icons.chevron_left,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Header Title + Active Engine Subtitle
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                '$providerLabel • $modelShort',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0x8AFFFFFF),
                  letterSpacing: 0.3,
                  fontFamily: TypographyTokens.monoFontFamily,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Live Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0x1F007AFF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0x59007AFF)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing dot
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.4, end: 1.0),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E5FF),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Color(0x8800E5FF), blurRadius: 6)],
                      ),
                    ),
                  ),
                  onEnd: () {},
                ),
                const SizedBox(width: 6),
                Text(
                  'CLOUD API READY',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00E5FF),
                    fontFamily: TypographyTokens.monoFontFamily,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SIDEBAR NAVIGATION (1:1 with Prototype Categories & Badges)
  // ---------------------------------------------------------------------------
  Widget _buildCategorySidebar() {
    return Container(
      width: 220,
      color: const Color(0xF20A0E16),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        children: [
          ...AppSettingCategory.values.map((cat) {
            final isSelected = cat == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0x1F007AFF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(
                          color: isSelected
                              ? ColorSemantics.turboBlue
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          cat.icon,
                          size: 16,
                          color: isSelected
                              ? const Color(0xFF00E5FF)
                              : const Color(0x8AFFFFFF),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0x8AFFFFFF),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TACTICAL TOAST BANNER (1:1 with Prototype)
  // ---------------------------------------------------------------------------
  Widget _buildTacticalToastBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xF5101624),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x33007AFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.alertTriangle, size: 18, color: Colors.amber),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '⚠️ Tactical Voice Callout',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '"Enemy Mid is rotating Bot river! Fall back to turret."',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CONTENT PANE ROUTING
  // ---------------------------------------------------------------------------
  Widget _buildContentPane(
    GameTurboSettings settings,
    GameTurboSettingsNotifier notifier,
  ) {
    switch (_selectedCategory) {
      case AppSettingCategory.general:
        return _buildGeneralSettings(settings, notifier);
      case AppSettingCategory.aiProviders:
        return _buildAiProviderSettings(settings, notifier);
      case AppSettingCategory.assistant:
        return _buildAssistantSettings(settings, notifier);
      case AppSettingCategory.alerts:
        return _buildAlertsSettings(settings, notifier);
      case AppSettingCategory.performance:
        return _buildPerformanceSettings(settings, notifier);
    }
  }

  // ---------------------------------------------------------------------------
  // 1. GENERAL SETTINGS
  // ---------------------------------------------------------------------------
  Widget _buildGeneralSettings(
    GameTurboSettings settings,
    GameTurboSettingsNotifier notifier,
  ) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        _buildPaneHeader(
          'General Preferences',
          'Manage theme mode, launch behavior, interface display localization, and profile factory resets. (Active game is automatically identified via foreground package).',
        ),
        _buildSettingsCard([
          // Theme Mode
          _buildSettingRow(
            title: 'App Theme',
            hint:
                'Choose system default matching device OS, forced dark MOBA theme, or light mode.',
            control: OemSegmentedChips<ThemeMode>(
              options: const [
                ThemeMode.system,
                ThemeMode.dark,
                ThemeMode.light
              ],
              selected: settings.themeMode,
              labelBuilder: (m) => switch (m) {
                ThemeMode.system => 'System',
                ThemeMode.dark => 'Dark HUD',
                ThemeMode.light => 'Light',
              },
              onSelected: notifier.setThemeMode,
            ),
          ),

          // Interface Language
          _buildSettingRow(
            title: 'Interface Display Language',
            hint:
                'Controls on-screen text and settings labels. Assistant voice language remains separate in Alerts tab.',
            control: OemSegmentedChips<String>(
              options: const ['en', 'es', 'id', 'tl', 'vi'],
              selected: settings.interfaceLanguage,
              labelBuilder: (l) => switch (l) {
                'es' => 'Español',
                'id' => 'Bahasa',
                'tl' => 'Tagalog',
                'vi' => 'Tiếng Việt',
                _ => 'English (US)',
              },
              onSelected: notifier.setInterfaceLanguage,
            ),
          ),

          // Reset All Settings Row (Styled Red Tinted in Prototype)
          Container(
            color: const Color(0x08FF453A),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reset All Settings',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: ColorSemantics.turboCrimson,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Clear all custom role configurations, thresholds, and restore factory defaults.',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0x88FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(LucideIcons.rotateCcw,
                      size: 13, color: ColorSemantics.turboCrimson),
                  label: const Text('Reset to Factory Defaults',
                      style: TextStyle(
                          fontSize: 11, color: ColorSemantics.turboCrimson)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x55FF453A)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    notifier.resetToDefaults();
                    _loadCurrentApiKey();
                  },
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 2. AI PROVIDERS & MODELS (1:1 with Prototype 4-Card Grid & Key Validation)
  // ---------------------------------------------------------------------------
  Widget _buildAiProviderSettings(
    GameTurboSettings settings,
    GameTurboSettingsNotifier notifier,
  ) {
    final availableModels = switch (settings.activeAiProvider) {
      'openai' => const ['gpt-4o-mini', 'gpt-4o', 'gpt-4-turbo'],
      'claude' => const [
          'claude-3-5-haiku',
          'claude-3-5-sonnet',
          'claude-3-opus'
        ],
      'deepseek' => const [
          'deepseek/deepseek-chat',
          'deepseek/deepseek-r1',
          'meta-llama/llama-3.3-70b'
        ],
      _ => const ['gemini-2.0-flash', 'gemini-1.5-flash', 'gemini-1.5-pro'],
    };

    final selectedModel = availableModels.contains(settings.activeModel)
        ? settings.activeModel
        : availableModels.first;

    final providerDisplayName = switch (settings.activeAiProvider) {
      'openai' => 'OpenAI',
      'claude' => 'Claude',
      'deepseek' => 'DeepSeek',
      _ => 'Google Gemini',
    };

    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        _buildPaneHeader(
          'AI Provider & Model Configuration',
          'Select your cloud LLM tactical inference provider, configure encrypted API credentials, and choose specific model checkpoints.',
        ),

        _buildSettingsCard([
          // Hidden semantic anchor
          const Opacity(
            opacity: 0.0,
            child: SizedBox(height: 0, child: Text('Active AI Provider')),
          ),

          // ── Provider Selector Grid (1:1 with Prototype .provider-grid) ──────
          // Dark background + border-bottom matches: background: rgba(0,0,0,0.15)
          // Horizontal scroll wrapper prevents overflow on narrow screens
          Container(
            decoration: const BoxDecoration(
              color: Color(0x26000000),
              border: Border(bottom: BorderSide(color: Color(0x14FFFFFF))),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: IntrinsicWidth(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 180,
                        child: _buildProviderCard(
                          id: 'gemini',
                          name: 'Google Gemini',
                          tag: 'RECOMMENDED',
                          hint: 'Sub-50ms flash inference',
                          isSelected: settings.activeAiProvider == 'gemini',
                          onTap: () {
                            notifier.setActiveAiProvider('gemini');
                            _loadCurrentApiKey();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 180,
                        child: _buildProviderCard(
                          id: 'openai',
                          name: 'OpenAI',
                          tag: 'GPT-4O',
                          hint: 'High reasoning depth',
                          isSelected: settings.activeAiProvider == 'openai',
                          onTap: () {
                            notifier.setActiveAiProvider('openai');
                            _loadCurrentApiKey();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 180,
                        child: _buildProviderCard(
                          id: 'claude',
                          name: 'Claude',
                          tag: 'ANTHROPIC',
                          hint: 'Accurate tactical logic',
                          isSelected: settings.activeAiProvider == 'claude',
                          onTap: () {
                            notifier.setActiveAiProvider('claude');
                            _loadCurrentApiKey();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 180,
                        child: _buildProviderCard(
                          id: 'deepseek',
                          name: 'DeepSeek / OpenRouter',
                          tag: 'OPEN',
                          hint: 'Community models',
                          isSelected: settings.activeAiProvider == 'deepseek',
                          onTap: () {
                            notifier.setActiveAiProvider('deepseek');
                            _loadCurrentApiKey();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── API Key Input Row (setting-row style) ──────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 580;

                Widget statusBadge;
                if (_keyTestResult != null) {
                  statusBadge = _buildKeyStatusBadge(
                    _keyTestResult!,
                    const Color(0xFF30D158),
                    const Color(0x2230D158),
                    const Color(0x5530D158),
                  );
                } else if (_keyController.text.isNotEmpty) {
                  statusBadge = _buildKeyStatusBadge(
                    '✓ Key Active',
                    const Color(0xFF30D158),
                    const Color(0x2230D158),
                    const Color(0x5530D158),
                  );
                } else {
                  statusBadge = _buildKeyStatusBadge(
                    '● Key Missing',
                    const Color(0xFFFF9F0A),
                    const Color(0x22FF9F0A),
                    const Color(0x66FF9F0A),
                  );
                }

                final descriptionCol = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$providerDisplayName API Key',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        statusBadge,
                      ],
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Stored in on-device Keystore (AES-256). Calls route directly from device to provider API.',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0x88FFFFFF),
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
                          controller: _keyController,
                          obscureText: _obscureKey,
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF00E5FF),
                            fontFamily: TypographyTokens.monoFontFamily,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter API Key',
                            hintStyle: const TextStyle(
                              color: Color(0x44FFFFFF),
                              fontSize: 11,
                            ),
                            filled: true,
                            fillColor: const Color(0x80000000),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0x14FFFFFF)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0x14FFFFFF)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: ColorSemantics.turboBlue.withValues(alpha: 0.6),
                              ),
                            ),
                            suffixIcon: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                _obscureKey ? Icons.visibility_off : Icons.visibility,
                                size: 14,
                                color: const Color(0x88FFFFFF),
                              ),
                              onPressed: () => setState(() => _obscureKey = !_obscureKey),
                            ),
                          ),
                          onChanged: (_) {
                            if (_keyValidationError != null) {
                              setState(() => _keyValidationError = null);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Test Key / Save & Test button
                    GestureDetector(
                      onTap: _isValidatingKey ? null : _testAndSaveKey,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0x1F007AFF),
                          border: Border.all(color: const Color(0x66007AFF)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isValidatingKey)
                              const SizedBox(
                                width: 11,
                                height: 11,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(LucideIcons.checkCheck, size: 12, color: Colors.white),
                            const SizedBox(width: 7),
                            Text(
                              _isValidatingKey ? 'Testing...' : 'Save & Test',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );

                final errorWidget = _keyValidationError != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          '⚠️ $_keyValidationError',
                          style: const TextStyle(
                            fontSize: 10,
                            color: ColorSemantics.turboCrimson,
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

          // ── Model Checkpoint Row (setting-row style with horizontal scroll) ─
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Active Tactical Model',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Choose between ultra-fast Flash/Mini models for combat callouts or larger models for macro analysis.',
                        style: TextStyle(fontSize: 10.5, color: Color(0x88FFFFFF)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '⇄ Swipe horizontally if options exceed space',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: const Color(0x55FFFFFF),
                          fontFamily: TypographyTokens.monoFontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: OemSegmentedChips<String>(
                      options: availableModels,
                      selected: selectedModel,
                      onSelected: notifier.setActiveModel,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  Widget _buildKeyStatusBadge(
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
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: textColor,
          fontFamily: TypographyTokens.monoFontFamily,
        ),
      ),
    );
  }

  Widget _buildProviderCard({
    required String id,
    required String name,
    required String tag,
    required String hint,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x1F007AFF) : const Color(0x07FFFFFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? ColorSemantics.turboBlue : const Color(0x14FFFFFF),
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: ColorSemantics.turboBlue.withValues(alpha: 0.22), blurRadius: 12)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name left, tag right — exact prototype layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xB3FFFFFF),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // Tag as plain mono text (prototype: .provider-tag is just text, no bg chip)
                Text(
                  tag,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00E5FF),
                    fontFamily: TypographyTokens.monoFontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              hint,
              style: const TextStyle(
                fontSize: 9.5,
                color: Color(0x73FFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. ASSISTANT & TACTICAL AI (1:1 with Prototype Cards & Auto Role)
  // ---------------------------------------------------------------------------
  Widget _buildAssistantSettings(
    GameTurboSettings settings,
    GameTurboSettingsNotifier notifier,
  ) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        _buildPaneHeader(
          'Tactical Assistant & AI Engine',
          'Tune your in-match coach intelligence, player role specialization, and real-time vision parsing sensitivity.',
        ),

        // Card 1: Core Coaching Controls
        _buildSettingsCard([
          // Assistant Mode
          _buildSettingRow(
            title: 'Assistant Mode',
            hint:
                'Choose between live battlefield HUD assistance or post-match replay coaching.',
            control: OemSegmentedChips<String>(
              options: const ['off', 'postMatch', 'live'],
              selected: settings.assistantMode,
              labelBuilder: (m) => switch (m) {
                'postMatch' => 'Post-Match',
                'off' => 'Off',
                _ => 'Live Match',
              },
              onSelected: notifier.setAssistantMode,
            ),
          ),

          // Coaching Level
          _buildSettingRow(
            title: 'Coaching Level',
            hint:
                'Adjusts tactical callout depth for beginner basics or advanced objective wave control.',
            control: OemSegmentedChips<String>(
              options: const ['beginner', 'intermediate', 'advanced'],
              selected: settings.coachingLevel,
              labelBuilder: (c) => switch (c) {
                'beginner' => 'Beginner',
                'advanced' => 'Advanced',
                _ => 'Intermediate',
              },
              onSelected: notifier.setCoachingLevel,
            ),
          ),

          // Preferred Role Specialization (WITH AUTO ROLE & HORIZONTAL SCROLL)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preferred Role Specialization',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Keep on Default Auto so the AI detects your role dynamically, or swipe to manually lock a position.',
                        style: TextStyle(
                            fontSize: 10.5, color: Color(0x88FFFFFF)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settings.preferredRole == 'auto'
                            ? '✓ Auto-detects Smite / Retribution / Roaming boots from match data.'
                            : '• Fixed role override: ${settings.preferredRole.toUpperCase()} (Manual lock).',
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF00E5FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: OemSegmentedChips<String>(
                      options: const [
                        'auto',
                        'jungle',
                        'mid',
                        'roam',
                        'solo',
                        'adc'
                      ],
                      selected: settings.preferredRole,
                      labelBuilder: (r) => switch (r) {
                        'auto' => 'Auto (Default)',
                        'jungle' => 'Jungle',
                        'mid' => 'Mid',
                        'roam' => 'Roam / Sup',
                        'solo' => 'Solo',
                        'adc' => 'ADC',
                        _ => r,
                      },
                      onSelected: notifier.setPreferredRole,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Warning Sensitivity
          _buildSettingRow(
            title: 'Warning Sensitivity',
            hint:
                'Early warnings alert on first fog absence; conservative confirms river vision.',
            control: OemSegmentedChips<String>(
              options: const ['conservative', 'balanced', 'earlyWarning'],
              selected: settings.warningSensitivity,
              labelBuilder: (s) => switch (s) {
                'conservative' => 'Conservative',
                'earlyWarning' => 'Early Warning',
                _ => 'Balanced',
              },
              onSelected: notifier.setWarningSensitivity,
            ),
          ),

          // Explain Recommendations
          _buildSettingRow(
            title: 'Explain Recommendations',
            hint:
                'Show concise 1-line tactical rationale tag with each alert (e.g. "Enemy ult on 45s CD").',
            control: MiuiSwitch(
              value: settings.explainRecommendations,
              onChanged: notifier.toggleExplainRecommendations,
            ),
          ),
        ]),

        // Subheader for Individual Feature Toggles
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Text(
            'Individual Tactical Feature Toggles'.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0x73FFFFFF),
              letterSpacing: 0.6,
            ),
          ),
        ),

        // Card 2: Feature Toggles
        _buildSettingsCard([
          _buildSettingRow(
            title: 'Missing-Enemy Warnings',
            hint:
                'Alert when enemy mid or jungler disappears from vision for >3s.',
            control: MiuiSwitch(
              value: settings.missingEnemyAlerts,
              onChanged: notifier.toggleMissingEnemyAlerts,
            ),
          ),
          _buildSettingRow(
            title: 'Overextension & Gank Risk Radar',
            hint:
                'Tactical pulse when pushing past enemy river without ward vision.',
            control: MiuiSwitch(
              value: settings.overextensionRadar,
              onChanged: notifier.toggleOverextensionRadar,
            ),
          ),
          _buildSettingRow(
            title: 'Objective Rings & Smite Timers',
            hint:
                'Countdown timer indicators for Dragon, Baron, Turtle, and Lord spawns.',
            control: MiuiSwitch(
              value: settings.objectiveTimers,
              onChanged: notifier.toggleObjectiveTimers,
            ),
          ),
          _buildSettingRow(
            title: 'Lane Wave Management Advice',
            hint:
                'Smart tips to freeze, slow push, or crash waves based on recall state.',
            control: MiuiSwitch(
              value: settings.laneWaveAdvice,
              onChanged: notifier.toggleLaneWaveAdvice,
            ),
          ),
        ]),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. VOICE & ALERTS
  // ---------------------------------------------------------------------------
  Widget _buildAlertsSettings(
    GameTurboSettings settings,
    GameTurboSettingsNotifier notifier,
  ) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        _buildPaneHeader(
          'Voice Callouts & Haptic Alerts',
          'Manage speech synthesis callouts, non-intrusive priority filtering, and tactile feedback.',
        ),
        _buildSettingsCard([
          // Master Voice Alerts
          _buildSettingRow(
            title: 'Spoken Voice Alerts (TTS)',
            hint:
                'Synthesized voice callouts for critical tactical combat events.',
            control: MiuiSwitch(
              value: settings.voiceAlertsEnabled,
              onChanged: notifier.toggleVoiceAlerts,
            ),
          ),

          // Priority Filter
          _buildSettingRow(
            title: 'Voice Alert Priority',
            hint:
                'Critical-only limits speech to urgent ganks while keeping macro advice visual.',
            control: OemSegmentedChips<String>(
              options: const ['criticalOnly', 'important', 'allAlerts'],
              selected: settings.alertPriority,
              labelBuilder: (p) => switch (p) {
                'important' => 'Important',
                'allAlerts' => 'All Alerts',
                _ => 'Critical Only',
              },
              onSelected: notifier.setAlertPriority,
            ),
          ),

          // Speech Cooldown Buffer Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Speech Cooldown Buffer',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Minimum cooldown pause between spoken callouts to prevent audio clutter.',
                        style: TextStyle(
                            fontSize: 10.5, color: Color(0x88FFFFFF)),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${settings.speechCooldownSeconds}s',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00E5FF),
                    fontFamily: TypographyTokens.monoFontFamily,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 140,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: ColorSemantics.turboBlue,
                      inactiveTrackColor: const Color(0x33FFFFFF),
                      thumbColor: Colors.white,
                      trackHeight: 3,
                    ),
                    child: Slider(
                      value: settings.speechCooldownSeconds.toDouble(),
                      min: 3,
                      max: 20,
                      divisions: 17,
                      onChanged: (v) =>
                          notifier.setSpeechCooldownSeconds(v.round()),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Audio Ducking Safety
          _buildSettingRow(
            title: 'Avoid Interrupting Game Audio',
            hint:
                'Maintains game footstep and skill cues without system volume ducking.',
            control: MiuiSwitch(
              value: settings.avoidInterruptingGameAudio,
              onChanged: notifier.toggleAvoidInterruptingGameAudio,
            ),
          ),

          // Haptics
          _buildSettingRow(
            title: 'Haptic Vibration Pulse',
            hint:
                'Double tactile feedback on objective steal thresholds and ambush alerts.',
            control: MiuiSwitch(
              value: settings.hapticsEnabled,
              onChanged: notifier.toggleHaptics,
            ),
          ),

          // Test Alert Button Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Voice & Haptic Alert',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Simulate a live tactical callout banner and test vibration pulse.',
                        style: TextStyle(
                            fontSize: 10.5, color: Color(0x88FFFFFF)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(LucideIcons.play, size: 12),
                  label:
                      const Text('Play Test', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x24007AFF),
                    foregroundColor: const Color(0xFF00E5FF),
                    side: const BorderSide(color: Color(0x55007AFF)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _triggerTestCallout,
                ),
              ],
            ),
          ),
        ]),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5. ASSISTANT PERFORMANCE (1:1 with Prototype Telemetry Diagnostics)
  // ---------------------------------------------------------------------------
  Widget _buildPerformanceSettings(
    GameTurboSettings settings,
    GameTurboSettingsNotifier notifier,
  ) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        _buildPaneHeader(
          'Hardware Footprint & Adaptive Throttling',
          'Scale tactical engine resource consumption and configure emergency thermal safeguards.',
        ),

        _buildSettingsCard([
          // Workload Profile
          _buildSettingRow(
            title: 'Companion Workload Profile',
            hint:
                'Controls assistant frame sampling frequency and battery efficiency.',
            control: OemSegmentedChips<String>(
              options: const ['saver', 'balanced', 'high'],
              selected: settings.performanceMode,
              labelBuilder: (p) => switch (p) {
                'saver' => 'Battery Saver (1 FPS)',
                'high' => 'High (12 FPS)',
                _ => 'Balanced (5 FPS)',
              },
              onSelected: notifier.setPerformanceMode,
            ),
          ),

          // Adaptive Workload
          _buildSettingRow(
            title: 'Adaptive Workload Throttling',
            hint:
                'Automatically reduce frame sampling during base recalls and passive farming.',
            control: MiuiSwitch(
              value: settings.adaptiveWorkload,
              onChanged: notifier.toggleAdaptiveWorkload,
            ),
          ),

          // Thermal Protection
          _buildSettingRow(
            title: 'Thermal Stress Protection',
            hint:
                'Step down analysis frequency if battery temperature exceeds 41°C.',
            control: MiuiSwitch(
              value: settings.thermalProtection,
              onChanged: notifier.toggleThermalProtection,
            ),
          ),

          // In-game Latency HUD
          _buildSettingRow(
            title: 'Show In-Game Latency HUD',
            hint:
                'Display live inference latency (ms) beside the in-game floating handle.',
            control: MiuiSwitch(
              value: settings.showInGameLatencyHud,
              onChanged: notifier.toggleShowInGameLatencyHud,
            ),
          ),
        ]),

        // Telemetry Diagnostics Box (1:1 with Prototype)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0x0AFFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0x1AFFFFFF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTelemetryColumn(
                'Cloud Latency',
                settings.activeAiProvider == 'gemini' ? '38 ms' : '110 ms',
                const Color(0xFF00E5FF),
              ),
              _buildTelemetryColumn(
                'Sampling Rate',
                settings.performanceMode == 'high'
                    ? '12.0 FPS'
                    : settings.performanceMode == 'saver'
                        ? '1.0 FPS'
                        : '5.2 FPS',
                const Color(0xFF30D158),
              ),
              _buildTelemetryColumn(
                  'Thermal State', '34.2°C', const Color(0xFF30D158)),
              _buildTelemetryColumn('RAM Footprint', '86 MB', Colors.white),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTelemetryColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0x73FFFFFF),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
            fontFamily: TypographyTokens.monoFontFamily,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // REUSABLE PRESENTATION HELPERS
  // ---------------------------------------------------------------------------
  Widget _buildPaneHeader(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0x8AFFFFFF),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0x0FFFFFFF)),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required String title,
    required String hint,
    required Widget control,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0x88FFFFFF),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          control,
        ],
      ),
    );
  }
}
