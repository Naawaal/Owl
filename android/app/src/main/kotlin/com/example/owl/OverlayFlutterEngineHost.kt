package com.example.owl

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Handler
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin

/**
 * Hosts a dedicated FlutterEngine that renders the same Console
 * [GameturboFloatingToolbox] UI inside the system overlay.
 *
 * Registers the same platform channels the toolbox expects from MainActivity,
 * because a second engine has its own BinaryMessenger.
 */
object OverlayFlutterEngineHost {
    const val ENGINE_ID = "owl_overlay_toolbox"
    private const val CHANNEL = "com.example.owl/overlay_ui"
    private const val STATS_CHANNEL = "com.example.owl/stats"
    private const val OVERLAY_LEGACY_CHANNEL = "com.example.owl/overlay"
    private const val SYSTEM_CHANNEL = "com.example.owl/system_controls"
    private const val VOICE_CHANNEL = "com.example.owl/voice_changer"
    private const val GAMES_CHANNEL = "com.example.owl/games"
    private const val CAPTURE_CHANNEL = "com.example.owl/screen_capture"

    @Volatile
    private var channel: MethodChannel? = null

    @Volatile
    private var statsSink: EventChannel.EventSink? = null

    @Volatile
    private var configProvider: (() -> Map<String, Any?>)? = null

    @Volatile
    private var bridgesRegistered = false

    fun ensureEngine(context: Context): FlutterEngine {
        FlutterEngineCache.getInstance().get(ENGINE_ID)?.let { cached ->
            if (cached.dartExecutor.isExecutingDart) {
                if (!bridgesRegistered) {
                    registerPlatformBridges(cached, context.applicationContext)
                }
                return cached
            }
            FlutterEngineCache.getInstance().remove(ENGINE_ID)
            try {
                cached.destroy()
            } catch (_: Exception) {
            }
            channel = null
            statsSink = null
            bridgesRegistered = false
        }

        val appContext = context.applicationContext
        val loader = FlutterInjector.instance().flutterLoader()
        if (!loader.initialized()) {
            loader.startInitialization(appContext)
            loader.ensureInitializationComplete(appContext, null)
        }

        val engine = FlutterEngine(appContext, null, false)
        try {
            GeneratedPluginRegistrant.registerWith(engine)
        } catch (e: Exception) {
            android.util.Log.w("GameTurbo", "overlay plugin registrant: ${e.message}")
            try {
                engine.plugins.add(SharedPreferencesPlugin())
            } catch (_: Exception) {
            }
        }
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(
                loader.findAppBundlePath(),
                "package:owl/overlay_entry.dart",
                "overlayMain",
            ),
        )

        channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        if (!engine.dartExecutor.isExecutingDart) {
            android.util.Log.e(
                "GameTurbo",
                "overlayMain failed to start — is overlay_entry.dart exported from main.dart?",
            )
            try {
                engine.destroy()
            } catch (_: Exception) {
            }
            channel = null
            throw IllegalStateException("overlayMain isolate failed to start")
        }

