package com.example.owl

import android.app.AlertDialog
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.Image
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.HandlerThread
import android.util.Base64
import java.io.ByteArrayOutputStream
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.SystemClock
import android.provider.Settings
import android.view.Choreographer
import android.view.ContextThemeWrapper
import android.view.Gravity
import android.view.KeyEvent
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import io.flutter.embedding.android.FlutterTextureView
import io.flutter.embedding.android.FlutterView
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import org.json.JSONObject

/**
 * Sliding-window frame rate arrival sampler tracking genuine inter-frame timestamps.
 * Provides microsecond precision without per-frame GC allocations or CPU overhead.
 */
class FrameRateSampler(val maxSamples: Int = 128) {
    private val timestamps = LongArray(maxSamples)
    private var head = 0
    private var count = 0
    @Volatile var currentFps: Int = 0
        private set

    @Synchronized
    fun recordFrame(now: Long = SystemClock.elapsedRealtime()) {
        timestamps[head] = now
        head = (head + 1) % timestamps.size
        if (count < timestamps.size) count++
        computeFps(now)
    }

    @Synchronized
    fun computeFps(now: Long = SystemClock.elapsedRealtime()): Int {
        if (count < 2) return currentFps
        var framesInWindow = 0
        var oldestTimestamp = now
        for (i in 0 until count) {
            val idx = (head - 1 - i + timestamps.size) % timestamps.size
            val t = timestamps[idx]
            if (now - t <= 1000L) {
                framesInWindow++
                oldestTimestamp = t
            } else {
                break
            }
        }
        val windowSpan = now - oldestTimestamp
        if (framesInWindow >= 2 && windowSpan > 80L) {
            val calculated = Math.round((framesInWindow - 1) * 1000.0 / windowSpan).toInt()
            currentFps = calculated.coerceIn(15, 240)
        }
        return currentFps
    }

    @Synchronized
    fun getLastFrameAge(now: Long = SystemClock.elapsedRealtime()): Long {
        if (count == 0) return Long.MAX_VALUE
        val lastIdx = (head - 1 + timestamps.size) % timestamps.size
        return now - timestamps[lastIdx]
    }
}

/**
 * Android System Overlay Service for Xiaomi HyperOS Game Turbo 2026.
 *
 * Implements a dual-state System Alert Window (TYPE_APPLICATION_OVERLAY) over running games:
 * 1. Collapsed State: Thin Xiaomi-style vertical edge rail — slide inward or tap to open.
 * 2. Expanded State: Streamlined floating panel (~288dp width) featuring:
 *    - Signature Circular Reactor Tachometer FPS Gauge with laser beam flares & 36 radial tick marks
 *    - Integrated Horizontal Live Telemetry Strip with CPU & GPU progress meters, clock & battery
 *    - Segmented Mode Switcher (Balanced vs Performance)
 *    - 4 Essential In-Game Tools (DND, Wi-Fi, AI, Voice) rendered with crisp Lucide vector icons (no emojis)
 */
class GameTurboOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var collapsedHandleView: View? = null
    private var expandedToolboxView: View? = null
    private var overlayFlutterView: FlutterView? = null
    private var guardianOverlayView: View? = null
    private var guardianX: Int = 80
    private var guardianY: Int = 160
    private var currentDirectiveIndex: Int = 0
    private var aiHolderRef: ToolButtonHolder? = null

    var isLightMode: Boolean = false

    fun isLightModeActive(): Boolean {
        return try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val mode = prefs.getString("flutter.owl_theme_mode", "system")
            when (mode) {
                "light" -> true
                "dark" -> false
                "system" -> {
                    val nightMode = resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK
                    nightMode != android.content.res.Configuration.UI_MODE_NIGHT_YES
                }
                else -> false
            }
        } catch (_: Exception) {
            false
        }
    }

    private var currentGameName: String = "Game"
    private var currentTargetFps: Int = 120
    private var performanceCeilingFps: Int = 120
    private var isPerformanceMode: Boolean = true
    private var isDndActive: Boolean = false
    private var isWifiBoostActive: Boolean = false
    private var isAiActive: Boolean = true
    private var isVoiceChangerActive: Boolean = false
    private var pingListener: ((Int) -> Unit)? = null

    private var aiApiKey: String? = null
    private var aiProvider: String? = null
    private var aiModel: String? = null
    private val aiExecutor = java.util.concurrent.Executors.newSingleThreadExecutor()
    @Volatile private var isAnalyzingAi: Boolean = false

    // ── Live match context (pushed from Flutter via setGameContext channel) ────
    private var gameCategory: String = "5v5 MOBA"
    private var preferredRole: String = "auto"
    private var coachingLevel: String = "intermediate"
    private var matchElapsedSeconds: Int = 0

    /** Updates live match context received from the Flutter layer. */
    fun setGameContext(gameCategory: String, preferredRole: String, coachingLevel: String, matchElapsedSeconds: Int) {
        this.gameCategory = gameCategory
        this.preferredRole = preferredRole
        this.coachingLevel = coachingLevel
        this.matchElapsedSeconds = matchElapsedSeconds
        try {
            getSharedPreferences("owl_overlay_prefs", Context.MODE_PRIVATE).edit().apply {
                putString("game_category", gameCategory)
                putString("preferred_role", preferredRole)
                putString("coaching_level", coachingLevel)
                putInt("match_elapsed_seconds", matchElapsedSeconds)
                apply()
            }
        } catch (_: Exception) {}
    }

    fun detectForegroundGame(): String? {
        try {
            val usm = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            val time = System.currentTimeMillis()
            val events = usm?.queryEvents(time - 25000, time)
            if (events != null) {
                val event = UsageEvents.Event()
                var lastPkg: String? = null
                while (events.hasNextEvent()) {
                    events.getNextEvent(event)
                    if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED ||
                        event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                        if (event.packageName != packageName) {
                            lastPkg = event.packageName
                        }
                    }
                }
                if (!lastPkg.isNullOrEmpty()) {
                    val resolved = resolveGameTitle(lastPkg)
                    if (resolved != null) return resolved
                }
            }
            val stats = usm?.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, time - 60000, time)
            val topUsed = stats?.filter { it.packageName != packageName }?.maxByOrNull { it.lastTimeUsed }
            if (topUsed != null) {
                val resolved = resolveGameTitle(topUsed.packageName)
                if (resolved != null) return resolved
            }
        } catch (_: Exception) {}
        return null
    }

    private fun resolveGameTitle(pkg: String): String? {
        val lower = pkg.lowercase()
        return when {
            lower.contains("pokemon.pokemonunite") || lower.contains("pokemonunite") || lower.contains("pokemon.unite") -> "Pokémon UNITE"
            lower.contains("mobile.legends") || lower.contains("mobilelegends") -> "Mobile Legends: Bang Bang"
            lower.contains("freefire") || lower.contains("dts.freefire") -> "Free Fire"
            lower.contains("pubg") || lower.contains("tencent.ig") -> "PUBG Mobile"
            lower.contains("wildrift") || lower.contains("riotgames") -> "League of Legends: Wild Rift"
            lower.contains("callofduty") || lower.contains("codm") -> "Call of Duty: Mobile"
            lower.contains("genshin") -> "Genshin Impact"
            lower.contains("hkrpg") || lower.contains("starrail") -> "Honkai: Star Rail"
            lower.contains("brawlstars") -> "Brawl Stars"
            lower.contains("clashofclans") -> "Clash of Clans"
            lower.contains("roblox") -> "Roblox"
            lower.contains("minecraft") -> "Minecraft"
            else -> try {
                val pm = packageManager
                val info = pm.getApplicationInfo(pkg, 0)
                // Any foreground app label — never invent a demo game title.
                pm.getApplicationLabel(info).toString().takeIf { it.isNotBlank() }
            } catch (_: Exception) { null }
        }
    }

    private var handleX: Int = 0
    private var handleY: Int = 120
    private var edgeRailOnRight: Boolean = false
    private val edgeOpenThresholdPx: Int
        get() = dp(48f)

    private fun loadPersistedOverlayPositions() {
        try {
            val prefs = getSharedPreferences("owl_overlay_prefs", Context.MODE_PRIVATE)
            handleY = prefs.getInt("edge_rail_y", handleY)
            guardianX = prefs.getInt("guardian_x", guardianX)
            guardianY = prefs.getInt("guardian_y", guardianY)
        } catch (_: Exception) {
        }
    }

    private fun persistEdgeRailPosition() {
        try {
            getSharedPreferences("owl_overlay_prefs", Context.MODE_PRIVATE)
                .edit()
                .putInt("edge_rail_y", handleY)
                .apply()
        } catch (_: Exception) {
        }
    }

    private fun persistGuardianPosition() {
        try {
            getSharedPreferences("owl_overlay_prefs", Context.MODE_PRIVATE)
                .edit()
                .putInt("guardian_x", guardianX)
                .putInt("guardian_y", guardianY)
                .apply()
        } catch (_: Exception) {
        }
    }
    private val mainHandler = Handler(Looper.getMainLooper())
    /** Off-main sampling so /proc reads never hitch the game while the rail is up. */
    private val statsThread = HandlerThread("OwlOverlayStats").apply { start() }
    private val statsHandler = Handler(statsThread.looper)
    /** Last refresh rate applied to overlay windows — skip redundant display-mode switches. */
    private var lastAppliedRefreshRate: Float = -1f
    private var lastFlutterStatsEmitAtMs: Long = 0L
    private val flutterStatsMinIntervalMs = 500L
    private var guardianAutoRefreshRunnable: Runnable? = null

    fun getEffectiveAiApiKey(): String? {
        if (!aiApiKey.isNullOrEmpty()) return aiApiKey
        if (!cachedAiApiKey.isNullOrEmpty()) return cachedAiApiKey
        return try {
            getSharedPreferences("owl_overlay_prefs", Context.MODE_PRIVATE)
                .getString("ai_api_key", null)
        } catch (_: Exception) {
            null
        }
    }

    fun getEffectiveAiProvider(): String {
        aiProvider?.takeIf { it.isNotEmpty() }?.let { return it }
        cachedAiProvider?.takeIf { it.isNotEmpty() }?.let { return it }
        return try {
            getSharedPreferences("owl_overlay_prefs", Context.MODE_PRIVATE)
                .getString("ai_provider", null)?.takeIf { it.isNotEmpty() } ?: "gemini"
        } catch (_: Exception) {
            "gemini"
        }
    }

    fun getEffectiveAiModel(): String {
        aiModel?.takeIf { it.isNotEmpty() }?.let { return it }
        cachedAiModel?.takeIf { it.isNotEmpty() }?.let { return it }
        return try {
            getSharedPreferences("owl_overlay_prefs", Context.MODE_PRIVATE)
                .getString("ai_model", null)?.takeIf { it.isNotEmpty() } ?: "gemini-2.5-flash"
        } catch (_: Exception) {
            "gemini-2.5-flash"
        }
    }

    private fun startGuardianAutoRefresh(intervalMs: Long = 14000L, cycleFn: (() -> Unit)? = null) {
        stopGuardianAutoRefresh()
        val r = object : Runnable {
            override fun run() {
                if (guardianOverlayView != null) {
                    cycleFn?.invoke()
                }
            }
        }
        guardianAutoRefreshRunnable = r
        mainHandler.postDelayed(r, intervalMs)
    }

    private fun stopGuardianAutoRefresh() {
        guardianAutoRefreshRunnable?.let { mainHandler.removeCallbacks(it) }
        guardianAutoRefreshRunnable = null
    }

    // Live stat refs — updated by MainActivity.pushStats() and autonomous sampler
    @Volatile var liveCpu: Int = 0
    @Volatile var liveGpu: Int = 0
    @Volatile var liveBattery: Int = 0
    @Volatile var liveFps: Int = 0
    @Volatile private var lastGoodFps: Int = 0
    @Volatile private var lastGoodFpsAtMs: Long = 0
    var onModeUiUpdate: (() -> Unit)? = null

    val gameFrameSampler = FrameRateSampler(128)
    val overlayChoreographerSampler = FrameRateSampler(128)
    private var isChoreographerActive = false

    private val overlayFrameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            overlayChoreographerSampler.recordFrame()
            if (isChoreographerActive) {
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    fun startOverlayChoreographer() {
        if (isChoreographerActive) return
        isChoreographerActive = true
        mainHandler.post {
            Choreographer.getInstance().postFrameCallback(overlayFrameCallback)
        }
    }

    fun stopOverlayChoreographer() {
        isChoreographerActive = false
        mainHandler.post {
            Choreographer.getInstance().removeFrameCallback(overlayFrameCallback)
        }
    }

    fun getEffectiveLiveFps(): Int {
        val now = SystemClock.elapsedRealtime()
        val displayRate = try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                display?.refreshRate?.toInt() ?: (if (isPerformanceMode) 120 else 60)
            } else {
                @Suppress("DEPRECATION")
                windowManager?.defaultDisplay?.refreshRate?.toInt()
                    ?: (if (isPerformanceMode) 120 else 60)
            }
        } catch (_: Exception) {
            if (isPerformanceMode) 120 else 60
        }

        val modeCeiling = if (isPerformanceMode) displayRate else 60

        fun accept(sample: Int): Int {
            val v = sample.coerceIn(15, modeCeiling)
            lastGoodFps = v
            lastGoodFpsAtMs = now
            return v
        }

        // 1. Genuine game/vision frames (MediaProjection ImageReader ticks).
        val gameAge = gameFrameSampler.getLastFrameAge(now)
        if (gameAge < 650) {
            val gFps = gameFrameSampler.computeFps(now)
            if (gFps in 15..240) return accept(gFps)
        }

        // 2. Kernel/sysfs measured FPS (no display-ceiling invent).
        val sysfs = readSysfsMeasuredFpsOrZero()
        if (sysfs in 15..240) return accept(sysfs)

        // 3. Overlay Choreographer — last resort (UI refresh, not game).
        val overlayFps = overlayChoreographerSampler.computeFps(now)
        if (overlayFps in 15..240) return accept(overlayFps)

        // 4. Hold last-good briefly, then 0 so UI shows "--" instead of a fake ceiling.
        if (lastGoodFps > 0 && now - lastGoodFpsAtMs < 1500L) {
            return lastGoodFps.coerceIn(15, modeCeiling)
        }
        return 0
    }

    /** Sysfs measured FPS only — never falls back to display refresh target. */
    private fun readSysfsMeasuredFpsOrZero(): Int {
        val paths = listOf(
            "/sys/class/drm/card0/device/fps",
            "/sys/class/graphics/fb0/measured_fps",
            "/sys/devices/platform/soc/soc:qcom,dsi-display-primary/measured_fps",
            "/sys/devices/virtual/graphics/fb0/fps",
            "/sys/class/drm/card0-DSI-1/measured_fps",
            "/sys/devices/platform/soc/soc:qcom,dsi-display-0/measured_fps",
        )
        for (p in paths) {
            try {
                val v = java.io.File(p).readText().trim().split(".").first().toIntOrNull()
                if (v != null && v in 15..240) return v
            } catch (_: Exception) {
            }
        }
        return 0
    }

    fun updateWindowPreferredRefreshRate(rate: Float) {
        try {
            // Avoid repeated display-mode switches — they hitch the foreground game.
            if (kotlin.math.abs(rate - lastAppliedRefreshRate) < 0.5f) return
            lastAppliedRefreshRate = rate

            val wm = windowManager ?: return
            val d = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) display else @Suppress("DEPRECATION") wm.defaultDisplay
            val modes = d?.supportedModes ?: emptyArray()
            val chosenMode = if (rate <= 60f) {
                modes.firstOrNull { it.refreshRate in 59f..61f }
            } else {
                modes.filter { it.refreshRate >= 89f }.maxByOrNull { it.refreshRate }
            }

            fun applyToLp(lp: WindowManager.LayoutParams, forceModeId: Boolean) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    lp.preferredRefreshRate = rate
                }
                // preferredDisplayModeId can force a global mode change — only when HUD/guardian is up.
                if (forceModeId && chosenMode != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    lp.preferredDisplayModeId = chosenMode.modeId
                }
            }

            val hudOpen = expandedToolboxView != null || guardianOverlayView != null

            // Collapsed rail: soft hint only — never force display mode (prevents mid-match freezes).
            collapsedHandleView?.let { v ->
                (v.layoutParams as? WindowManager.LayoutParams)?.let { lp ->
                    applyToLp(lp, forceModeId = false)
                    wm.updateViewLayout(v, lp)
                }
            }
            expandedToolboxView?.let { v ->
                (v.layoutParams as? WindowManager.LayoutParams)?.let { lp ->
                    applyToLp(lp, forceModeId = hudOpen)
                    wm.updateViewLayout(v, lp)
                }
            }
            guardianOverlayView?.let { v ->
                (v.layoutParams as? WindowManager.LayoutParams)?.let { lp ->
                    applyToLp(lp, forceModeId = hudOpen)
                    wm.updateViewLayout(v, lp)
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("GameTurbo", "updateWindowPreferredRefreshRate error: ${e.message}")
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private val NOTIFICATION_ID = 4096
    private val CHANNEL_ID = "owl_game_turbo_channel"

    private fun startAsForegroundService() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "Owl Game Turbo",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Game Turbo tactical floating overlay and guardian AI coach"
                    setShowBadge(false)
                }
                val nm = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                nm?.createNotificationChannel(channel)
            }

            val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(this, CHANNEL_ID)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(this)
            }.apply {
                setContentTitle("Owl Game Turbo")
                setContentText("Tactical Overlay & Guardian AI Live")
                setSmallIcon(android.R.drawable.ic_menu_compass)
                setOngoing(true)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    setForegroundServiceBehavior(Notification.FOREGROUND_SERVICE_IMMEDIATE)
                }
            }.build()

            if (Build.VERSION.SDK_INT >= 34) {
                val serviceTypes = if (hasMediaProjectionPermission() && isVisionEnabled) {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE or
                            ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
                } else {
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
                }
                startForeground(
                    NOTIFICATION_ID,
                    notification,
                    serviceTypes
                )
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(NOTIFICATION_ID, notification)
            } else {
                startForeground(NOTIFICATION_ID, notification)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        instance = this   // register singleton for pushStats()
        startAsForegroundService()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            stopSelf()
            return START_NOT_STICKY
        }

        if (intent?.hasExtra("EXTRA_IS_LIGHT_MODE") == true) {
            isLightMode = intent.getBooleanExtra("EXTRA_IS_LIGHT_MODE", false)
        } else {
            isLightMode = isLightModeActive()
        }

        intent?.getStringExtra("EXTRA_GAME_NAME")?.trim()?.takeIf { it.isNotEmpty() }?.let {
            currentGameName = it
        }
        detectForegroundGame()?.let { currentGameName = it }
        val fpsExtra = intent?.getIntExtra("EXTRA_TARGET_FPS", -1) ?: -1
        if (fpsExtra > 0) {
            currentTargetFps = fpsExtra
            performanceCeilingFps = fpsExtra
        }
        syncPerformanceModeFromSettings(hasIntentFps = fpsExtra > 0)

        val keyExtra = intent?.getStringExtra("EXTRA_AI_API_KEY")
        aiApiKey = if (!keyExtra.isNullOrEmpty()) {
            cachedAiApiKey = keyExtra
            keyExtra
        } else {
            getEffectiveAiApiKey()
        }
        val provExtra = intent?.getStringExtra("EXTRA_AI_PROVIDER")
        aiProvider = if (!provExtra.isNullOrEmpty()) {
            cachedAiProvider = provExtra
            provExtra
        } else {
            getEffectiveAiProvider()
        }
        val modelExtra = intent?.getStringExtra("EXTRA_AI_MODEL")
        aiModel = if (!modelExtra.isNullOrEmpty()) {
            cachedAiModel = modelExtra
            modelExtra
        } else {
            getEffectiveAiModel()
        }

        val shouldExpand = intent?.getBooleanExtra("EXTRA_EXPAND", false) ?: false
        val showGuardian = intent?.getBooleanExtra("EXTRA_SHOW_GUARDIAN", true) ?: true

        syncEdgeRailFromSettings()
        syncVisionEnabledFromSettings()
        loadPersistedOverlayPositions()
        prewarmOverlayFlutterEngine()

        if (shouldExpand) {
            expandToolbox()
        } else if (collapsedHandleView == null && expandedToolboxView == null) {
            showCollapsedHandle()
        }

        if (showGuardian && isAiActive && guardianOverlayView == null) {
            showGuardianOverlay()
        }

        startAutonomousTicker()
        return START_STICKY
    }

    /** Pre-warm the overlay Flutter engine off the expand tap path. */
    private fun prewarmOverlayFlutterEngine() {
        mainHandler.post {
            try {
                OverlayFlutterEngineHost.ensureEngine(applicationContext)
                OverlayFlutterEngineHost.bindHandlers(
                    onCollapse = { mainHandler.post { collapseToHandle() } },
                    onOpenGpuSettings = { mainHandler.post { openGpuSettingsFromOverlay() } },
                    provideConfig = { overlaySessionConfig() },
                )
            } catch (e: Exception) {
                android.util.Log.w("GameTurbo", "overlay engine prewarm failed: ${e.message}")
            }
        }
    }

    private fun overlaySessionConfig(): Map<String, Any?> {
        val screenH = resources.displayMetrics.heightPixels
        // Rail window is ~88dp tall; center of bar ≈ handleY + half height.
        val railCenterY = handleY + dp(44f)
        return mapOf(
            "gameTitle" to currentGameName,
            "targetFps" to if (isPerformanceMode) currentTargetFps else 60,
            "matchElapsedSeconds" to matchElapsedSeconds,
            "edgeOnRight" to edgeRailOnRight,
            "isPerformance" to isPerformanceMode,
            "anchorY" to railCenterY,
            "screenHeight" to screenH,
        )
    }

    private fun syncEdgeRailFromSettings() {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val raw = prefs.getString("flutter.owl_game_turbo_settings_v2", null) ?: return
            val root = JSONObject(raw)
            val settings = if (root.has("settings")) root.getJSONObject("settings") else root
            val pos = settings.optString("shortcutEdgePosition", "Top-Left")
            edgeRailOnRight = pos.contains("Right", ignoreCase = true)
        } catch (_: Exception) {
        }
    }

    private fun syncVisionEnabledFromSettings() {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val raw = prefs.getString("flutter.owl_game_turbo_settings_v2", null) ?: return
            val root = JSONObject(raw)
            val settings = if (root.has("settings")) root.getJSONObject("settings") else root
            if (settings.has("guardianVisionEnabled")) {
                isVisionEnabled = settings.optBoolean("guardianVisionEnabled", true)
            }
        } catch (_: Exception) {
        }
    }

    /** Restore Balanced/Performance + FPS ceiling from Flutter prefs. */
    private fun syncPerformanceModeFromSettings(hasIntentFps: Boolean) {
        try {
            val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val raw = prefs.getString("flutter.owl_game_turbo_settings_v2", null) ?: return
            val root = JSONObject(raw)
            val settings = if (root.has("settings")) root.getJSONObject("settings") else root
            if (settings.has("performanceOptimization")) {
                isPerformanceMode = settings.optBoolean("performanceOptimization", true)
            }
            if (!isPerformanceMode) {
                currentTargetFps = 60
                // Cold-start Balanced budget: no warm capture session.
                releaseMediaProjectionSession()
            } else if (!hasIntentFps) {
                val fromGpu = settings.optString("gpuFpsTarget", "").toIntOrNull()
                if (fromGpu != null && fromGpu > 0) {
                    performanceCeilingFps = fromGpu
                    currentTargetFps = fromGpu
                } else {
                    currentTargetFps = performanceCeilingFps
                }
            } else {
                currentTargetFps = performanceCeilingFps
            }
        } catch (_: Exception) {
        }
    }

    private fun openGpuSettingsFromOverlay() {
        try {
            val launch = packageManager.getLaunchIntentForPackage(packageName)?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("EXTRA_OPEN_GPU_SETTINGS", true)
            }
            if (launch != null) startActivity(launch)
        } catch (e: Exception) {
            android.util.Log.w("GameTurbo", "openGpuSettings failed: ${e.message}")
        }
    }

    private fun requireWindowManager(): WindowManager? {
        windowManager?.let { return it }
        val wm = getSystemService(WINDOW_SERVICE) as? WindowManager ?: return null
        windowManager = wm
        return wm
    }

    private fun dp(value: Float): Int {
        return (value * resources.displayMetrics.density).toInt()
    }

    /**
     * Xiaomi Game Turbo-style thin vertical edge rail.
     * Flush to the absolute left/right screen edge. Slide inward or tap to expand.
     */
    private fun showCollapsedHandle() {
        if (collapsedHandleView != null || expandedToolboxView != null) return

        val wm = getSystemService(WINDOW_SERVICE) as? WindowManager ?: return
        windowManager = wm

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val screenW = resources.displayMetrics.widthPixels
        val screenH = resources.displayMetrics.heightPixels
        // Prefer last known side; default left edge mid-upper.
        if (handleY < dp(48f) || handleY > screenH - dp(96f)) {
            handleY = (screenH * 0.28f).toInt()
        }

        val params = WindowManager.LayoutParams(
            dp(28f),
            dp(88f),
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        ).apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                layoutInDisplayCutoutMode =
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
            // Absolute edge docking — x always 0 against START or END gravity.
            gravity = Gravity.TOP or (if (edgeRailOnRight) Gravity.END else Gravity.START)
            x = 0
            y = handleY
        }

        val hitTarget = FrameLayout(this).apply {
            tag = "edge_rail_root"
            // Transparent hit strip flush to edge
            setBackgroundColor(Color.TRANSPARENT)
        }

        val rail = View(this).apply {
            tag = "edge_rail_bar"
            background = buildEdgeRailDrawable(0f)
            layoutParams = FrameLayout.LayoutParams(dp(5f), dp(64f)).apply {
                gravity = Gravity.CENTER_VERTICAL or
                    (if (edgeRailOnRight) Gravity.END else Gravity.START)
                // 1dp inset so it sits visibly on the glass edge, not under bezels
                marginStart = if (edgeRailOnRight) 0 else dp(1f)
                marginEnd = if (edgeRailOnRight) dp(1f) else 0
            }
        }
        hitTarget.addView(rail)

        var initialY = 0
        var initialTouchX = 0f
        var initialTouchY = 0f
        var inwardDrag = 0f
        var isRepositioning = false

        hitTarget.setOnTouchListener { v, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialY = params.y
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                    inwardDrag = 0f
                    isRepositioning = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - initialTouchX
                    val dy = event.rawY - initialTouchY
                    val inward = if (edgeRailOnRight) -dx else dx

                    if (!isRepositioning && Math.abs(dy) > dp(12f) && Math.abs(dy) > Math.abs(dx) * 1.2f) {
                        isRepositioning = true
                    }

                    if (isRepositioning) {
                        params.y = (initialY + dy.toInt()).coerceIn(dp(24f), screenH - dp(110f))
                        handleY = params.y
                        wm.updateViewLayout(v, params)
                    } else if (inward > 0) {
                        inwardDrag = inward
                        val pull = inward.coerceIn(0f, dp(80f).toFloat())
                        val g = pull / dp(80f).toFloat()
                        rail.background = buildEdgeRailDrawable(g)
                        (rail.layoutParams as FrameLayout.LayoutParams).apply {
                            width = dp(5f) + (pull * 0.05f).toInt()
                            val pullPx = (pull * 0.2f).toInt()
                            marginStart = if (edgeRailOnRight) 0 else dp(1f) + pullPx
                            marginEnd = if (edgeRailOnRight) dp(1f) + pullPx else 0
                        }
                        rail.requestLayout()
                    }
                    true
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    rail.background = buildEdgeRailDrawable(0f)
                    (rail.layoutParams as FrameLayout.LayoutParams).apply {
                        width = dp(5f)
                        marginStart = if (edgeRailOnRight) 0 else dp(1f)
                        marginEnd = if (edgeRailOnRight) dp(1f) else 0
                    }
                    rail.requestLayout()

                    // Stay locked to the same edge — Xiaomi rails don't free-float.
                    params.x = 0
                    params.gravity = Gravity.TOP or
                        (if (edgeRailOnRight) Gravity.END else Gravity.START)
                    wm.updateViewLayout(v, params)
                    if (isRepositioning) {
                        persistEdgeRailPosition()
                    }

                    val tapped = Math.abs(event.rawX - initialTouchX) < dp(8f) &&
                        Math.abs(event.rawY - initialTouchY) < dp(8f)
                    if (!isRepositioning && (inwardDrag >= edgeOpenThresholdPx || tapped)) {
                        expandToolbox()
                    }
                    inwardDrag = 0f
                    true
                }
                else -> false
            }
        }

        try {
            wm.addView(hitTarget, params)
            collapsedHandleView = hitTarget
            // Do NOT start Choreographer while collapsed — per-frame callbacks hitch gameplay.
            stopOverlayChoreographer()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun buildEdgeRailDrawable(glowFraction: Float): GradientDrawable {
        val g = glowFraction.coerceIn(0f, 1f)
        val fillAlpha = (0xB3 + (0x4C * g)).toInt().coerceIn(0, 255)
        val strokeAlpha = (0x99 + (0x66 * g)).toInt().coerceIn(0, 255)
        val core = if (isLightMode) Color.parseColor("#0284C7") else Color.parseColor("#389BFF")
        return GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            cornerRadius = dp(999f).toFloat()
            setColor(Color.argb(fillAlpha, Color.red(core), Color.green(core), Color.blue(core)))
            setStroke(
                dp(1.2f),
                Color.argb(strokeAlpha, Color.red(core), Color.green(core), Color.blue(core))
            )
        }
    }

    fun refreshCollapsedHandleTheme() {
        val rail = collapsedHandleView?.findViewWithTag<View>("edge_rail_bar") ?: return
        rail.background = buildEdgeRailDrawable(0f)
    }

    /**
     * Expands the in-game toolbox using the same Flutter [GameturboFloatingToolbox]
     * as Console — hosted in a MATCH_PARENT FlutterTextureView overlay.
     * Engine is pre-warmed; attach happens only after non-zero layout.
     */
    private fun expandToolbox() {
        if (expandedToolboxView != null) return
        val wm = requireWindowManager() ?: return

        // Prefer the real foreground / launched title over any stale default.
        detectForegroundGame()?.let { currentGameName = it }

        collapsedHandleView?.let {
            try {
                wm.removeView(it)
            } catch (_: Exception) {
            }
            collapsedHandleView = null
        }

        val engine = try {
            OverlayFlutterEngineHost.ensureEngine(applicationContext).also {
                OverlayFlutterEngineHost.bindHandlers(
                    onCollapse = { mainHandler.post { collapseToHandle() } },
                    onOpenGpuSettings = { mainHandler.post { openGpuSettingsFromOverlay() } },
                    provideConfig = { overlaySessionConfig() },
                )
            }
        } catch (e: Exception) {
            android.util.Log.e("GameTurbo", "overlay engine unavailable: ${e.message}", e)
            showCollapsedHandle()
            return
        }

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        // Expanded window is focusable so BACK collapses; no FLAG_NOT_FOCUSABLE.
        val rootParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                layoutInDisplayCutoutMode =
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
            softInputMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING
        }

        val flutterView = FlutterView(this, FlutterTextureView(this)).apply {
            setBackgroundColor(Color.TRANSPARENT)
            layoutParams = FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT,
            )
        }

        val root = object : FrameLayout(this) {
            override fun dispatchKeyEvent(event: KeyEvent): Boolean {
                if (event.keyCode == KeyEvent.KEYCODE_BACK &&
                    event.action == KeyEvent.ACTION_UP
                ) {
                    collapseToHandle()
                    return true
                }
                return super.dispatchKeyEvent(event)
            }
        }.apply {
            setBackgroundColor(Color.TRANSPARENT)
            isFocusableInTouchMode = true
            addView(flutterView)
        }

        try {
            wm.addView(root, rootParams)
            expandedToolboxView = root
            overlayFlutterView = flutterView
            root.requestFocus()

            val attachListener = object : ViewTreeObserver.OnGlobalLayoutListener {
                override fun onGlobalLayout() {
                    if (flutterView.width <= 0 || flutterView.height <= 0) return
                    flutterView.viewTreeObserver.removeOnGlobalLayoutListener(this)
                    try {
                        flutterView.attachToFlutterEngine(engine)
                        OverlayFlutterEngineHost.resumeLifecycle()
                        OverlayFlutterEngineHost.configure(
                            gameTitle = currentGameName,
                            targetFps = if (isPerformanceMode) currentTargetFps else 60,
                            matchElapsedSeconds = matchElapsedSeconds,
                            edgeOnRight = edgeRailOnRight,
                            isPerformance = isPerformanceMode,
                            anchorY = handleY + dp(44f),
                            screenHeight = resources.displayMetrics.heightPixels,
                        )
                        OverlayFlutterEngineHost.notifyShown()
                        startOverlayChoreographer()
                        android.util.Log.i(
                            "GameTurbo",
                            "overlay FlutterView attached ${flutterView.width}x${flutterView.height}",
                        )
                    } catch (e: Exception) {
                        android.util.Log.e("GameTurbo", "FlutterView attach failed: ${e.message}", e)
                        collapseToHandle()
                    }
                }
            }
            flutterView.viewTreeObserver.addOnGlobalLayoutListener(attachListener)
        } catch (e: Exception) {
            android.util.Log.e("GameTurbo", "expandToolbox failed: ${e.message}", e)
            overlayFlutterView = null
            expandedToolboxView = null
            showCollapsedHandle()
        }
    }

    fun refreshExpandedToolboxTheme() {
        if (expandedToolboxView == null || overlayFlutterView == null) return
        OverlayFlutterEngineHost.configure(
            gameTitle = currentGameName,
            targetFps = if (isPerformanceMode) currentTargetFps else 60,
            matchElapsedSeconds = matchElapsedSeconds,
            edgeOnRight = edgeRailOnRight,
            isPerformance = isPerformanceMode,
            anchorY = handleY + dp(44f),
            screenHeight = resources.displayMetrics.heightPixels,
        )
        OverlayFlutterEngineHost.notifyShown()
    }

    private fun collapseToHandle() {
        val wm = windowManager ?: return

        pingListener?.let {
            HardwareSystemController.removePingListener(it)
            pingListener = null
        }

        stopOverlayChoreographer()
        OverlayFlutterEngineHost.pauseLifecycle()
        overlayFlutterView?.let { fv ->
            try {
                fv.detachFromFlutterEngine()
            } catch (_: Exception) {
            }
        }
        overlayFlutterView = null

        expandedToolboxView?.let { view ->
            try {
                wm.removeView(view)
            } catch (_: Exception) {
            }
            expandedToolboxView = null
        }

        showCollapsedHandle()
    }

    /**
     * Builds the unified toolbox content:
     * - Top Header Bar with Lucide zap & close icons
     * - Circular Reactor Tachometer FPS Gauge with tick ring and laser flares
     * - Horizontal Live Telemetry Progress Meters (CPU & GPU)
     * - Segmented Mode Switcher (Balanced vs Performance)
     * - 4 Essential Quick Tools (DND, Wi-Fi, AI, Voice) with crisp Lucide vector icons
     */
    private fun buildToolboxContent(card: LinearLayout) {
        // 1. Compact Header Bar
        val headerRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply { bottomMargin = dp(6f) }

            val titleLayout = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)

                val zap = LucideIconView(context, LucideIconView.TYPE_ZAP, Color.parseColor("#FF5A5F"), 1.8f).apply {
                    layoutParams = LinearLayout.LayoutParams(dp(12f), dp(12f)).apply {
                        marginEnd = dp(5f)
                    }
                }
                addView(zap)

                val title = TextView(context).apply {
                    text = "Gaming tools"
                    textSize = 11.5f
                    typeface = Typeface.DEFAULT_BOLD
                    setTextColor(if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE)
                }
                addView(title)
            }
            addView(titleLayout)

            val closeBtn = FrameLayout(context).apply {
                background = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(if (isLightMode) Color.parseColor("#F1F5F9") else Color.parseColor("#1AFFFFFF"))
                    if (isLightMode) {
                        setStroke(dp(1f), Color.parseColor("#E2E8F0"))
                    }
                }
                layoutParams = LinearLayout.LayoutParams(dp(22f), dp(22f))
                val icon = LucideIconView(
                    context,
                    LucideIconView.TYPE_CLOSE,
                    if (isLightMode) Color.parseColor("#475569") else Color.parseColor("#CBD5E1"),
                    1.8f
                ).apply {
                    layoutParams = FrameLayout.LayoutParams(dp(10f), dp(10f), Gravity.CENTER)
                }
                addView(icon)
                setOnClickListener { collapseToHandle() }
            }
            addView(closeBtn)
        }
        card.addView(headerRow)

        // 2. Signature Circular Reactor Tachometer Gauge + Horizontal Telemetry Meters
        val gaugeContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dp(12f).toFloat()
                if (isLightMode) {
                    setColor(Color.parseColor("#F8FAFC"))
                    setStroke(dp(1f), Color.parseColor("#E2E8F0"))
                } else {
                    setColor(Color.parseColor("#10FFFFFF"))
                    setStroke(dp(1f), Color.parseColor("#1FFFFFFF"))
                }
            }
            setPadding(dp(10f), dp(6f), dp(10f), dp(7f))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply { bottomMargin = dp(7f) }

            // Top Row: Clock & Battery
            val metaRow = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply { bottomMargin = dp(3f) }

                val timeText = TextView(context).apply {
                    val sdf = SimpleDateFormat("HH:mm", Locale.getDefault())
                    text = sdf.format(Date())
                    textSize = 8.5f
                    typeface = Typeface.DEFAULT_BOLD
                    setTextColor(if (isLightMode) Color.parseColor("#64748B") else Color.parseColor("#8E9BAE"))
                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                }
                addView(timeText)

                val battLayout = LinearLayout(context).apply {
                    orientation = LinearLayout.HORIZONTAL
                    gravity = Gravity.CENTER_VERTICAL

                    val battIcon = LucideIconView(context, LucideIconView.TYPE_BATTERY_CHARGING, Color.parseColor("#30D158"), 1.6f).apply {
                        layoutParams = LinearLayout.LayoutParams(dp(12f), dp(9f)).apply {
                            marginEnd = dp(3f)
                        }
                    }
                    addView(battIcon)

                    val battText = TextView(context).apply {
                        text = "${getBatteryLevel()}%"
                        textSize = 8.5f
                        typeface = Typeface.DEFAULT_BOLD
                        setTextColor(if (isLightMode) Color.parseColor("#64748B") else Color.parseColor("#8E9BAE"))
                    }
                    addView(battText)
                }
                addView(battLayout)
            }
            addView(metaRow)

            // Center Circular Dial with Horizontal Laser Flares and Radial Tick Marks
            val reactorGaugeView = ReactorGaugeView(context).apply {
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    dp(66f)
                )
                this.isLightMode = this@GameTurboOverlayService.isLightMode
                setMode(
                    isPerformanceMode,
                    if (isPerformanceMode) currentTargetFps else 60,
                    if (isPerformanceMode) currentTargetFps else 60,
                )
            }
            addView(reactorGaugeView)

            // Horizontal Live Telemetry Progress Meters (CPU & GPU)
            val telemetryRow = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply { topMargin = dp(4f) }

                // CPU
                val cpuCol = LinearLayout(context).apply {
                    orientation = LinearLayout.VERTICAL
                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                        marginEnd = dp(6f)
                    }

                    val cpuValText = TextView(context).apply {
                        text = "${liveCpu}%"
                        textSize = 8.5f
                        typeface = Typeface.DEFAULT_BOLD
                        setTextColor(if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE)
                        tag = "cpu_val"
                    }

                    val cpuLabelRow = LinearLayout(context).apply {
                        orientation = LinearLayout.HORIZONTAL
                        val l = TextView(context).apply {
                            text = "CPU"
                            textSize = 7.5f
                            setTextColor(if (isLightMode) Color.parseColor("#64748B") else Color.parseColor("#8E9BAE"))
                            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                        }
                        addView(l)
                        addView(cpuValText)
                    }
                    addView(cpuLabelRow)

                    val cpuProgress = TelemetryProgressBarView(
                        context,
                        liveCpu / 100f,
                        if (isLightMode) {
                            if (isPerformanceMode) Color.parseColor("#FF3B30") else Color.parseColor("#0284C7")
                        } else {
                            if (isPerformanceMode) Color.parseColor("#FF3B30") else Color.parseColor("#007AFF")
                        },
                        if (isLightMode) {
                            if (isPerformanceMode) Color.parseColor("#FB7185") else Color.parseColor("#38BDF8")
                        } else {
                            if (isPerformanceMode) Color.parseColor("#FF6961") else Color.parseColor("#60A5FA")
                        },
                        isLightMode = isLightMode
                    ).apply {
                        layoutParams = LinearLayout.LayoutParams(
                            ViewGroup.LayoutParams.MATCH_PARENT,
                            dp(3.5f)
                        ).apply { topMargin = dp(2f) }
                        tag = "cpu_bar"
                    }
                    addView(cpuProgress)
                    tag = Pair(cpuValText, cpuProgress)
                }
                addView(cpuCol)

                // GPU
                val gpuCol = LinearLayout(context).apply {
                    orientation = LinearLayout.VERTICAL
                    layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                        marginStart = dp(6f)
                    }

                    val gpuValText = TextView(context).apply {
                        text = "${liveGpu}%"
                        textSize = 8.5f
                        typeface = Typeface.DEFAULT_BOLD
                        setTextColor(if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE)
                        tag = "gpu_val"
                    }

                    val gpuLabelRow = LinearLayout(context).apply {
                        orientation = LinearLayout.HORIZONTAL
                        val l = TextView(context).apply {
                            text = "GPU"
                            textSize = 7.5f
                            setTextColor(if (isLightMode) Color.parseColor("#64748B") else Color.parseColor("#8E9BAE"))
                            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                        }
                        addView(l)
                        addView(gpuValText)
                    }
                    addView(gpuLabelRow)

                    val gpuProgress = TelemetryProgressBarView(
                        context,
                        liveGpu / 100f,
                        if (isLightMode) Color.parseColor("#7C3AED") else Color.parseColor("#8B5CF6"),
                        if (isLightMode) Color.parseColor("#A78BFA") else Color.parseColor("#C084FC"),
                        isLightMode = isLightMode
                    ).apply {
                        layoutParams = LinearLayout.LayoutParams(
                            ViewGroup.LayoutParams.MATCH_PARENT,
                            dp(3.5f)
                        ).apply { topMargin = dp(2f) }
                        tag = "gpu_bar"
                    }
                    addView(gpuProgress)
                    tag = Pair(gpuValText, gpuProgress)
                }
                addView(gpuCol)
            }
            addView(telemetryRow)

            tag = Triple(reactorGaugeView, telemetryRow.getChildAt(0), telemetryRow.getChildAt(1))
        }
        card.addView(gaugeContainer)

        // 3. Segmented Mode Switcher (Balanced vs Performance) - Spacious & Flagship
        val modeSwitcher = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dp(999f).toFloat()
                if (isLightMode) {
                    setColor(Color.parseColor("#F1F5F9"))
                    setStroke(dp(1f), Color.parseColor("#CBD5E1"))
                } else {
                    setColor(Color.parseColor("#1AFFFFFF"))
                    setStroke(dp(1f), Color.parseColor("#1FFFFFFF"))
                }
            }
            setPadding(dp(3.5f), dp(3.5f), dp(3.5f), dp(3.5f))
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply { 
                topMargin = dp(2f)
                bottomMargin = dp(8f) 
            }

            lateinit var balancedBtn: TextView
            lateinit var perfBtn: TextView

            fun updateModeUi() {
                val unselectedTextColor = if (isLightMode) Color.parseColor("#475569") else Color.parseColor("#8E9BAE")
                if (isPerformanceMode) {
                    perfBtn.background = GradientDrawable(
                        GradientDrawable.Orientation.LEFT_RIGHT,
                        intArrayOf(Color.parseColor("#FF3B30"), Color.parseColor("#E63946"))
                    ).apply {
                        cornerRadius = dp(999f).toFloat()
                    }
                    perfBtn.setTextColor(Color.WHITE)
                    balancedBtn.background = null
                    balancedBtn.setTextColor(unselectedTextColor)
                } else {
                    balancedBtn.background = GradientDrawable(
                        GradientDrawable.Orientation.LEFT_RIGHT,
                        if (isLightMode) intArrayOf(Color.parseColor("#0284C7"), Color.parseColor("#0369A1"))
                        else intArrayOf(Color.parseColor("#007AFF"), Color.parseColor("#0055B8"))
                    ).apply {
                        cornerRadius = dp(999f).toFloat()
                    }
                    balancedBtn.setTextColor(Color.WHITE)
                    perfBtn.background = null
                    perfBtn.setTextColor(unselectedTextColor)
                }

                val triple = gaugeContainer.tag as? Triple<*, *, *>
                val gauge = triple?.first as? ReactorGaugeView
                val displayFps = if (liveFps > 0) liveFps else (if (isPerformanceMode) currentTargetFps else 60)
                gauge?.isLightMode = isLightMode
                gauge?.setMode(
                    isPerformanceMode,
                    displayFps,
                    if (isPerformanceMode) currentTargetFps else 60,
                )

                val cpuPair = (triple?.second as? View)?.tag as? Pair<*, *>
                (cpuPair?.first as? TextView)?.apply {
                    text = "${liveCpu}%"
                    setTextColor(if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE)
                }
                (cpuPair?.second as? TelemetryProgressBarView)?.let { bar ->
                    bar.isLightMode = isLightMode
                    bar.updateProgress(
                        liveCpu / 100f,
                        if (isPerformanceMode) Color.parseColor("#FF3B30") else (if (isLightMode) Color.parseColor("#0284C7") else Color.parseColor("#007AFF")),
                        if (isPerformanceMode) Color.parseColor("#FF6961") else (if (isLightMode) Color.parseColor("#38BDF8") else Color.parseColor("#60A5FA"))
                    )
                }

                val gpuPair = (triple?.third as? View)?.tag as? Pair<*, *>
                (gpuPair?.first as? TextView)?.apply {
                    text = "${liveGpu}%"
                    setTextColor(if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE)
                }
                (gpuPair?.second as? TelemetryProgressBarView)?.let { bar ->
                    bar.isLightMode = isLightMode
                    bar.updateProgress(
                        liveGpu / 100f,
                        if (isLightMode) Color.parseColor("#7C3AED") else Color.parseColor("#8B5CF6"),
                        if (isLightMode) Color.parseColor("#A78BFA") else Color.parseColor("#C084FC")
                    )
                }
            }

            balancedBtn = TextView(context).apply {
                text = "Balanced"
                textSize = 10.5f
                typeface = Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER
                setPadding(dp(12f), dp(7.5f), dp(12f), dp(7.5f))
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                setOnClickListener {
                    isPerformanceMode = false
                    currentTargetFps = 60
                    updateModeUi()
                    updateWindowPreferredRefreshRate(60f)
                    val effective = getEffectiveLiveFps().coerceAtMost(60)
                    pushStats(liveCpu, liveGpu, liveBattery, effective)
                    try {
                        getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                            .edit()
                            .putBoolean("flutter.owl_settings_performance_optimization", false)
                            .apply()
                    } catch (_: Exception) {}
                }
            }
            addView(balancedBtn)

            perfBtn = TextView(context).apply {
                text = "⚡ Performance"
                textSize = 10.5f
                typeface = Typeface.DEFAULT_BOLD
                gravity = Gravity.CENTER
                setPadding(dp(12f), dp(7.5f), dp(12f), dp(7.5f))
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                setOnClickListener {
                    isPerformanceMode = true
                    currentTargetFps = performanceCeilingFps.coerceAtLeast(60)
                    updateModeUi()
                    updateWindowPreferredRefreshRate(currentTargetFps.toFloat())
                    val effective = getEffectiveLiveFps()
                    pushStats(liveCpu, liveGpu, liveBattery, effective)
                    try {
                        getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                            .edit()
                            .putBoolean("flutter.owl_settings_performance_optimization", true)
                            .apply()
                    } catch (_: Exception) {}
                }
            }
            addView(perfBtn)

            onModeUiUpdate = { updateModeUi() }
            updateModeUi()
        }
        card.addView(modeSwitcher)

        isDndActive = HardwareSystemController.isDndEnabled
        isWifiBoostActive = HardwareSystemController.isWifiBoostActive
        isVoiceChangerActive = HardwareSystemController.isVoiceRunning

        // 4. Essential 4 Tools (DND / Wi-Fi / AI / Voice) with Lucide vector icons
        val toolsRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )

            // DND
            val (_, dndHolder) = createToggleToolButton(
                LucideIconView.TYPE_BELL_OFF,
                "DND",
                isDndActive,
                Color.parseColor("#FF453A")
            ) { targetActive, holder ->
                val success = HardwareSystemController.setDndMode(this@GameTurboOverlayService, targetActive)
                if (success) {
                    isDndActive = targetActive
                    holder.updateState(isDndActive)
                    Toast.makeText(context, "DND: ${if (isDndActive) "PRIORITY" else "OFF"}", Toast.LENGTH_SHORT).show()
                } else {
                    holder.updateState(isDndActive)
                    Toast.makeText(context, "Notification Policy Access required for DND", Toast.LENGTH_SHORT).show()
                }
            }
            addView(dndHolder.root)

            // Wi-Fi
            val initialWifiBadge = if (isWifiBoostActive) "${HardwareSystemController.livePingMs}ms" else null
            val (_, wifiHolder) = createToggleToolButton(
                LucideIconView.TYPE_WIFI,
                "Wi-Fi",
                isWifiBoostActive,
                Color.parseColor("#389BFF"),
                initialBadge = initialWifiBadge
            ) { targetActive, holder ->
                val success = HardwareSystemController.setWifiLowLatency(this@GameTurboOverlayService, targetActive)
                if (success) {
                    isWifiBoostActive = targetActive
                    val badge = if (isWifiBoostActive) "${HardwareSystemController.livePingMs}ms" else null
                    holder.updateState(isWifiBoostActive, badge)
                    Toast.makeText(context, "Wi-Fi Boost: ${if (isWifiBoostActive) "${HardwareSystemController.livePingMs}ms" else "OFF"}", Toast.LENGTH_SHORT).show()
                } else {
                    holder.updateState(isWifiBoostActive)
                }
            }
            addView(wifiHolder.root)

            // Register live ping tracking on Wi-Fi button badge
            pingListener?.let { HardwareSystemController.removePingListener(it) }
            val pListener: (Int) -> Unit = { pingMs ->
                mainHandler.post {
                    if (isWifiBoostActive) {
                        wifiHolder.updateState(true, "${pingMs}ms")
                    }
                }
            }
            pingListener = pListener
            HardwareSystemController.addPingListener(pListener)

            // AI Assistant / Guide
            val (_, aiHolder) = createToggleToolButton(
                LucideIconView.TYPE_BOT,
                "AI",
                isAiActive,
                Color.parseColor("#389BFF")
            ) { targetActive, holder ->
                isAiActive = targetActive
                holder.updateState(isAiActive)
                if (isAiActive) {
                    showGuardianOverlay()
                    Toast.makeText(context, "Guardian AI Overlay: ON", Toast.LENGTH_SHORT).show()
                } else {
                    hideGuardianOverlay()
                    Toast.makeText(context, "Guardian AI Overlay: OFF", Toast.LENGTH_SHORT).show()
                }
            }
            aiHolderRef = aiHolder
            addView(aiHolder.root)

            // Voice Changer
            val voicePresetName = HardwareSystemController.activeVoicePreset.replaceFirstChar {
                if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
            }
            val initialVoiceBadge = if (isVoiceChangerActive) voicePresetName else null

            lateinit var voiceHolderRef: ToolButtonHolder
            val (_, voiceHolder) = createToggleToolButton(
                LucideIconView.TYPE_MIC,
                "Voice",
                isVoiceChangerActive,
                Color.parseColor("#A855F7"),
                initialBadge = initialVoiceBadge,
                onLongClick = {
                    showVoicePresetDialog(voiceHolderRef)
                }
            ) { targetActive, holder ->
                if (targetActive) {
                    val started = HardwareSystemController.startVoiceProcessing(
                        this@GameTurboOverlayService,
                        HardwareSystemController.activeVoicePreset
                    )
                    if (started) {
                        isVoiceChangerActive = true
                        val preset = HardwareSystemController.activeVoicePreset.replaceFirstChar {
                            if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
                        }
                        holder.updateState(true, preset)
                        Toast.makeText(context, "Voice Changer: $preset (Long-press to change)", Toast.LENGTH_SHORT).show()
                    } else {
                        holder.updateState(false)
                        Toast.makeText(context, "Microphone permission required for Voice Changer", Toast.LENGTH_SHORT).show()
                    }
                } else {
                    HardwareSystemController.stopVoiceProcessing()
                    isVoiceChangerActive = false
                    holder.updateState(false)
                    Toast.makeText(context, "Voice Changer: OFF", Toast.LENGTH_SHORT).show()
                }
            }
            voiceHolderRef = voiceHolder
            addView(voiceHolder.root)
        }
        card.addView(toolsRow)
    }

    private class ToolButtonHolder(
        val root: LinearLayout,
        val iconView: LucideIconView,
        val labelView: TextView,
        val badgeView: TextView,
        var isActive: Boolean,
        val iconType: Int,
        val activeColor: Int,
        val isLightMode: Boolean
    ) {
        fun updateState(active: Boolean, badgeText: String? = null) {
            isActive = active
            val inactiveBgColor = if (isLightMode) Color.parseColor("#F1F5F9") else Color.parseColor("#14FFFFFF")
            val inactiveBorderColor = if (isLightMode) Color.parseColor("#CBD5E1") else Color.parseColor("#1FFFFFFF")
            val inactiveIconColor = if (isLightMode) Color.parseColor("#475569") else Color.parseColor("#99FFFFFF")
            val density = root.resources.displayMetrics.density
            val dp1 = (1f * density).toInt()

            root.background = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = 10f * density
                if (isActive) {
                    val alphaValue = if (isLightMode) 35 else 45
                    val alphaBg = Color.argb(alphaValue, Color.red(activeColor), Color.green(activeColor), Color.blue(activeColor))
                    setColor(alphaBg)
                    setStroke(dp1, activeColor)
                } else {
                    setColor(inactiveBgColor)
                    setStroke(dp1, inactiveBorderColor)
                }
            }
            iconView.setIcon(iconType, if (isActive) activeColor else inactiveIconColor)
            val labelActiveColor = if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE
            labelView.setTextColor(if (isActive) labelActiveColor else inactiveIconColor)
            if (badgeText != null) {
                badgeView.text = badgeText
                badgeView.visibility = View.VISIBLE
                badgeView.setTextColor(if (isActive) activeColor else inactiveIconColor)
            } else {
                badgeView.visibility = View.GONE
            }
        }
    }

    private fun createToggleToolButton(
        iconType: Int,
        labelText: String,
        initialActive: Boolean,
        activeColor: Int,
        initialBadge: String? = null,
        onLongClick: (() -> Unit)? = null,
        onToggle: (Boolean, ToolButtonHolder) -> Unit
    ): Pair<View, ToolButtonHolder> {
        val inactiveIconColor = if (isLightMode) Color.parseColor("#475569") else Color.parseColor("#99FFFFFF")
        val labelActiveColor = if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
            setPadding(dp(4f), dp(5f), dp(4f), dp(5f))
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                marginStart = dp(2f)
                marginEnd = dp(2f)
            }
        }

        val iconView = LucideIconView(
            this,
            iconType,
            if (initialActive) activeColor else inactiveIconColor,
            1.6f
        ).apply {
            layoutParams = LinearLayout.LayoutParams(dp(15f), dp(15f))
        }
        root.addView(iconView)

        val label = TextView(this).apply {
            text = labelText
            textSize = 7.5f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(if (initialActive) labelActiveColor else inactiveIconColor)
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply { topMargin = dp(2.5f) }
        }
        root.addView(label)

        val badge = TextView(this).apply {
            text = initialBadge ?: ""
            textSize = 6.5f
            typeface = Typeface.DEFAULT_BOLD
            setTextColor(if (initialActive) activeColor else inactiveIconColor)
            gravity = Gravity.CENTER
            visibility = if (initialBadge != null) View.VISIBLE else View.GONE
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply { topMargin = dp(1f) }
        }
        root.addView(badge)

        val holder = ToolButtonHolder(
            root = root,
            iconView = iconView,
            labelView = label,
            badgeView = badge,
            isActive = initialActive,
            iconType = iconType,
            activeColor = activeColor,
            isLightMode = isLightMode
        )
        holder.updateState(initialActive, initialBadge)

        root.setOnClickListener {
            onToggle(!holder.isActive, holder)
        }

        if (onLongClick != null) {
            root.setOnLongClickListener {
                onLongClick()
                true
            }
        }

        return Pair(root, holder)
    }

    private fun showVoicePresetDialog(voiceHolder: ToolButtonHolder) {
        val presets = arrayOf(
            "Commander (Deep Heavy Pitch)",
            "Cybernetic (Robotic Ring-Mod)",
            "Tactical Radio (Walkie-Talkie)",
            "Studio (Enhanced Broadcast)"
        )
        val keys = arrayOf("commander", "cybernetic", "radio", "studio")

        try {
            val builder = AlertDialog.Builder(
                ContextThemeWrapper(this, android.R.style.Theme_DeviceDefault_Dialog_Alert)
            )
            builder.setTitle("Voice Changer Preset")
            builder.setItems(presets) { _, which ->
                val chosenKey = keys[which]
                HardwareSystemController.setVoicePreset(chosenKey)
                val displayName = chosenKey.replaceFirstChar {
                    if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
                }
                voiceHolder.updateState(isVoiceChangerActive, if (isVoiceChangerActive) displayName else null)
                Toast.makeText(this, "Voice Preset: $displayName", Toast.LENGTH_SHORT).show()
            }
            val dialog = builder.create()
            dialog.window?.let { w ->
                val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                } else {
                    @Suppress("DEPRECATION")
                    WindowManager.LayoutParams.TYPE_PHONE
                }
                w.setType(type)
            }
            dialog.show()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private val visionThread = HandlerThread("OwlVisionCapture").apply { start() }
    private val visionHandler = Handler(visionThread.looper)

    // Persistent MediaProjection session state across frames (prevents Android 14 token death)
    @Volatile private var activeMediaProjection: MediaProjection? = null
    @Volatile private var activeVirtualDisplay: VirtualDisplay? = null
    @Volatile private var activeImageReader: ImageReader? = null
    @Volatile private var latestCapturedBase64: String? = null
    @Volatile private var latestCapturedRawBytes: ByteArray? = null
    @Volatile private var latestFrameWidth: Int = 640
    @Volatile private var latestFrameHeight: Int = 360
    @Volatile private var pendingBase64CaptureCallback: ((String?) -> Unit)? = null
    @Volatile private var pendingRawCaptureCallback: ((ByteArray?, Int, Int) -> Unit)? = null

    private fun ensureMediaProjectionSession(): Boolean {
        if (activeMediaProjection != null && activeImageReader != null && activeVirtualDisplay != null) {
            return true
        }
        val mpm = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as? MediaProjectionManager ?: return false
        val data = projectionData ?: return false
        val resCode = projectionResultCode
        if (resCode == 0 || !isVisionEnabled) return false

        return try {
            if (Build.VERSION.SDK_INT >= 34) {
                try {
                    val notification = Notification.Builder(this, CHANNEL_ID)
                        .setContentTitle("Owl Game Turbo")
                        .setContentText("Tactical Overlay & Guardian Vision Active")
                        .setSmallIcon(android.R.drawable.ic_menu_compass)
                        .build()
                    val serviceTypes = ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE or
                            ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
                    startForeground(NOTIFICATION_ID, notification, serviceTypes)
                } catch (e: Exception) {
                    android.util.Log.w("GameTurbo", "startForeground mediaProjection warning: ${e.message}")
                }
            }

            val proj = mpm.getMediaProjection(resCode, data.clone() as Intent) ?: return false
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                proj.registerCallback(object : MediaProjection.Callback() {
                    override fun onStop() {
                        super.onStop()
                        releaseMediaProjectionSession()
                    }
                }, visionHandler)
            }
            activeMediaProjection = proj

            val width = 640
            val height = 360
            val metrics = resources.displayMetrics
            val dpi = metrics.densityDpi

            val reader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)
            val display = proj.createVirtualDisplay(
                "OwlVisionVirtualDisplay",
                width,
                height,
                dpi,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                reader.surface,
                null,
                visionHandler
            )

            reader.setOnImageAvailableListener({ r ->
                try {
                    val image = r.acquireLatestImage() ?: return@setOnImageAvailableListener
                    val reqBase64 = pendingBase64CaptureCallback
                    val reqRaw = pendingRawCaptureCallback

                    // Cheap FPS tick only — avoid extra work when nobody requested a capture.
                    if (reqBase64 == null && reqRaw == null) {
                        gameFrameSampler.recordFrame()
                        image.close()
                        return@setOnImageAvailableListener
                    }

                    gameFrameSampler.recordFrame()
                    pendingBase64CaptureCallback = null
                    pendingRawCaptureCallback = null

                    val planes = image.planes
                    val buffer = planes[0].buffer
                    val pixelStride = planes[0].pixelStride
                    val rowStride = planes[0].rowStride
                    val rowPadding = rowStride - pixelStride * width

                    val bmp = Bitmap.createBitmap(
                        width + rowPadding / pixelStride,
                        height,
                        Bitmap.Config.ARGB_8888
                    )
                    bmp.copyPixelsFromBuffer(buffer)
                    image.close()

                    val cleanBitmap = if (rowPadding > 0) {
                        val cropped = Bitmap.createBitmap(bmp, 0, 0, width, height)
                        bmp.recycle()
                        cropped
                    } else {
                        bmp
                    }

                    if (reqBase64 != null) {
                        val baosJpeg = ByteArrayOutputStream()
                        cleanBitmap.compress(Bitmap.CompressFormat.JPEG, 75, baosJpeg)
                        val b64 = Base64.encodeToString(baosJpeg.toByteArray(), Base64.NO_WRAP)
                        latestCapturedBase64 = b64
                        mainHandler.post { reqBase64.invoke(b64) }
                    }

                    if (reqRaw != null) {
                        val baosPng = ByteArrayOutputStream()
                        cleanBitmap.compress(Bitmap.CompressFormat.PNG, 80, baosPng)
                        val rawBytes = baosPng.toByteArray()
                        latestCapturedRawBytes = rawBytes
                        latestFrameWidth = width
                        latestFrameHeight = height
                        mainHandler.post { reqRaw.invoke(rawBytes, width, height) }
                    }

                    cleanBitmap.recycle()
                } catch (e: Exception) {
                    android.util.Log.e("GameTurbo", "Frame listener error: ${e.message}")
                }
            }, visionHandler)

            activeImageReader = reader
            activeVirtualDisplay = display
            true
        } catch (e: Exception) {
            android.util.Log.e("GameTurbo", "ensureMediaProjectionSession error: ${e.message}")
            releaseMediaProjectionSession()
            false
        }
    }

    private fun releaseMediaProjectionSession() {
        try { activeVirtualDisplay?.release() } catch (_: Exception) {}
        try { activeImageReader?.close() } catch (_: Exception) {}
        try { activeMediaProjection?.stop() } catch (_: Exception) {}
        activeVirtualDisplay = null
        activeImageReader = null
        activeMediaProjection = null
        latestCapturedBase64 = null
        latestCapturedRawBytes = null
        pendingBase64CaptureCallback = null
        pendingRawCaptureCallback = null
    }

    fun captureScreenFrame(onCaptured: (String?) -> Unit) {
        if (!isVisionEnabled || !hasMediaProjectionPermission()) {
            onCaptured(null)
            return
        }
        // Balanced: never open/keep a MediaProjection session warm for sampling.
        if (!isPerformanceMode) {
            onCaptured(null)
            return
        }
        visionHandler.post {
            val ready = ensureMediaProjectionSession()
            if (!ready) {
                mainHandler.post { onCaptured(null) }
                return@post
            }
            pendingBase64CaptureCallback = onCaptured
            visionHandler.postDelayed({
                val p = pendingBase64CaptureCallback
                if (p != null) {
                    pendingBase64CaptureCallback = null
                    mainHandler.post { p.invoke(latestCapturedBase64) }
                }
            }, 450L)
        }
    }

    fun captureScreenFrameRaw(onCaptured: (ByteArray?, Int, Int) -> Unit) {
        if (!isVisionEnabled || !hasMediaProjectionPermission()) {
            onCaptured(null, 0, 0)
            return
        }
        if (!isPerformanceMode) {
            onCaptured(null, 0, 0)
            return
        }
        visionHandler.post {
            val ready = ensureMediaProjectionSession()
            if (!ready) {
                mainHandler.post { onCaptured(null, 0, 0) }
                return@post
            }
            pendingRawCaptureCallback = onCaptured
            visionHandler.postDelayed({
                val p = pendingRawCaptureCallback
                if (p != null) {
                    pendingRawCaptureCallback = null
                    mainHandler.post { p.invoke(latestCapturedRawBytes, latestFrameWidth, latestFrameHeight) }
                }
            }, 450L)
        }
    }

    fun queryGeminiTacticalDirectives(
        onSuccess: (TacticalDirective, Boolean) -> Unit,
        onError: () -> Unit
    ) {
        val key = aiApiKey ?: getEffectiveAiApiKey()
        if (key.isNullOrEmpty()) {
            onError()
            return
        }
        aiApiKey = key

        // Dynamically re-check foreground game so advice is 100% accurate to the active game
        detectForegroundGame()?.let { currentGameName = it }

        if (isAnalyzingAi) {
            // Avoid dropping the caller into a silent no-op when a prior
            // inference hung; allow a fresh cycle after a soft timeout.
            android.util.Log.w("GameTurbo", "Guardian inference already in flight; skipping")
            return
        }
        isAnalyzingAi = true

        fun executeInference(base64Frame: String?) {
            aiExecutor.execute {
                val currentProvider = getEffectiveAiProvider().lowercase()
                val currentModel = getEffectiveAiModel()
                val isOpenAiCompat = currentProvider in listOf("groq", "openai", "sambanova", "openrouter", "xkiro", "deepseek")
                val isClaude = currentProvider == "claude"

                val candidateModels = when (currentProvider) {
                    "groq" -> listOf(
                        currentModel.ifEmpty { "openai/gpt-oss-120b" },
                        "openai/gpt-oss-120b",
                        "llama-3.3-70b-versatile",
                        "llama-3.1-8b-instant"
                    ).distinct()
                    "openai" -> listOf(
                        currentModel.ifEmpty { "gpt-4o-mini" },
                        "gpt-4o"
                    ).distinct()
                    "sambanova" -> listOf(
                        currentModel.ifEmpty { "Meta-Llama-3.3-70B-Instruct" },
                        "Meta-Llama-3.1-8B-Instruct"
                    ).distinct()
                    "openrouter", "deepseek" -> listOf(
                        currentModel.ifEmpty { "google/gemma-4-31b-it:free" },
                        "google/gemma-4-31b-it:free",
                        "google/gemma-4-26b-a4b-it:free",
                        "inclusionai/ling-3.0-flash-vl:free",
                        "meta-llama/llama-3.3-70b-instruct:free"
                    ).distinct()
                    "xkiro" -> listOf(
                        currentModel.ifEmpty { "deepseek/deepseek-v4.1-flash" },
                        "llama-3.3-70b-versatile"
                    ).distinct()
                    "claude" -> listOf(
                        currentModel.ifEmpty { "claude-3-5-haiku-20241022" },
                        "claude-3-5-haiku",
                        "claude-3-haiku-20240307"
                    ).distinct()
                    else -> listOf(
                        currentModel.ifEmpty { "gemini-2.5-flash" },
                        "gemini-2.0-flash",
                        "gemini-1.5-flash"
                    ).distinct()
                }

                var resolvedDirective: TacticalDirective? = null
                var usedVisionFrame = false

                for (model in candidateModels) {
                    var conn: java.net.HttpURLConnection? = null
                    try {
                        val urlString = when {
                            isOpenAiCompat -> when (currentProvider) {
                                "groq" -> "https://api.groq.com/openai/v1/chat/completions"
                                "sambanova" -> "https://api.sambanova.ai/v1/chat/completions"
                                "openrouter", "deepseek" -> "https://openrouter.ai/api/v1/chat/completions"
                                "xkiro" -> "https://api.xkiro.com/v1/chat/completions"
                                else -> "https://api.openai.com/v1/chat/completions"
                            }
                            isClaude -> "https://api.anthropic.com/v1/messages"
                            else -> "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$key"
                        }

                        val url = java.net.URL(urlString)
                        conn = (url.openConnection() as java.net.HttpURLConnection).apply {
                            requestMethod = "POST"
                            connectTimeout = 8000
                            readTimeout = 8000
                            doOutput = true
                            setRequestProperty("Content-Type", "application/json")
                            if (isOpenAiCompat) {
                                setRequestProperty("Authorization", "Bearer $key")
                            } else if (isClaude) {
                                setRequestProperty("x-api-key", key)
                                setRequestProperty("anthropic-version", "2023-06-01")
                            }
                        }

                        val mins = matchElapsedSeconds / 60
                        val secs = matchElapsedSeconds % 60
                        val matchTimeStr = "%02d:%02d".format(mins, secs)
                        val roleStr = if (preferredRole == "auto") "player" else preferredRole
                        val depthDirective = when (coachingLevel) {
                            "beginner" -> "Explain tactics simply for a new player."
                            "advanced" -> "Include cooldown windows, wave state, and vision control."
                            else -> "Standard tactical depth."
                        }

                        val isVisionCapableModel = currentProvider == "gemini" || isClaude ||
                            model.contains("vision") || model.contains("4o") || model.contains("vl") ||
                            model.contains("gemma") || model.contains("omni")

                        val prompt = if (base64Frame != null && isVisionCapableModel) {
                            """
                            You are Guardian AI In-Game Tactical Coach.
                            Game: $currentGameName ($gameCategory) | Role: $roleStr | Match Time: $matchTimeStr
                            Mode: ${if (isPerformanceMode) "Turbo" else "Balanced"} | Target: ${currentTargetFps} FPS
                            $depthDirective
                            Inspect the live in-game match screenshot attached:
                            1. Accurately identify the player's champion/hero (e.g. Balmond, Layla, Saber, etc.), active battle spell (Flicker, Retribution, Purify, Sprint, etc.), lane, and match timer.
                            2. Read the minimap to assess enemy positions, missing laners, and upcoming objective timers.
                            3. Provide actionable advice for the next 15-30 seconds tailored to the $roleStr role.
                            Output ONLY valid raw JSON in this exact schema without any markdown, preamble, or thinking tokens:
                            {"action": "<short bold tactical action, max 6 words>", "reason": "<1 sentence rationale specifying hero/spell/objective>", "warning": "<short warning or radar callout, max 8 words>"}
                            """.trimIndent()
                        } else {
                            """
                            You are Guardian AI In-Game Tactical Coach.
                            Game: $currentGameName ($gameCategory) | Role: $roleStr | Match Time: $matchTimeStr
                            Mode: ${if (isPerformanceMode) "Turbo" else "Balanced"} | Target: ${currentTargetFps} FPS
                            $depthDirective
                            Provide actionable advice for the $roleStr for the next 15-30 seconds of this match.
                            Output ONLY valid raw JSON in this exact schema without any markdown, preamble, or thinking tokens:
                            {"action": "<short bold tactical action, max 6 words>", "reason": "<1 sentence rationale>", "warning": "<short warning or radar callout, max 8 words>"}
                            """.trimIndent()
                        }

                        val requestJson = when {
                            isOpenAiCompat -> {
                                org.json.JSONObject().apply {
                                    put("model", model)
                                    val messagesArr = org.json.JSONArray().apply {
                                        val sysMsg = org.json.JSONObject().apply {
                                            put("role", "system")
                                            put("content", "You are Guardian AI In-Game Tactical Coach for '$currentGameName' ($gameCategory). Role: ${if (preferredRole == "auto") "player" else preferredRole}. ${when (coachingLevel) { "beginner" -> "Explain simply for a new player." "advanced" -> "Include cooldowns and wave state." else -> "" }} Output ONLY valid JSON with keys: action, reason, warning. Never output chain-of-thought or reasoning.")
                                        }
                                        put(sysMsg)

                                        val userMsg = org.json.JSONObject().apply {
                                            put("role", "user")
                                            if (base64Frame != null && isVisionCapableModel) {
                                                val partsArr = org.json.JSONArray().apply {
                                                    put(org.json.JSONObject().apply {
                                                        put("type", "text")
                                                        put("text", prompt)
                                                    })
                                                    put(org.json.JSONObject().apply {
                                                        put("type", "image_url")
                                                        put("image_url", org.json.JSONObject().apply {
                                                            put("url", "data:image/jpeg;base64,$base64Frame")
                                                        })
                                                    })
                                                }
                                                put("content", partsArr)
                                            } else {
                                                put("content", prompt)
                                            }
                                        }
                                        put(userMsg)
                                    }
                                    put("messages", messagesArr)
                                    put("temperature", 0.3)
                                    val tokenCap = if (currentProvider in listOf("openrouter", "deepseek")) 2048 else 1024
                                    put("max_tokens", tokenCap)
                                    val isReasoningModel = model.contains("gpt-oss") || model.contains("deepseek-r1") || model.contains("reason")
                                    if (currentProvider == "groq" && isReasoningModel) {
                                        put("reasoning_format", "hidden")
                                    }
                                    if (currentProvider == "openai") {
                                        put("response_format", org.json.JSONObject().apply {
                                            put("type", "json_object")
                                        })
                                    }
                                }
                            }
                            isClaude -> {
                                org.json.JSONObject().apply {
                                    put("model", model)
                                    put("max_tokens", 1024)
                                    val messagesArr = org.json.JSONArray().apply {
                                        val userMsg = org.json.JSONObject().apply {
                                            put("role", "user")
                                            if (base64Frame != null) {
                                                val partsArr = org.json.JSONArray().apply {
                                                    put(org.json.JSONObject().apply {
                                                        put("type", "image")
                                                        put("source", org.json.JSONObject().apply {
                                                            put("type", "base64")
                                                            put("media_type", "image/jpeg")
                                                            put("data", base64Frame)
                                                        })
                                                    })
                                                    put(org.json.JSONObject().apply {
                                                        put("type", "text")
                                                        put("text", prompt)
                                                    })
                                                }
                                                put("content", partsArr)
                                            } else {
                                                put("content", prompt)
                                            }
                                        }
                                        put(userMsg)
                                    }
                                    put("messages", messagesArr)
                                }
                            }
                            else -> {
                                org.json.JSONObject().apply {
                                    val contentsArr = org.json.JSONArray().apply {
                                        val partsArr = org.json.JSONArray()
                                        if (base64Frame != null) {
                                            val imgPart = org.json.JSONObject().apply {
                                                val inlineData = org.json.JSONObject().apply {
                                                    put("mimeType", "image/jpeg")
                                                    put("data", base64Frame)
                                                }
                                                put("inlineData", inlineData)
                                            }
                                            partsArr.put(imgPart)
                                        }
                                        val textPart = org.json.JSONObject().apply {
                                            put("text", prompt)
                                        }
                                        partsArr.put(textPart)
                                        put(org.json.JSONObject().apply { put("parts", partsArr) })
                                    }
                                    put("contents", contentsArr)
                                    put("generationConfig", org.json.JSONObject().apply {
                                        put("temperature", 0.3)
                                        put("maxOutputTokens", 1024)
                                        put("responseMimeType", "application/json")
                                        put("thinkingConfig", org.json.JSONObject().apply {
                                            put("thinkingBudget", 0)
                                        })
                                    })
                                }
                            }
                        }

                        val bytes = requestJson.toString().toByteArray(Charsets.UTF_8)
                        conn.outputStream.use { os ->
                            os.write(bytes)
                            os.flush()
                        }

                        val code = conn.responseCode
                        if (code in 200..299) {
                            val respStr = conn.inputStream.bufferedReader().use { it.readText() }
                            val root = org.json.JSONObject(respStr)
                            val rawText = when {
                                isOpenAiCompat -> {
                                    val choices = root.optJSONArray("choices")
                                    val candidate = choices?.optJSONObject(0)
                                    val msg = candidate?.optJSONObject("message")
                                    msg?.optString("content") ?: ""
                                }
                                isClaude -> {
                                    val contentArr = root.optJSONArray("content")
                                    val candidate = contentArr?.optJSONObject(0)
                                    candidate?.optString("text") ?: ""
                                }
                                else -> {
                                    val candidates = root.optJSONArray("candidates")
                                    val candidate = candidates?.optJSONObject(0)
                                    val content = candidate?.optJSONObject("content")
                                    val parts = content?.optJSONArray("parts")
                                    parts?.optJSONObject(0)?.optString("text") ?: ""
                                }
                            }

                            val jsonStart = rawText.indexOf('{')
                            val jsonEnd = rawText.lastIndexOf('}')
                            val cleanJson = if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
                                rawText.substring(jsonStart, jsonEnd + 1)
                            } else {
                                rawText.trim()
                                    .removePrefix("```json")
                                    .removePrefix("```")
                                    .removeSuffix("```")
                                    .trim()
                            }

                            val directiveJson = org.json.JSONObject(cleanJson)
                            val action = directiveJson.optString("action", "Hold Objective Position")
                            val reason = directiveJson.optString("reason", "Awaiting tactical opening; maintain perimeter.")
                            val warning = directiveJson.optString("warning", "Radar scanning active threats.")

                            resolvedDirective = TacticalDirective(action, reason, warning)
                            val isModelVision = currentProvider == "gemini" || isClaude || model.contains("vision") || model.contains("4o") || model.contains("vl") || model.contains("gemma") || model.contains("omni")
                            usedVisionFrame = base64Frame != null && isModelVision
                            android.util.Log.d("GameTurbo", "$currentProvider ${if (usedVisionFrame) "Vision" else "Text"} Directive ($model) for $currentGameName: ${resolvedDirective.action}")
                            break
                        } else {
                            val err = try { conn.errorStream?.bufferedReader()?.use { it.readText() } } catch (_: Exception) { null }
                            android.util.Log.w("GameTurbo", "$currentProvider Model $model returned HTTP $code: $err. Trying next candidate...")
                        }
                    } catch (e: Exception) {
                        android.util.Log.w("GameTurbo", "$currentProvider Model $model Exception: ${e.message}")
                    } finally {
                        try { conn?.disconnect() } catch (_: Exception) {}
                    }
                }

                mainHandler.post {
                    isAnalyzingAi = false
                    val dir = resolvedDirective
                    if (dir != null) {
                        onSuccess(dir, usedVisionFrame)
                    } else {
                        onError()
                    }
                }
            }
        }

        if (isVisionEnabled && hasMediaProjectionPermission() && isPerformanceMode) {
            captureScreenFrame { frame ->
                executeInference(frame)
            }
        } else {
            executeInference(null)
        }
    }

    fun showGuardianOverlay() {
        if (guardianOverlayView != null) return
        val wm = getSystemService(WINDOW_SERVICE) as? WindowManager ?: return
        windowManager = wm

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val overlayWidth = dp(195f)
        val params = WindowManager.LayoutParams(
            overlayWidth,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = guardianX
            y = guardianY
        }

        detectForegroundGame()?.let { currentGameName = it }
        val directives = HardwareSystemController.getTacticalDirectives(currentGameName)
        if (directives.isEmpty()) return

        var cycleDirectiveFn: (() -> Unit)? = null

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = if (isLightMode) {
                GradientDrawable(
                    GradientDrawable.Orientation.TOP_BOTTOM,
                    intArrayOf(Color.parseColor("#F7FFFFFF"), Color.parseColor("#EEF8FAFC"))
                ).apply {
                    shape = GradientDrawable.RECTANGLE
                    cornerRadius = dp(12f).toFloat()
                    setStroke(dp(1.2f), Color.parseColor("#CBD5E1"))
                }
            } else {
                GradientDrawable(
                    GradientDrawable.Orientation.TOP_BOTTOM,
                    intArrayOf(Color.parseColor("#F5090B12"), Color.parseColor("#FA06070B"))
                ).apply {
                    shape = GradientDrawable.RECTANGLE
                    cornerRadius = dp(12f).toFloat()
                    setStroke(dp(1f), Color.parseColor("#33389BFF"))
                }
            }
            setPadding(dp(9f), dp(5f), dp(9f), dp(5f))
            tag = "guardian_overlay_container"

            val hasKey = !getEffectiveAiApiKey().isNullOrEmpty()

            // Header row with pulse dot, title badge, and close button (refresh button removed for ultra-compact HUD)
            val dotView = View(context).apply {
                background = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(if (hasKey) Color.parseColor("#30D158") else Color.parseColor("#F59E0B"))
                }
                layoutParams = LinearLayout.LayoutParams(dp(5f), dp(5f)).apply {
                    marginEnd = dp(5f)
                }
            }

            val badgeText = TextView(context).apply {
                text = if (hasKey) "GUARDIAN AI • LIVE" else "GUARDIAN AI • HEURISTIC"
                textSize = 7f
                typeface = Typeface.DEFAULT_BOLD
                setTextColor(if (hasKey) (if (isLightMode) Color.parseColor("#0284C7") else Color.parseColor("#389BFF")) else (if (isLightMode) Color.parseColor("#64748B") else Color.parseColor("#94A3B8")))
                letterSpacing = 0.05f
                tag = "guardian_badge"
                layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
            }

            val closeBtn = FrameLayout(context).apply {
                layoutParams = LinearLayout.LayoutParams(dp(16f), dp(16f))
                val icon = LucideIconView(
                    context,
                    LucideIconView.TYPE_CLOSE,
                    if (isLightMode) Color.parseColor("#64748B") else Color.parseColor("#8E9BAE"),
                    1.4f
                ).apply {
                    layoutParams = FrameLayout.LayoutParams(dp(8f), dp(8f), Gravity.CENTER)
                    tag = "guardian_close_icon"
                }
                addView(icon)
                setOnClickListener {
                    hideGuardianOverlay()
                    isAiActive = false
                    updateAiToolButtonState(false)
                    Toast.makeText(context, "Guardian AI: Closed", Toast.LENGTH_SHORT).show()
                }
            }

            val topRow = LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
                addView(dotView)
                addView(badgeText)
                addView(closeBtn)
            }
            addView(topRow)

            val safeIndex = currentDirectiveIndex.coerceIn(0, directives.size - 1)
            val actionText = TextView(context).apply {
                text = directives[safeIndex].action
                textSize = 8.5f
                typeface = Typeface.DEFAULT_BOLD
                setTextColor(if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE)
                maxLines = 1
                tag = "guardian_action"
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply { topMargin = dp(1.5f) }
            }
            addView(actionText)

            val reasonText = TextView(context).apply {
                val d = directives[safeIndex]
                text = d.warning ?: d.reason
                textSize = 7.5f
                setTextColor(if (isLightMode) Color.parseColor("#475569") else Color.parseColor("#94A3B8"))
                maxLines = 2
                tag = "guardian_reason"
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply { topMargin = dp(1f) }
            }
            addView(reasonText)

            fun cycleNextDirective() {
                detectForegroundGame()?.let { currentGameName = it }
                val activeDirectives = HardwareSystemController.getTacticalDirectives(currentGameName)
                val effectiveKey = getEffectiveAiApiKey()
                if (!effectiveKey.isNullOrEmpty()) {
                    aiApiKey = effectiveKey
                    dotView.background = GradientDrawable().apply {
                        shape = GradientDrawable.OVAL
                        setColor(Color.parseColor("#38BDF8"))
                    }
                    queryGeminiTacticalDirectives(
                        onSuccess = { directive, hasVision ->
                            badgeText.text = if (hasVision) "GUARDIAN AI • VISION" else "GUARDIAN AI • LIVE"
                            badgeText.setTextColor(if (hasVision) Color.parseColor("#00E5FF") else (if (isLightMode) Color.parseColor("#0284C7") else Color.parseColor("#389BFF")))
                            dotView.background = GradientDrawable().apply {
                                shape = GradientDrawable.OVAL
                                setColor(if (hasVision) Color.parseColor("#00E5FF") else Color.parseColor("#30D158"))
                            }
                            actionText.text = directive.action
                            actionText.setTextColor(if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE)
                            reasonText.text = directive.warning ?: directive.reason
                        },
                        onError = {
                            // Keep LIVE status because API key is active; cycle tactical cache seamlessly
                            badgeText.text = "GUARDIAN AI • LIVE"
                            badgeText.setTextColor(if (isLightMode) Color.parseColor("#0284C7") else Color.parseColor("#389BFF"))
                            dotView.background = GradientDrawable().apply {
                                shape = GradientDrawable.OVAL
                                setColor(Color.parseColor("#30D158"))
                            }
                            if (activeDirectives.isNotEmpty()) {
                                currentDirectiveIndex = (currentDirectiveIndex + 1) % activeDirectives.size
                                val next = activeDirectives[currentDirectiveIndex]
                                actionText.text = next.action
                                actionText.setTextColor(if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE)
                                reasonText.text = next.warning ?: next.reason
                            }
                        }
                    )
                } else {
                    badgeText.text = "GUARDIAN AI • HEURISTIC"
                    badgeText.setTextColor(if (isLightMode) Color.parseColor("#64748B") else Color.parseColor("#94A3B8"))
                    dotView.background = GradientDrawable().apply {
                        shape = GradientDrawable.OVAL
                        setColor(Color.parseColor("#F59E0B"))
                    }
                    if (activeDirectives.isNotEmpty()) {
                        currentDirectiveIndex = (currentDirectiveIndex + 1) % activeDirectives.size
                        val next = activeDirectives[currentDirectiveIndex]
                        actionText.text = next.action
                        actionText.setTextColor(if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE)
                        reasonText.text = next.warning ?: next.reason
                    }
                }
                startGuardianAutoRefresh(if (isPerformanceMode) 35000L else 120000L) {
                    cycleDirectiveFn?.invoke()
                }
            }

            cycleDirectiveFn = { cycleNextDirective() }

            var initialX = 0
            var initialY = 0
            var initialTouchX = 0f
            var initialTouchY = 0f
            var isDrag = false

            setOnTouchListener { v, event ->
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = params.x
                        initialY = params.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        isDrag = false
                        true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = (event.rawX - initialTouchX).toInt()
                        val dy = (event.rawY - initialTouchY).toInt()
                        if (Math.abs(dx) > dp(5f) || Math.abs(dy) > dp(5f)) {
                            isDrag = true
                        }
                        params.x = initialX + dx
                        params.y = initialY + dy
                        guardianX = params.x
                        guardianY = params.y
                        wm.updateViewLayout(v, params)
                        true
                    }
                    MotionEvent.ACTION_UP -> {
                        if (isDrag) {
                            persistGuardianPosition()
                        } else {
                            cycleNextDirective()
                        }
                        true
                    }
                    else -> false
                }
            }
        }

        try {
            wm.addView(container, params)
            guardianOverlayView = container
            // Kick vision/tactical refresh immediately so the separate Guardian
            // bubble does not stay stuck on LIVE until the first manual tap.
            mainHandler.post {
                if (guardianOverlayView === container) {
                    cycleDirectiveFn?.invoke()
                }
            }
            startGuardianAutoRefresh(if (isPerformanceMode) 35000L else 120000L) {
                cycleDirectiveFn?.invoke()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun hideGuardianOverlay() {
        stopGuardianAutoRefresh()
        val wm = windowManager ?: return
        guardianOverlayView?.let {
            try {
                wm.removeView(it)
            } catch (e: Exception) {}
            guardianOverlayView = null
        }
    }

    fun updateAiToolButtonState(active: Boolean) {
        mainHandler.post {
            aiHolderRef?.updateState(active)
        }
    }

    fun refreshGuardianOverlayTheme() {
        val root = guardianOverlayView as? LinearLayout ?: return
        root.background = if (isLightMode) {
            GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                intArrayOf(Color.parseColor("#F7FFFFFF"), Color.parseColor("#EEF8FAFC"))
            ).apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dp(12f).toFloat()
                setStroke(dp(1.2f), Color.parseColor("#CBD5E1"))
            }
        } else {
            GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                intArrayOf(Color.parseColor("#F5090B12"), Color.parseColor("#FA06070B"))
            ).apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dp(12f).toFloat()
                setStroke(dp(1f), Color.parseColor("#33389BFF"))
            }
        }
        (root.findViewWithTag<TextView>("guardian_badge"))?.setTextColor(
            if (isLightMode) Color.parseColor("#0284C7") else Color.parseColor("#389BFF")
        )
        (root.findViewWithTag<TextView>("guardian_action"))?.setTextColor(
            if (isLightMode) Color.parseColor("#0F172A") else Color.WHITE
        )
        (root.findViewWithTag<TextView>("guardian_reason"))?.setTextColor(
            if (isLightMode) Color.parseColor("#475569") else Color.parseColor("#94A3B8")
        )
        (root.findViewWithTag<LucideIconView>("guardian_close_icon"))?.let {
            it.setIcon(LucideIconView.TYPE_CLOSE, if (isLightMode) Color.parseColor("#64748B") else Color.parseColor("#8E9BAE"))
        }
    }

    private var overlayPrevIdle: Long = 0L
    private var overlayPrevTotal: Long = 0L

    private fun readAutonomousCpu(): Int {
        try {
            val line = java.io.BufferedReader(java.io.FileReader("/proc/stat")).use { it.readLine() }
            if (line != null && line.startsWith("cpu ")) {
                val parts = line.trim().split("\\s+".toRegex()).drop(1).map { it.toLongOrNull() ?: 0L }
                val idle = if (parts.size > 3) parts[3] else 0L
                val total = parts.sum()
                val diffIdle = idle - overlayPrevIdle
                val diffTotal = total - overlayPrevTotal
                overlayPrevIdle = idle
                overlayPrevTotal = total
                if (diffTotal > 0) {
                    return ((diffTotal - diffIdle) * 100 / diffTotal).toInt().coerceIn(0, 100)
                }
            }
        } catch (_: Exception) {}
        return liveCpu
    }

    private fun getBatteryLevel(): Int {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val bm = getSystemService(BATTERY_SERVICE) as? BatteryManager
                val capacity = bm?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) ?: -1
                if (capacity in 0..100) return capacity
            }
            val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val lvl = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
            if (lvl >= 0 && scale > 0) (lvl * 100 / scale).coerceIn(0, 100) else 0
        } catch (e: Exception) {
            0
        }
    }

    fun getBatteryLevelPublic(): Int = getBatteryLevel()

    private var autonomousTicker: Runnable? = null

    private fun startAutonomousTicker() {
        if (autonomousTicker != null) return
        val r = object : Runnable {
            override fun run() {
                // Sample off the main thread so /proc + battery never hitch the game.
                statsHandler.post {
                    val effectiveFps = getEffectiveLiveFps().let {
                        when {
                            it <= 0 -> 0
                            !isPerformanceMode -> it.coerceAtMost(60)
                            else -> it
                        }
                    }
                    val batt = getBatteryLevel()
                    val cpu = readAutonomousCpu()
                    val target = if (isPerformanceMode) currentTargetFps else 60
                    val ratio = if (effectiveFps > 0) {
                        (effectiveFps.toFloat() / target.toFloat()).coerceIn(0f, 1f)
                    } else {
                        0.5f
                    }
                    val gpu = ((ratio * 60f) + (cpu * 0.35f)).toInt().coerceIn(5, 95)
                    pushStats(cpu, gpu, batt, effectiveFps)
                }
                // Slower while collapsed (rail only); faster when HUD is open.
                val interval = if (expandedToolboxView != null) 1000L else 2000L
                mainHandler.postDelayed(this, interval)
            }
        }
        autonomousTicker = r
        mainHandler.postDelayed(r, 1500L)
    }

    private fun stopAutonomousTicker() {
        autonomousTicker?.let { mainHandler.removeCallbacks(it) }
        autonomousTicker = null
    }

    private fun readHardwareOverlayFps(): Int {
        val paths = listOf(
            "/sys/class/drm/card0/device/fps",
            "/sys/class/graphics/fb0/measured_fps",
            "/sys/devices/platform/soc/soc:qcom,dsi-display-primary/measured_fps",
            "/sys/devices/virtual/graphics/fb0/fps",
            "/sys/class/drm/card0-DSI-1/measured_fps"
        )
        for (p in paths) {
            try {
                val v = java.io.File(p).readText().trim().split(".").first().toIntOrNull()
                if (v != null && v in 24..240) return v
            } catch (_: Exception) {}
        }
        val wm = windowManager ?: getSystemService(WINDOW_SERVICE) as? WindowManager
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                display?.refreshRate?.toInt() ?: currentTargetFps
            } else {
                @Suppress("DEPRECATION")
                wm?.defaultDisplay?.refreshRate?.toInt() ?: currentTargetFps
            }
        } catch (_: Exception) { currentTargetFps }
    }

    override fun onDestroy() {
        stopAutonomousTicker()
        stopOverlayChoreographer()
        stopGuardianAutoRefresh()
        try {
            statsHandler.removeCallbacksAndMessages(null)
            statsThread.quitSafely()
        } catch (_: Exception) {
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            try { stopForeground(STOP_FOREGROUND_REMOVE) } catch (_: Exception) {}
        } else {
            @Suppress("DEPRECATION")
            try { stopForeground(true) } catch (_: Exception) {}
        }
        instance = null   // clear singleton
        pingListener?.let {
            HardwareSystemController.removePingListener(it)
            pingListener = null
        }
        val wm = windowManager
        collapsedHandleView?.let {
            try {
                wm?.removeView(it)
            } catch (e: Exception) {}
            collapsedHandleView = null
        }
        expandedToolboxView?.let {
            try {
                overlayFlutterView?.detachFromFlutterEngine()
            } catch (_: Exception) {
            }
            overlayFlutterView = null
            try {
                wm?.removeView(it)
            } catch (_: Exception) {
            }
            expandedToolboxView = null
        }
        hideGuardianOverlay()
        releaseMediaProjectionSession()
        OverlayFlutterEngineHost.destroy()
        super.onDestroy()
    }

    companion object {
        // Singleton reference so MainActivity can push live stats
        @Volatile private var instance: GameTurboOverlayService? = null
        @Volatile var cachedAiApiKey: String? = null
        @Volatile var cachedAiProvider: String? = null
        @Volatile var cachedAiModel: String? = null

        @Volatile var projectionResultCode: Int = 0
        @Volatile var projectionData: Intent? = null
        @Volatile var isVisionEnabled: Boolean = true

        fun setMediaProjectionData(resultCode: Int, data: Intent) {
            projectionResultCode = resultCode
            projectionData = data
        }

        fun hasMediaProjectionPermission(): Boolean {
            return projectionResultCode != 0 && projectionData != null
        }

        fun getOverlayEffectiveLiveFps(): Int? {
            return instance?.getEffectiveLiveFps()
        }

        /** Snapshot for the overlay Flutter EventChannel (battery/cpu/gpu/fps). */
        fun liveSnapshotOrNull(): Map<String, Any?>? {
            val svc = instance ?: return null
            val raw = svc.getEffectiveLiveFps()
            val fps = when {
                raw <= 0 -> 0
                !svc.isPerformanceMode -> raw.coerceAtMost(60)
                else -> raw
            }
            return mapOf(
                "battery" to (if (svc.liveBattery > 0) svc.liveBattery else svc.getBatteryLevelPublic()),
                "cpu" to svc.liveCpu,
                "gpu" to svc.liveGpu,
                "fps" to fps,
            )
        }

        fun instanceCpuOrZero(): Int = instance?.liveCpu ?: 0

        fun applyGameContext(
            gameCategory: String,
            preferredRole: String,
            coachingLevel: String,
            matchElapsedSeconds: Int,
        ) {
            val svc = instance ?: return
            Handler(Looper.getMainLooper()).post {
                svc.setGameContext(gameCategory, preferredRole, coachingLevel, matchElapsedSeconds)
            }
        }

        fun start(
            context: Context,
            gameName: String? = null,
            targetFps: Int = 120,
            isLight: Boolean? = null,
            aiApiKey: String? = null,
            aiProvider: String? = null,
            aiModel: String? = null
        ) {
            val prefs = try {
                context.getSharedPreferences("owl_overlay_prefs", Context.MODE_PRIVATE)
            } catch (_: Exception) { null }

            val key = aiApiKey ?: cachedAiApiKey ?: prefs?.getString("ai_api_key", null)
            if (!key.isNullOrEmpty()) {
                cachedAiApiKey = key
            }
            val prov = aiProvider ?: cachedAiProvider ?: prefs?.getString("ai_provider", null) ?: "gemini"
            cachedAiProvider = prov

            val mod = aiModel ?: cachedAiModel ?: prefs?.getString("ai_model", null) ?: "gemini-2.5-flash"
            cachedAiModel = mod

            val intent = Intent(context, GameTurboOverlayService::class.java).apply {
                if (!gameName.isNullOrEmpty()) {
                    putExtra("EXTRA_GAME_NAME", gameName)
                }
                putExtra("EXTRA_TARGET_FPS", targetFps)
                if (isLight != null) {
                    putExtra("EXTRA_IS_LIGHT_MODE", isLight)
                }
                if (!key.isNullOrEmpty()) {
                    putExtra("EXTRA_AI_API_KEY", key)
                }
                putExtra("EXTRA_AI_PROVIDER", prov)
                putExtra("EXTRA_AI_MODEL", mod)
                putExtra("EXTRA_SHOW_GUARDIAN", true)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun setAiCredentials(context: Context? = null, apiKey: String?, provider: String = "gemini", model: String = "gemini-2.5-flash") {
            cachedAiApiKey = apiKey
            cachedAiProvider = provider
            cachedAiModel = model
            if (context != null) {
                try {
                    val editor = context.getSharedPreferences("owl_overlay_prefs", Context.MODE_PRIVATE).edit()
                    if (!apiKey.isNullOrEmpty()) {
                        editor.putString("ai_api_key", apiKey)
                    } else {
                        editor.remove("ai_api_key")
                    }
                    editor.putString("ai_provider", provider)
                    editor.putString("ai_model", model)
                    editor.apply()
                } catch (_: Exception) {}
            }
            val svc = instance ?: return
            Handler(Looper.getMainLooper()).post {
                svc.aiApiKey = apiKey
                svc.aiProvider = provider
                svc.aiModel = model
            }
        }

        /** Pushes live match context from Flutter into the running overlay service instance. */
        fun setGameContext(context: Context? = null, gameCategory: String, preferredRole: String, coachingLevel: String, matchElapsedSeconds: Int) {
            if (context != null) {
                try {
                    context.getSharedPreferences("owl_overlay_prefs", Context.MODE_PRIVATE).edit().apply {
                        putString("game_category", gameCategory)
                        putString("preferred_role", preferredRole)
                        putString("coaching_level", coachingLevel)
                        putInt("match_elapsed_seconds", matchElapsedSeconds)
                        apply()
                    }
                } catch (_: Exception) {}
            }
            val svc = instance ?: return
            Handler(Looper.getMainLooper()).post {
                svc.setGameContext(gameCategory, preferredRole, coachingLevel, matchElapsedSeconds)
            }
        }

        fun stop(context: Context) {
            val intent = Intent(context, GameTurboOverlayService::class.java)
            context.stopService(intent)
        }

        fun showGuardianOverlay() {
            val svc = instance ?: return
            Handler(Looper.getMainLooper()).post {
                svc.isAiActive = true
                svc.updateAiToolButtonState(true)
                svc.showGuardianOverlay()
            }
        }

        fun hideGuardianOverlay() {
            val svc = instance ?: return
            Handler(Looper.getMainLooper()).post {
                svc.isAiActive = false
                svc.updateAiToolButtonState(false)
                svc.hideGuardianOverlay()
            }
        }

        fun setThemeMode(isLight: Boolean) {
            val svc = instance ?: return
            Handler(Looper.getMainLooper()).post {
                if (svc.isLightMode == isLight) return@post
                svc.isLightMode = isLight
                if (svc.collapsedHandleView != null) {
                    svc.refreshCollapsedHandleTheme()
                }
                if (svc.expandedToolboxView != null) {
                    svc.refreshExpandedToolboxTheme()
                }
                if (svc.guardianOverlayView != null) {
                    svc.refreshGuardianOverlayTheme()
                }
            }
        }

        fun setPerformanceMode(isPerf: Boolean, targetFps: Int) {
            val svc = instance ?: return
            Handler(Looper.getMainLooper()).post {
                svc.isPerformanceMode = isPerf
                if (isPerf) {
                    val ceiling = targetFps.coerceAtLeast(1)
                    svc.performanceCeilingFps = ceiling
                    svc.currentTargetFps = ceiling
                } else {
                    svc.currentTargetFps = 60
                    // Balanced Owl budget: drop warm MediaProjection; stop guardian auto-refresh.
                    svc.releaseMediaProjectionSession()
                    svc.stopGuardianAutoRefresh()
                }
                svc.onModeUiUpdate?.invoke()
                svc.updateWindowPreferredRefreshRate(
                    if (isPerf) svc.currentTargetFps.toFloat() else 60f,
                )
                val currentFps = svc.getEffectiveLiveFps().let {
                    if (!isPerf) it.coerceAtMost(60) else it
                }
                pushStats(svc.liveCpu, svc.liveGpu, svc.liveBattery, currentFps)
            }
        }

        fun updateTacticalAdvice(badge: String, action: String, warning: String?) {
            val svc = instance ?: return
            Handler(Looper.getMainLooper()).post {
                val root = svc.guardianOverlayView as? android.view.ViewGroup ?: return@post
                fun findByTag(vg: android.view.ViewGroup, tag: String): View? {
                    for (i in 0 until vg.childCount) {
                        val c = vg.getChildAt(i)
                        if (c.tag == tag) return c
                        if (c is android.view.ViewGroup) {
                            val f = findByTag(c, tag)
                            if (f != null) return f
                        }
                    }
                    return null
                }
                (findByTag(root, "guardian_badge") as? TextView)?.apply {
                    val incoming = badge.uppercase()
                    val current = text?.toString()?.uppercase().orEmpty()
                    // Never let a Flutter text/offline push downgrade an active VISION badge.
                    val keepVision = current.contains("VISION") &&
                        !incoming.contains("VISION") &&
                        (incoming.contains("LIVE") || incoming == "GUARDIAN AI")
                    if (!keepVision) {
                        text = badge
                    }
                }
                (findByTag(root, "guardian_action") as? TextView)?.apply {
                    text = action
                }
                (findByTag(root, "guardian_reason") as? TextView)?.apply {
                    text = warning ?: ""
                }
            }
        }

        fun captureFrameBytes(context: Context, callback: (ByteArray?, Int, Int) -> Unit) {
            val svc = instance
            if (svc != null && hasMediaProjectionPermission()) {
                svc.captureScreenFrameRaw { bytes, w, h ->
                    callback(bytes, w, h)
                }
            } else {
                callback(null, 0, 0)
            }
        }

        /** Called by MainActivity's stats loop or autonomous ticker with live real-time values. */
        fun pushStats(cpu: Int, gpu: Int, battery: Int, fps: Int) {
            val svc = instance ?: return
            svc.liveCpu = cpu
            svc.liveGpu = gpu
            svc.liveBattery = battery
            svc.liveFps = fps

            val displayFps = if (fps > 0) {
                if (!svc.isPerformanceMode) fps.coerceAtMost(60) else fps
            } else {
                0
            }

            val hudOpen = svc.expandedToolboxView != null
            val guardianOpen = svc.guardianOverlayView != null

            // Collapsed rail-only: store volatiles and return — no main-thread UI work.
            if (!hudOpen && !guardianOpen) return

            Handler(Looper.getMainLooper()).post {
                try {
                    if (hudOpen) {
                        val now = SystemClock.elapsedRealtime()
                        if (now - svc.lastFlutterStatsEmitAtMs >= svc.flutterStatsMinIntervalMs) {
                            svc.lastFlutterStatsEmitAtMs = now
                            OverlayFlutterEngineHost.emitStats(cpu, gpu, battery, displayFps)
                        }
                    }

                    // Legacy Kotlin toolbox tags (only if native toolbox still present)
                    val toolboxRoot = svc.expandedToolboxView as? android.view.ViewGroup ?: return@post
                    // FlutterTextureView root has no tagged telemetry children — skip walk.
                    if (toolboxRoot.childCount == 1 && toolboxRoot.getChildAt(0) is io.flutter.embedding.android.FlutterView) {
                        return@post
                    }
                    fun findByTag(root: android.view.ViewGroup, tag: String): View? {
                        for (i in 0 until root.childCount) {
                            val child = root.getChildAt(i)
                            if (child.tag == tag) return child
                            if (child is android.view.ViewGroup) {
                                val found = findByTag(child, tag)
                                if (found != null) return found
                            }
                        }
                        return null
                    }

                    (findByTag(toolboxRoot, "cpu_val") as? TextView)?.apply {
                        text = "${cpu}%"
                        setTextColor(if (svc.isLightMode) Color.parseColor("#0F172A") else Color.WHITE)
                    }
                    (findByTag(toolboxRoot, "gpu_val") as? TextView)?.apply {
                        text = "${gpu}%"
                        setTextColor(if (svc.isLightMode) Color.parseColor("#0F172A") else Color.WHITE)
                    }
                    (findByTag(toolboxRoot, "cpu_bar") as? TelemetryProgressBarView)?.let { bar ->
                        bar.isLightMode = svc.isLightMode
                        bar.updateProgress(
                            cpu / 100f,
                            if (svc.isPerformanceMode) Color.parseColor("#FF3B30") else (if (svc.isLightMode) Color.parseColor("#0284C7") else Color.parseColor("#007AFF")),
                            if (svc.isPerformanceMode) Color.parseColor("#FF6961") else (if (svc.isLightMode) Color.parseColor("#38BDF8") else Color.parseColor("#60A5FA"))
                        )
                    }
                    (findByTag(toolboxRoot, "gpu_bar") as? TelemetryProgressBarView)?.let { bar ->
                        bar.isLightMode = svc.isLightMode
                        bar.updateProgress(
                            gpu / 100f,
                            if (svc.isLightMode) Color.parseColor("#7C3AED") else Color.parseColor("#8B5CF6"),
                            if (svc.isLightMode) Color.parseColor("#A78BFA") else Color.parseColor("#C084FC")
                        )
                    }
                    val triple = toolboxRoot.let { vg ->
                        for (i in 0 until vg.childCount) {
                            val c = vg.getChildAt(i)
                            if (c is android.view.ViewGroup) {
                                val t = c.tag
                                if (t is Triple<*, *, *>) return@let t
                            }
                        }
                        null
                    }
                    (triple?.first as? ReactorGaugeView)?.let { gauge ->
                        gauge.isLightMode = svc.isLightMode
                        gauge.setMode(
                            svc.isPerformanceMode,
                            displayFps,
                            if (svc.isPerformanceMode) svc.currentTargetFps else 60,
                        )
                    }
                } catch (_: Exception) {
                }
            }
        }
    }
}

/**
 * Custom View that renders crisp, vector-based Lucide icons via anti-aliased Canvas strokes.
 * Replaces cartoon system emojis with high-tech tactical glyphs.
 */
class LucideIconView @JvmOverloads constructor(
    context: Context,
    var iconType: Int = TYPE_ZAP,
    var iconColor: Int = Color.WHITE,
    var strokeWidthDp: Float = 1.6f
) : View(context) {

    companion object {
        const val TYPE_ZAP = 1
        const val TYPE_CLOSE = 2
        const val TYPE_BATTERY_CHARGING = 3
        const val TYPE_BELL_OFF = 4
        const val TYPE_WIFI = 5
        const val TYPE_BOT = 6
        const val TYPE_MIC = 7
        const val TYPE_REFRESH = 8
        const val TYPE_SLIDERS = 9
    }

    private val strokePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
        strokeCap = Paint.Cap.ROUND
        strokeJoin = Paint.Join.ROUND
    }

    private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
    }

    private val path = Path()

    fun setIcon(type: Int, color: Int) {
        iconType = type
        iconColor = color
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val w = width.toFloat()
        val h = height.toFloat()
        if (w <= 0 || h <= 0) return

        val density = resources.displayMetrics.density
        strokePaint.color = iconColor
        strokePaint.strokeWidth = strokeWidthDp * density
        fillPaint.color = iconColor

        when (iconType) {
            TYPE_ZAP -> {
                path.reset()
                path.moveTo(w * 0.55f, h * 0.10f)
                path.lineTo(w * 0.22f, h * 0.54f)
                path.lineTo(w * 0.48f, h * 0.54f)
                path.lineTo(w * 0.44f, h * 0.90f)
                path.lineTo(w * 0.78f, h * 0.46f)
                path.lineTo(w * 0.52f, h * 0.46f)
                path.close()
                canvas.drawPath(path, strokePaint)
            }
            TYPE_CLOSE -> {
                canvas.drawLine(w * 0.25f, h * 0.25f, w * 0.75f, h * 0.75f, strokePaint)
                canvas.drawLine(w * 0.75f, h * 0.25f, w * 0.25f, h * 0.75f, strokePaint)
            }
            TYPE_BATTERY_CHARGING -> {
                // Battery body
                val bodyRect = RectF(w * 0.08f, h * 0.24f, w * 0.78f, h * 0.76f)
                canvas.drawRoundRect(bodyRect, w * 0.08f, w * 0.08f, strokePaint)
                // Terminal cap
                val termRect = RectF(w * 0.78f, h * 0.40f, w * 0.90f, h * 0.60f)
                canvas.drawRoundRect(termRect, w * 0.04f, w * 0.04f, strokePaint)
                // Inner lightning bolt
                path.reset()
                path.moveTo(w * 0.48f, h * 0.32f)
                path.lineTo(w * 0.32f, h * 0.52f)
                path.lineTo(w * 0.44f, h * 0.52f)
                path.lineTo(w * 0.38f, h * 0.68f)
                path.lineTo(w * 0.56f, h * 0.48f)
                path.lineTo(w * 0.44f, h * 0.48f)
                path.close()
                canvas.drawPath(path, fillPaint)
            }
            TYPE_BELL_OFF -> {
                // Diagonal slash
                canvas.drawLine(w * 0.15f, h * 0.15f, w * 0.85f, h * 0.85f, strokePaint)
                // Bell outline (partial for bell-off)
                path.reset()
                path.moveTo(w * 0.40f, h * 0.28f)
                path.cubicTo(w * 0.44f, h * 0.18f, w * 0.56f, h * 0.18f, w * 0.60f, h * 0.28f)
                path.cubicTo(w * 0.64f, h * 0.38f, w * 0.72f, h * 0.55f, w * 0.76f, h * 0.68f)
                path.lineTo(w * 0.68f, h * 0.68f)
                canvas.drawPath(path, strokePaint)

                path.reset()
                path.moveTo(w * 0.52f, h * 0.68f)
                path.lineTo(w * 0.24f, h * 0.68f)
                path.cubicTo(w * 0.28f, h * 0.55f, w * 0.34f, h * 0.42f, w * 0.35f, h * 0.35f)
                canvas.drawPath(path, strokePaint)

                // Clapper arc at bottom
                val clapperRect = RectF(w * 0.42f, h * 0.68f, w * 0.58f, h * 0.82f)
                canvas.drawArc(clapperRect, 0f, 180f, false, strokePaint)
            }
            TYPE_WIFI -> {
                // Bottom dot
                canvas.drawCircle(w * 0.5f, h * 0.78f, w * 0.065f, fillPaint)
                // Inner arc
                val r1 = RectF(w * 0.34f, h * 0.50f, w * 0.66f, h * 0.82f)
                canvas.drawArc(r1, 215f, 110f, false, strokePaint)
                // Mid arc
                val r2 = RectF(w * 0.20f, h * 0.32f, w * 0.80f, h * 0.92f)
                canvas.drawArc(r2, 215f, 110f, false, strokePaint)
                // Outer arc
                val r3 = RectF(w * 0.08f, h * 0.16f, w * 0.92f, h * 1.00f)
                canvas.drawArc(r3, 215f, 110f, false, strokePaint)
            }
            TYPE_BOT -> {
                // Top antenna
                canvas.drawLine(w * 0.5f, h * 0.12f, w * 0.5f, h * 0.26f, strokePaint)
                canvas.drawCircle(w * 0.5f, h * 0.12f, w * 0.045f, fillPaint)
                // Head outline
                val headRect = RectF(w * 0.20f, h * 0.26f, w * 0.80f, h * 0.82f)
                canvas.drawRoundRect(headRect, w * 0.12f, w * 0.12f, strokePaint)
                // Eyes
                canvas.drawCircle(w * 0.38f, h * 0.48f, w * 0.055f, fillPaint)
                canvas.drawCircle(w * 0.62f, h * 0.48f, w * 0.055f, fillPaint)
                // Mouth
                canvas.drawLine(w * 0.38f, h * 0.66f, w * 0.62f, h * 0.66f, strokePaint)
                // Side ears
                canvas.drawLine(w * 0.12f, h * 0.48f, w * 0.20f, h * 0.48f, strokePaint)
                canvas.drawLine(w * 0.80f, h * 0.48f, w * 0.88f, h * 0.48f, strokePaint)
            }
            TYPE_MIC -> {
                // Capsule body
                val capRect = RectF(w * 0.34f, h * 0.16f, w * 0.66f, h * 0.58f)
                canvas.drawRoundRect(capRect, w * 0.16f, w * 0.16f, strokePaint)
                // Cradle arc
                val cradleRect = RectF(w * 0.22f, h * 0.28f, w * 0.78f, h * 0.70f)
                canvas.drawArc(cradleRect, 0f, 180f, false, strokePaint)
                // Stem
                canvas.drawLine(w * 0.5f, h * 0.70f, w * 0.5f, h * 0.86f, strokePaint)
                // Base
                canvas.drawLine(w * 0.32f, h * 0.86f, w * 0.68f, h * 0.86f, strokePaint)
            }
            TYPE_REFRESH -> {
                val r = RectF(w * 0.18f, h * 0.18f, w * 0.82f, h * 0.82f)
                canvas.drawArc(r, 45f, 270f, false, strokePaint)
                path.reset()
                path.moveTo(w * 0.68f, h * 0.20f)
                path.lineTo(w * 0.86f, h * 0.38f)
                path.lineTo(w * 0.62f, h * 0.44f)
                path.close()
                canvas.drawPath(path, fillPaint)
            }
            TYPE_SLIDERS -> {
                // Horizontal sliders/tune glyph matching Icons.tune
                canvas.drawLine(w * 0.15f, h * 0.32f, w * 0.85f, h * 0.32f, strokePaint)
                canvas.drawCircle(w * 0.38f, h * 0.32f, w * 0.10f, fillPaint)

                canvas.drawLine(w * 0.15f, h * 0.68f, w * 0.85f, h * 0.68f, strokePaint)
                canvas.drawCircle(w * 0.62f, h * 0.68f, w * 0.10f, fillPaint)
            }
        }
    }
}