        registerPlatformBridges(engine, appContext)
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return engine
    }

    private fun registerPlatformBridges(engine: FlutterEngine, appContext: Context) {
        val messenger = engine.dartExecutor.binaryMessenger

        EventChannel(messenger, STATS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    statsSink = events
                    // Immediate snapshot so UI is not stuck on --%
                    val svc = GameTurboOverlayService.liveSnapshotOrNull()
                    if (svc != null) {
                        events.success(svc)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    statsSink = null
                }
            },
        )

        MethodChannel(messenger, OVERLAY_LEGACY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> result.success(readBatteryLevel(appContext))
                "getCpuUsage" -> result.success(GameTurboOverlayService.instanceCpuOrZero())
                else -> result.notImplemented()
            }
        }

        MethodChannel(messenger, SYSTEM_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isNotificationPolicyAccessGranted" -> {
                    result.success(
                        HardwareSystemController.isNotificationPolicyAccessGranted(appContext),
                    )
                }
                "requestNotificationPolicyAccess" -> {
                    HardwareSystemController.openNotificationPolicySettings(appContext)
                    result.success(true)
                }
                "setDndMode" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    result.success(HardwareSystemController.setDndMode(appContext, enabled))
                }
                "setWifiLowLatency" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    result.success(HardwareSystemController.setWifiLowLatency(appContext, enabled))
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(messenger, VOICE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVoiceProcessing" -> {
                    val preset = call.argument<String>("preset") ?: "commander"
                    result.success(
                        HardwareSystemController.startVoiceProcessing(appContext, preset),
                    )
                }
                "stopVoiceProcessing" -> {
                    HardwareSystemController.stopVoiceProcessing()
                    result.success(true)
                }
                "setPreset" -> {
                    val preset = call.argument<String>("preset") ?: "commander"
                    HardwareSystemController.setVoicePreset(preset)
                    result.success(true)
                }
                "isVoiceProcessingActive" -> {
                    result.success(HardwareSystemController.isVoiceRunning)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(messenger, GAMES_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setPerformanceMode" -> {
                    val isPerf = call.argument<Boolean>("isPerformance") ?: true
                    val targetFps =
                        call.argument<Int>("targetFps") ?: (if (isPerf) 120 else 60)
                    GameTurboOverlayService.setPerformanceMode(isPerf, targetFps)
                    result.success(true)
                }
                "setGameContext" -> {
                    val category = call.argument<String>("gameCategory") ?: "5v5 MOBA"
                    val role = call.argument<String>("preferredRole") ?: "auto"
                    val level = call.argument<String>("coachingLevel") ?: "intermediate"
                    val elapsed = call.argument<Int>("matchElapsedSeconds") ?: 0
                    GameTurboOverlayService.applyGameContext(category, role, level, elapsed)
                    result.success(null)
                }
                "showGuardianOverlay" -> {
                    GameTurboOverlayService.showGuardianOverlay()
                    result.success(true)
                }
                "hideGuardianOverlay" -> {
                    GameTurboOverlayService.hideGuardianOverlay()
                    result.success(true)
                }
                "updateTacticalAdvice" -> {
                    val badge = call.argument<String>("badge") ?: "GUARDIAN AI"
                    val action = call.argument<String>("action") ?: "Hold Position"
                    val warning = call.argument<String>("warning")
                    GameTurboOverlayService.updateTacticalAdvice(badge, action, warning)
                    result.success(true)
                }
                "setAiCredentials" -> {
                    val apiKey = call.argument<String>("apiKey")
                    val provider = call.argument<String>("provider") ?: "gemini"
                    val model = call.argument<String>("model") ?: "gemini-2.5-flash"
                    GameTurboOverlayService.setAiCredentials(appContext, apiKey, provider, model)
                    result.success(true)
                }
                "setGuardianVisionEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: true
                    GameTurboOverlayService.isVisionEnabled = enabled
                    result.success(true)
                }
                "hasScreenCapturePermission" -> {
                    result.success(GameTurboOverlayService.hasMediaProjectionPermission())
                }
                "requestScreenCapturePermission" -> {
                    // Overlay isolate cannot start an Activity consent flow.
                    result.success(GameTurboOverlayService.hasMediaProjectionPermission())
                }
                "setThemeMode" -> {
                    val modeStr = call.argument<String>("themeMode") ?: "system"
                    val isLight = when (modeStr) {
                        "light" -> true
                        "dark" -> false
                        else -> {
                            val nightMode = appContext.resources.configuration.uiMode and
                                android.content.res.Configuration.UI_MODE_NIGHT_MASK
                            nightMode != android.content.res.Configuration.UI_MODE_NIGHT_YES
                        }
                    }
                    GameTurboOverlayService.setThemeMode(isLight)
                    result.success(true)
                }
                "hasOverlayPermission" -> result.success(true)
                "showFloatingOverlay", "hideFloatingOverlay", "launchGame" -> {
                    // Main Activity owns lifecycle of the overlay service itself.
                    result.success(false)
                }
                // Overlay engine should not re-scan packages; main activity owns discovery.
                "getInstalledGames", "getAllApplications" -> {
                    result.success(emptyList<Map<String, Any?>>())
                }
                else -> result.notImplemented()
            }
        }

        // Same MediaProjection bridge as MainActivity so overlay coach/vision works
        // while Owl is backgrounded and only the HUD engine is alive.
        MethodChannel(messenger, CAPTURE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasCapturePermission" -> {
                    result.success(GameTurboOverlayService.hasMediaProjectionPermission())
                }
                "requestCapturePermission" -> {
                    // Cannot start Activity from overlay engine; permission is granted in-app.
                    result.success(GameTurboOverlayService.hasMediaProjectionPermission())
                }
                "getLatestFrame" -> {
                    GameTurboOverlayService.captureFrameBytes(appContext) { bytes, width, height ->
                        if (bytes != null && width > 0 && height > 0) {
                            result.success(
                                mapOf("bytes" to bytes, "width" to width, "height" to height),
                            )
                        } else {
                            result.success(null)
                        }
                    }
                }
                "stopCapture" -> result.success(true)
                else -> result.notImplemented()
            }
        }

        bridgesRegistered = true
    }

    fun bindHandlers(
        onCollapse: () -> Unit,
        onOpenGpuSettings: () -> Unit,
        provideConfig: () -> Map<String, Any?>,
    ) {
        configProvider = provideConfig
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "collapse" -> {
                    Handler(Looper.getMainLooper()).post { onCollapse() }
                    result.success(null)
                }
                "openGpuSettings" -> {
                    Handler(Looper.getMainLooper()).post { onOpenGpuSettings() }
                    result.success(null)
                }
                "requestConfig" -> {
                    result.success(configProvider?.invoke() ?: emptyMap<String, Any?>())
                }
                else -> result.notImplemented()
            }
        }
    }

    fun bindCollapseHandler(onCollapse: () -> Unit, onOpenGpuSettings: () -> Unit) {
        bindHandlers(onCollapse, onOpenGpuSettings) { emptyMap() }
    }

    fun configure(
        gameTitle: String,
        targetFps: Int,
        matchElapsedSeconds: Int = 0,
        edgeOnRight: Boolean = false,
        isPerformance: Boolean = true,
        anchorY: Int = 0,
        screenHeight: Int = 0,
    ) {
        channel?.invokeMethod(
            "configure",
            mapOf(
                "gameTitle" to gameTitle,
                "targetFps" to targetFps,
                "matchElapsedSeconds" to matchElapsedSeconds,
                "edgeOnRight" to edgeOnRight,
                "isPerformance" to isPerformance,
                "anchorY" to anchorY,
                "screenHeight" to screenHeight,
            ),
        )
    }

    fun notifyShown() {
        channel?.invokeMethod("shown", null)
        // Nudge an immediate stats frame when the toolbox opens.
        GameTurboOverlayService.liveSnapshotOrNull()?.let { emitStatsMap(it) }
    }

    fun emitStats(cpu: Int, gpu: Int, battery: Int, fps: Int) {
        emitStatsMap(
            mapOf(
                "battery" to battery,
                "cpu" to cpu,
                "gpu" to gpu,
                "fps" to fps,
            ),
        )
    }

    private fun emitStatsMap(map: Map<String, Any?>) {
        if (statsSink == null) return
        Handler(Looper.getMainLooper()).post {
            try {
                statsSink?.success(map)
            } catch (_: Exception) {
            }
        }
    }

    fun pauseLifecycle() {
        FlutterEngineCache.getInstance().get(ENGINE_ID)?.lifecycleChannel?.appIsPaused()
    }

    fun resumeLifecycle() {
        FlutterEngineCache.getInstance().get(ENGINE_ID)?.lifecycleChannel?.appIsResumed()
    }

    fun destroy() {
        channel?.setMethodCallHandler(null)
        channel = null
        statsSink = null
        configProvider = null
        bridgesRegistered = false
        FlutterEngineCache.getInstance().get(ENGINE_ID)?.let { engine ->
            FlutterEngineCache.getInstance().remove(ENGINE_ID)
            engine.destroy()
        }
    }

    private fun readBatteryLevel(context: Context): Int {
        return try {
            val intent = context.registerReceiver(
                null,
                IntentFilter(Intent.ACTION_BATTERY_CHANGED),
            )
            val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
            if (level >= 0 && scale > 0) ((level * 100f) / scale).toInt() else 0
        } catch (_: Exception) {
            0
        }
    }
}