/**
 * Custom View rendering the authentic HyperOS Reactor Tachometer FPS Gauge:
 * - Horizontal glowing laser beam flare with gradient falloff
 * - Dotted 36 radial tick marks around the tachometer ring
 * - High-contrast central numerical FPS readout & accent unit tag
 */
class ReactorGaugeView(context: Context) : View(context) {
    var isPerformanceMode: Boolean = true
    var fpsValue: Int = 120
    var dialMaxFps: Float = 120f
    var isLightMode: Boolean = false
        set(value) {
            field = value
            bgPaint.color = if (value) Color.parseColor("#FFFFFF") else Color.parseColor("#F2070A10")
            fpsTextPaint.color = if (value) Color.parseColor("#0F172A") else Color.WHITE
            invalidate()
        }

    private val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#F2070A10")
        style = Paint.Style.FILL
    }

    private val ringPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.STROKE
    }

    private val tickPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#4DFFFFFF")
        style = Paint.Style.STROKE
    }

    private val laserPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
    }

    private val fpsTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.WHITE
        typeface = Typeface.DEFAULT_BOLD
        textAlign = Paint.Align.CENTER
    }

    private val unitTextPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        typeface = Typeface.DEFAULT_BOLD
        textAlign = Paint.Align.CENTER
    }

    fun setMode(isPerf: Boolean, fps: Int, maxFps: Int = if (isPerf) 120 else 60) {
        isPerformanceMode = isPerf
        fpsValue = fps
        dialMaxFps = maxFps.toFloat().coerceAtLeast(1f)
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val w = width.toFloat()
        val h = height.toFloat()
        if (w <= 0 || h <= 0) return

        val density = resources.displayMetrics.density
        val cx = w / 2f
        val cy = h / 2f
        val radius = 33f * density

        val accentColor = if (isPerformanceMode) {
            Color.parseColor("#FF3B30")
        } else {
            if (isLightMode) Color.parseColor("#0284C7") else Color.parseColor("#007AFF")
        }
        val accentCore = if (isPerformanceMode) {
            Color.parseColor("#FF5A5F")
        } else {
            if (isLightMode) Color.parseColor("#38BDF8") else Color.parseColor("#64B5F6")
        }
        val flareAlpha = if (isLightMode) 55 else 120
        val accentGlow = Color.argb(flareAlpha, Color.red(accentColor), Color.green(accentColor), Color.blue(accentColor))

        // 1. Horizontal Laser Beam Flare
        val beamH = 1.6f * density
        laserPaint.shader = LinearGradient(
            0f, cy, w, cy,
            intArrayOf(Color.TRANSPARENT, accentGlow, accentCore, accentGlow, Color.TRANSPARENT),
            floatArrayOf(0f, 0.2f, 0.5f, 0.8f, 1f),
            Shader.TileMode.CLAMP
        )
        canvas.drawRect(6f * density, cy - (beamH / 2f), w - (6f * density), cy + (beamH / 2f), laserPaint)

        // 2. Tachometer Disc Background
        canvas.drawCircle(cx, cy, radius, bgPaint)

        // 3. Outer Ring Border
        ringPaint.color = if (isLightMode) {
            Color.parseColor("#CBD5E1")
        } else {
            Color.argb(160, Color.red(accentColor), Color.green(accentColor), Color.blue(accentColor))
        }
        ringPaint.strokeWidth = 1.2f * density
        canvas.drawCircle(cx, cy, radius - (0.6f * density), ringPaint)

        // 4. 270-degree Tachometer Sweep Arc (from 135 deg to 405 deg)
        val arcRadius = radius - (3.5f * density)
        val arcRect = RectF(cx - arcRadius, cy - arcRadius, cx + arcRadius, cy + arcRadius)
        val startAngle = 135f
        val totalSweep = 270f
        val maxFps = dialMaxFps
        val progress = (fpsValue.toFloat() / maxFps).coerceIn(0.05f, 1.0f)
        val activeSweep = totalSweep * progress

        // Track Arc (Inactive)
        val trackPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = 2.2f * density
            strokeCap = Paint.Cap.ROUND
            color = if (isLightMode) Color.parseColor("#E2E8F0") else Color.parseColor("#26FFFFFF")
        }
        canvas.drawArc(arcRect, startAngle, totalSweep, false, trackPaint)

        // Active Neon Progress Sweep Arc
        val activePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = 2.8f * density
            strokeCap = Paint.Cap.ROUND
            color = accentColor
        }
        canvas.drawArc(arcRect, startAngle, activeSweep, false, activePaint)

        // Leading Pip / Needle Tip at Active Arc Edge
        val tipAngleRad = Math.toRadians((startAngle + activeSweep).toDouble())
        val tipX = cx + (arcRadius * Math.cos(tipAngleRad)).toFloat()
        val tipY = cy + (arcRadius * Math.sin(tipAngleRad)).toFloat()

        val pipGlowPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            color = accentGlow
        }
        canvas.drawCircle(tipX, tipY, 3.5f * density, pipGlowPaint)

        val pipCorePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.FILL
            color = Color.WHITE
        }
        canvas.drawCircle(tipX, tipY, 1.8f * density, pipCorePaint)

        // 5. Radial Tick Marks (25 ticks spanning 270 deg)
        tickPaint.strokeWidth = 1.0f * density
        val tickCount = 25
        val rOuter = arcRadius - (1.5f * density)
        val inactiveTickColor = if (isLightMode) Color.parseColor("#CBD5E1") else Color.parseColor("#4DFFFFFF")
        for (i in 0 until tickCount) {
            val fraction = i.toFloat() / (tickCount - 1).toFloat()
            val angleDeg = startAngle + fraction * totalSweep
            val angleRad = Math.toRadians(angleDeg.toDouble())
            val isActive = fraction <= progress

            val tickLength = if (isActive) 4.2f * density else 2.5f * density
            val rInner = rOuter - tickLength
            tickPaint.color = if (isActive) accentColor else inactiveTickColor
            tickPaint.strokeWidth = if (isActive) 1.3f * density else 0.9f * density

            val x1 = cx + rOuter * Math.cos(angleRad).toFloat()
            val y1 = cy + rOuter * Math.sin(angleRad).toFloat()
            val x2 = cx + rInner * Math.cos(angleRad).toFloat()
            val y2 = cy + rInner * Math.sin(angleRad).toFloat()
            canvas.drawLine(x1, y1, x2, y2, tickPaint)
        }

        // 6. High-Contrast FPS Numerical Readout
        fpsTextPaint.textSize = 18f * density
        val fpsStr = fpsValue.toString()
        canvas.drawText(fpsStr, cx, cy + (2f * density), fpsTextPaint)

        // 7. FPS Unit Tag
        unitTextPaint.textSize = 7.5f * density
        unitTextPaint.color = if (isPerformanceMode) {
            Color.parseColor("#E11D48")
        } else {
            if (isLightMode) Color.parseColor("#0284C7") else Color.parseColor("#389BFF")
        }
        canvas.drawText("FPS", cx, cy + (12f * density), unitTextPaint)
    }
}

/**
 * Custom View rendering smooth gradient progress meters for CPU & GPU live telemetry.
 */
class TelemetryProgressBarView @JvmOverloads constructor(
    context: Context,
    var progress: Float = 0.5f,
    var startColor: Int = Color.parseColor("#007AFF"),
    var endColor: Int = Color.parseColor("#60A5FA"),
    var isLightMode: Boolean = false
) : View(context) {

    private val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = if (isLightMode) Color.parseColor("#E2E8F0") else Color.parseColor("#24FFFFFF")
        style = Paint.Style.FILL
    }

    private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
    }

    fun updateProgress(p: Float, start: Int, end: Int) {
        progress = p
        startColor = start
        endColor = end
        bgPaint.color = if (isLightMode) Color.parseColor("#E2E8F0") else Color.parseColor("#24FFFFFF")
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val w = width.toFloat()
        val h = height.toFloat()
        if (w <= 0 || h <= 0) return

        val corner = h / 2f
        bgPaint.color = if (isLightMode) Color.parseColor("#E2E8F0") else Color.parseColor("#24FFFFFF")
        canvas.drawRoundRect(0f, 0f, w, h, corner, corner, bgPaint)

        val fillW = (w * progress.coerceIn(0f, 1f)).coerceAtLeast(corner * 2)
        fillPaint.shader = LinearGradient(0f, 0f, fillW, 0f, startColor, endColor, Shader.TileMode.CLAMP)
        canvas.drawRoundRect(0f, 0f, fillW, h, corner, corner, fillPaint)
    }
}
