package com.example.owl

import android.Manifest
import android.app.ActivityManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioRecord
import android.media.AudioTrack
import android.media.MediaRecorder
import android.media.projection.MediaProjectionManager
import android.net.Uri
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.Choreographer
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.concurrent.Executors
import kotlin.math.sin

class MainActivity : FlutterActivity() {
    private val CHANNEL        = "com.example.owl/games"
    private val STATS_CHANNEL  = "com.example.owl/stats"
    private val SYSTEM_CHANNEL = "com.example.owl/system_controls"
    private val VOICE_CHANNEL  = "com.example.owl/voice_changer"
    private val CAPTURE_CHANNEL = "com.example.owl/screen_capture"

    private val REQUEST_SCREEN_CAPTURE = 8812
    private var pendingScreenCaptureResult: MethodChannel.Result? = null

    private val executor = Executors.newSingleThreadExecutor()
    private var floatingHandleView: View? = null

    // ── Live Stats EventChannel state ──────────────────────────────────────────
    private var statsEventSink: EventChannel.EventSink? = null
    private val statsHandler   = Handler(Looper.getMainLooper())
    private var statsRunnable: Runnable? = null

    // FPS measurement via sliding-window frame interval & hardware sysfs
    private var lastFrameTimeNanos = 0L
    private val frameIntervalsNanos = LongArray(16)
    private var frameIntervalIndex = 0
    private var frameIntervalCount = 0
    private var currentMeasuredFps = 0
    private var lastActiveFrameTimestamp = 0L
    private var choreographerStarted = false

    private val frameCallback = object : Choreographer.FrameCallback {
        override fun doFrame(frameTimeNanos: Long) {
            if (lastFrameTimeNanos > 0L) {
                val interval = frameTimeNanos - lastFrameTimeNanos
                // Valid frame durations between 3ms (333 FPS) and 250ms (4 FPS)
                if (interval in 3_000_000L..250_000_000L) {
                    frameIntervalsNanos[frameIntervalIndex] = interval
                    frameIntervalIndex = (frameIntervalIndex + 1) % frameIntervalsNanos.size
                    if (frameIntervalCount < frameIntervalsNanos.size) frameIntervalCount++
                    lastActiveFrameTimestamp = System.currentTimeMillis()

                    var sum = 0L
                    for (i in 0 until frameIntervalCount) {
                        sum += frameIntervalsNanos[i]
                    }
                    val avgInterval = sum / frameIntervalCount
                    if (avgInterval > 0) {
                        currentMeasuredFps = (1_000_000_000.0 / avgInterval).toInt()
                    }
                }
            }
            lastFrameTimeNanos = frameTimeNanos
            if (choreographerStarted) {
                Choreographer.getInstance().postFrameCallback(this)
            }
        }
    }

    // CPU idle/total state for delta calculation
    @Volatile private var prevIdle  = 0L
    @Volatile private var prevTotal = 0L

    // ── Flutter Engine Config ──────────────────────────────────────────────────
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Method channel — keeps existing operations (install scan, launch, overlay control)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasOverlayPermission" -> {
                        result.success(
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                                Settings.canDrawOverlays(this)
                            else true
                        )
                    }
                    "requestOverlayPermission" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            ).apply { addFlags(Intent.FLAG_ACTIVITY_NEW_TASK) }
                            startActivity(intent)
                        }
                        result.success(true)
                    }
                    "showFloatingOverlay" -> {
                        val gameName = call.argument<String>("gameName")
                        GameTurboOverlayService.start(
                            this,
                            gameName = gameName,
                            isLight = readIsLightMode(),
                        )
                        result.success(true)
                    }
                    "hideFloatingOverlay" -> {
                        GameTurboOverlayService.stop(this)
                        result.success(true)
                    }
                    "setThemeMode" -> {
                        val modeStr = call.argument<String>("themeMode") ?: "system"
                        val isLight = when (modeStr) {
                            "light" -> true
                            "dark" -> false
                            else -> {
                                val nightMode = resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK
                                nightMode != android.content.res.Configuration.UI_MODE_NIGHT_YES
                            }
                        }
                        GameTurboOverlayService.setThemeMode(isLight)
                        result.success(true)
                    }
                    "showGuardianOverlay" -> {
                        GameTurboOverlayService.showGuardianOverlay()
                        result.success(true)
                    }
                    "hideGuardianOverlay" -> {
                        GameTurboOverlayService.hideGuardianOverlay()
                        result.success(true)
                    }
                    "getInstalledGames" -> {
                        executor.execute {
                            try {
                                val games = scanInstalledGames(onlyGames = true)
                                runOnUiThread { result.success(games) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("SCAN_ERROR", e.message, null) }
                            }
                        }
                    }
                    "getAllApplications" -> {
                        executor.execute {
                            try {
                                val apps = scanInstalledGames(onlyGames = false)
                                runOnUiThread { result.success(apps) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("SCAN_ERROR", e.message, null) }
                            }
                        }
                    }
                    "launchGame" -> {
                        val packageName = call.argument<String>("packageName")
                        val gameName    = call.argument<String>("gameName") ?: "Game"
                        val targetFps   = call.argument<Int>("targetFps") ?: 120
                        val aiApiKey    = call.argument<String>("aiApiKey")
                        val aiProvider  = call.argument<String>("aiProvider") ?: "gemini"
                        val aiModel     = call.argument<String>("aiModel") ?: "gemini-3-flash-preview"
                        if (packageName.isNullOrEmpty()) {
                            result.error("INVALID_ARGS", "Package name cannot be empty", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                            if (launchIntent != null) {
                                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M ||
                                    Settings.canDrawOverlays(this)) {
                                    GameTurboOverlayService.start(
                                        this,
                                        gameName,
                                        targetFps,
                                        isLight = readIsLightMode(),
                                        aiApiKey = aiApiKey,
                                        aiProvider = aiProvider,
                                        aiModel = aiModel
                                    )
                                }
                                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(launchIntent)
                                result.success(true)
                            } else {
                                result.success(false)
                            }
                        } catch (e: Exception) {
                            result.error("LAUNCH_FAILED", e.message, null)
                        }
                    }
                    "setAiCredentials" -> {
                        val apiKey = call.argument<String>("apiKey")
                        val provider = call.argument<String>("provider") ?: "gemini"
                        val model = call.argument<String>("model") ?: "gemini-2.5-flash"
                        GameTurboOverlayService.setAiCredentials(this, apiKey, provider, model)
                        result.success(true)
                    }
                    "setGameContext" -> {
                        val gameCategory = call.argument<String>("gameCategory") ?: "5v5 MOBA"
                        val preferredRole = call.argument<String>("preferredRole") ?: "auto"
                        val coachingLevel = call.argument<String>("coachingLevel") ?: "intermediate"
                        val matchElapsedSeconds = call.argument<Int>("matchElapsedSeconds") ?: 0
                        GameTurboOverlayService.setGameContext(
                            this, gameCategory, preferredRole, coachingLevel, matchElapsedSeconds
                        )
                        result.success(true)
                    }
                    "hasScreenCapturePermission" -> {
                        result.success(GameTurboOverlayService.hasMediaProjectionPermission())
                    }
                    "requestScreenCapturePermission" -> {
                        val mpm = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as? MediaProjectionManager
                        if (mpm != null) {
                            pendingScreenCaptureResult = result
                            startActivityForResult(mpm.createScreenCaptureIntent(), REQUEST_SCREEN_CAPTURE)
                        } else {
                            result.success(false)
                        }
                    }
                    "setGuardianVisionEnabled" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: true
                        GameTurboOverlayService.isVisionEnabled = enabled
                        result.success(true)
                    }
                    "updateTacticalAdvice" -> {
                        val badge = call.argument<String>("badge") ?: "GUARDIAN AI"
                        val action = call.argument<String>("action") ?: "Hold Position"
                        val warning = call.argument<String>("warning")
                        GameTurboOverlayService.updateTacticalAdvice(badge, action, warning)
                        result.success(true)
                    }
                    // Keep legacy single-shot calls as fallback (they still work from main thread)
                    "getBatteryLevel" -> result.success(readBatteryLevel())
                    "getCpuUsage"     -> result.success(readCpuUsageSingleShot())
                    "setPerformanceMode" -> {
                        val isPerf = call.argument<Boolean>("isPerformance") ?: true
                        val targetFps = call.argument<Int>("targetFps") ?: (if (isPerf) 120 else 60)
                        applyPerformanceMode(isPerf, targetFps)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }

        // 2. EventChannel — pushes {battery, cpu, fps, gpu} every 2 s without blocking Flutter
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, STATS_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    statsEventSink = events
                    startChoreographer()
                    scheduleStatsPush()
                }
                override fun onCancel(arguments: Any?) {
                    stopStatsPush()
                    stopChoreographer()
                    statsEventSink = null
                }
            })

        // 3. System Controls Channel (DND ZenMode, Wi-Fi low-latency lock)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isNotificationPolicyAccessGranted" -> {
                        result.success(HardwareSystemController.isNotificationPolicyAccessGranted(this))
                    }
                    "requestNotificationPolicyAccess" -> {
                        HardwareSystemController.openNotificationPolicySettings(this)
                        result.success(true)
                    }
                    "setDndMode" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        val success = HardwareSystemController.setDndMode(this, enabled)
                        result.success(success)
                    }
                    "setWifiLowLatency" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        val success = HardwareSystemController.setWifiLowLatency(this, enabled)
                        result.success(success)
                    }
                    else -> result.notImplemented()
                }
            }

        // 4. Tactical Voice Changer Channel (Real-time DSP pitch/formant shifting)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VOICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startVoiceProcessing" -> {
                        val preset = call.argument<String>("preset") ?: "commander"
                        val success = HardwareSystemController.startVoiceProcessing(this, preset)
                        result.success(success)
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

        // 5. Screen Capture Channel (MediaProjection raw frame sampling)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CAPTURE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasCapturePermission" -> {
                        result.success(GameTurboOverlayService.hasMediaProjectionPermission())
                    }
                    "requestCapturePermission" -> {
                        val mpm = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as? MediaProjectionManager
                        if (mpm != null) {
                            pendingScreenCaptureResult = result
                            startActivityForResult(mpm.createScreenCaptureIntent(), REQUEST_SCREEN_CAPTURE)
                        } else {
                            result.success(false)
                        }
                    }
                    "getLatestFrame" -> {
                        GameTurboOverlayService.captureFrameBytes(this) { bytes: ByteArray?, width: Int, height: Int ->
                            if (bytes != null && width > 0 && height > 0) {
                                result.success(mapOf("bytes" to bytes, "width" to width, "height" to height))
                            } else {
                                result.success(null)
                            }
                        }
                    }
                    "stopCapture" -> {
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // ── Stats push loop ────────────────────────────────────────────────────────

    private var lastCpuTime = 0L
    private var lastSampleTime = 0L
    private var lastValidCpuUsage = 0

    // SELinux blocks most untrusted_app sysfs freq/display nodes on OEM ROMs.
    // Probe once; never re-open denied paths every stats tick (AVC spam).
    @Volatile private var gpuSysfsProbed = false
    @Volatile private var cachedGpuCurPath: String? = null
    @Volatile private var cachedGpuMaxPath: String? = null
    @Volatile private var hwFpsSysfsProbed = false
    @Volatile private var cachedHwFpsPath: String? = null

    private fun readHardwareDisplayFps(): Int? {
        if (!hwFpsSysfsProbed) {
            val paths = listOf(
                "/sys/class/drm/card0/device/fps",
                "/sys/class/graphics/fb0/measured_fps",
                "/sys/devices/platform/soc/soc:qcom,dsi-display-primary/measured_fps",
                "/sys/devices/virtual/graphics/fb0/fps",
                "/sys/class/drm/card0-DSI-1/measured_fps",
                "/sys/devices/platform/soc/soc:qcom,dsi-display-0/measured_fps"
            )
            for (p in paths) {
                try {
                    val content = File(p).readText().trim()
                    val v = content.split(".").first().toIntOrNull()
                    if (v != null && v in 24..240) {
                        cachedHwFpsPath = p
                        hwFpsSysfsProbed = true
                        return v
                    }
                } catch (_: Exception) {}
            }
            hwFpsSysfsProbed = true
            return null
        }
        val path = cachedHwFpsPath ?: return null
        return try {
            val content = File(path).readText().trim()
            val v = content.split(".").first().toIntOrNull()
            if (v != null && v in 24..240) v else null
        } catch (_: Exception) {
            cachedHwFpsPath = null
            null
        }
    }

    private var activePerformanceMode = true
    private var activeTargetFps = 120

    private fun applyPerformanceMode(isPerf: Boolean, targetFps: Int) {
        if (activePerformanceMode == isPerf && activeTargetFps == targetFps) {
            // Still sync overlay service, but skip redundant Activity window mode switch.
            GameTurboOverlayService.setPerformanceMode(isPerf, targetFps)
            return
        }
        activePerformanceMode = isPerf
        activeTargetFps = targetFps
        runOnUiThread {
            try {
                // Only mutate Owl Activity window when it is visible — never hitch an
                // in-game session by forcing display mode from a paused activity.
                if (!isFinishing && hasWindowFocus() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    val targetRate = if (isPerf) targetFps.toFloat() else 60.0f
                    val lp = window?.attributes
                    if (lp != null) {
                        lp.preferredRefreshRate = targetRate
                        val d = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                            display
                        } else {
                            @Suppress("DEPRECATION")
                            windowManager?.defaultDisplay
                        }
                        d?.supportedModes?.let { modes ->
                            val bestMode = if (isPerf) {
                                modes.filter { it.refreshRate >= 89f }.maxByOrNull { it.refreshRate }
                            } else {
                                modes.firstOrNull { it.refreshRate in 59f..61f }
                            }
                            if (bestMode != null) {
                                lp.preferredDisplayModeId = bestMode.modeId
                            }
                        }
                        window?.attributes = lp
                    }
                }
                GameTurboOverlayService.setPerformanceMode(isPerf, targetFps)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun getLiveFps(): Int {
        // 0. If overlay service has real sampled frames from game or compositor, prioritize it!
        val overlayFps = GameTurboOverlayService.getOverlayEffectiveLiveFps()
        if (overlayFps != null && overlayFps > 0) {
            return if (activePerformanceMode) overlayFps else overlayFps.coerceAtMost(60)
        }

        // 1. Hardware panel FPS from kernel driver (Qualcomm/MediaTek display controller)
        val hwFps = readHardwareDisplayFps()
        if (hwFps != null && hwFps > 0) {
            return if (activePerformanceMode) hwFps else hwFps.coerceAtMost(60)
        }

        // 2. Query display native refresh rate (e.g. 60, 90, 120, 144)
        val displayRefreshRate = try {
            val d = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                display
            } else {
                @Suppress("DEPRECATION")
                windowManager?.defaultDisplay
            }
            d?.refreshRate?.toInt() ?: activeTargetFps
        } catch (_: Exception) {
            activeTargetFps
        }

        // Effective ceiling strictly enforced by Balanced vs Performance mode
        val effectiveCeiling = if (activePerformanceMode) displayRefreshRate else 60

        // 3. If frames were actively rendered within the last 500ms, use moving average FPS
        val elapsedSinceLastFrame = System.currentTimeMillis() - lastActiveFrameTimestamp
        if (elapsedSinceLastFrame < 500 && currentMeasuredFps in 15..240) {
            return currentMeasuredFps.coerceIn(15, effectiveCeiling)
        }

        // 4. Idle state: display sits at effective ceiling
        return effectiveCeiling
    }

    private fun readDeviceTelemetryExtras(): Pair<Double, Int> {
        var tempC = 0.0
        var ramMb = 0
        try {
            val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val rawTemp = intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1) ?: -1
            if (rawTemp > 0) {
                tempC = rawTemp / 10.0
            }
        } catch (_: Exception) {}

        try {
            val mi = ActivityManager.MemoryInfo()
            val am = getSystemService(ACTIVITY_SERVICE) as ActivityManager
            am.getMemoryInfo(mi)
            ramMb = ((mi.totalMem - mi.availMem) / (1024 * 1024)).toInt()
        } catch (_: Exception) {}

        return Pair(tempC, ramMb)
    }

    private var lastPushedStatsKey: String? = null

    private fun scheduleStatsPush() {
        val r = object : Runnable {
            override fun run() {
                executor.execute {
                    val battery = readBatteryLevel()
                    // Quantize noisy counters so Flutter can skip no-op emits.
                    val cpu     = ((readCpuDelta() + 1) / 2) * 2
                    val gpu     = ((readGpuFreqPercent() + 1) / 2) * 2
                    val fps     = ((getLiveFps() + 1) / 2) * 2
                    val (tempC, ramMb) = readDeviceTelemetryExtras()
                    val ramQuantized = ((ramMb + 8) / 16) * 16
                    val tempQuantized =
                        if (tempC > 0.0) (Math.round(tempC * 2.0) / 2.0) else 0.0

                    val key = "$battery|$cpu|$gpu|$fps|$ramQuantized|$tempQuantized"
                    if (key == lastPushedStatsKey) {
                        // Keep Dart's EventChannel "alive" without a value change emit.
                        runOnUiThread {
                            statsEventSink?.success(mapOf("keepalive" to true))
                        }
                        return@execute
                    }
                    lastPushedStatsKey = key

                    val map = mutableMapOf<String, Any>(
                        "battery" to battery,
                        "cpu"     to cpu,
                        "gpu"     to gpu,
                        "fps"     to fps,
                        "ram"     to ramQuantized
                    )
                    if (tempQuantized > 0.0) {
                        map["temperature"] = tempQuantized
                    }

                    runOnUiThread {
                        statsEventSink?.success(map)
                        // Also push to native overlay service so its UI stays live
                        GameTurboOverlayService.pushStats(cpu, gpu, battery, fps)
                    }
                }
                statsRunnable?.let { statsHandler.postDelayed(it, 1000) }
            }
        }
        statsRunnable = r
        statsHandler.post(r)
    }

    private fun stopStatsPush() {
        statsRunnable?.let { statsHandler.removeCallbacks(it) }
        statsRunnable = null
        lastPushedStatsKey = null
    }

    private fun startChoreographer() {
        if (choreographerStarted) return
        choreographerStarted = true
        lastFrameTimeNanos = 0L
        frameIntervalCount = 0
        frameIntervalIndex = 0
        currentMeasuredFps = 0
        Choreographer.getInstance().postFrameCallback(frameCallback)
    }

    private fun stopChoreographer() {
        choreographerStarted = false
    }

    // ── Stat readers ───────────────────────────────────────────────────────────

    private fun readBatteryLevel(): Int {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val bm = getSystemService(BATTERY_SERVICE) as? BatteryManager
                val capacity = bm?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) ?: -1
                if (capacity in 0..100) return capacity
            }
            val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val lvl   = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
            if (lvl >= 0 && scale > 0) return (lvl * 100 / scale).coerceIn(0, 100)
        } catch (_: Exception) {}
        return 0
    }

    /**
     * CPU usage from /proc/stat delta, with Process.getElapsedCpuTime fallback.
     * Does not touch cpufreq sysfs (SELinux-denied for untrusted_app on OEM ROMs).
     */
    private fun readCpuDelta(): Int {
        // 1. /proc/stat line 1 delta
        try {
            val line = java.io.BufferedReader(java.io.FileReader("/proc/stat")).use { it.readLine() }
            if (line != null && line.startsWith("cpu ")) {
                val parts = line.trim().split("\\s+".toRegex()).drop(1)
                    .map { it.toLongOrNull() ?: 0L }
                val idle = if (parts.size > 3) parts[3] else 0L
                val total = parts.sum()
                val diffIdle = idle - prevIdle
                val diffTotal = total - prevTotal
                prevIdle = idle
                prevTotal = total
                if (diffTotal > 0) {
                    val usage = ((diffTotal - diffIdle) * 100 / diffTotal).toInt().coerceIn(0, 100)
                    lastValidCpuUsage = usage
                    return usage
                }
            }
        } catch (_: Exception) {}

        // Sysfs cpufreq is SELinux-denied for untrusted_app on many OEM ROMs
        // (AVC on scaling_*_freq). Prefer /proc/stat + process delta only.

        // 2. Process CPU delta vs clock
        try {
            val nowTime = android.os.SystemClock.elapsedRealtime()
            val cpuTime = android.os.Process.getElapsedCpuTime()
            val dt = nowTime - lastSampleTime
            val dCpu = cpuTime - lastCpuTime
            lastSampleTime = nowTime
            lastCpuTime = cpuTime
            if (dt > 100 && dCpu >= 0) {
                val cores = Runtime.getRuntime().availableProcessors().coerceAtLeast(1)
                val procUsage = ((dCpu.toDouble() / (dt * cores)) * 100).toInt().coerceIn(0, 100)
                lastValidCpuUsage = procUsage
                return procUsage
            }
        } catch (_: Exception) {}

        return lastValidCpuUsage
    }

    /** Legacy single-shot: used only by the fallback MethodChannel calls. */
    private fun readCpuUsageSingleShot(): Int {
        return readCpuDelta()
    }

    /**
     * Reads GPU frequency from Qualcomm kgsl sysfs, MediaTek Mali or devfreq nodes.
     * When hardware nodes are restricted by SELinux, derives GPU workload proportionally
     * from live frame delivery load and real CPU pressure.
     */
    private fun readGpuFreqPercent(): Int {
        if (!gpuSysfsProbed) {
            val freqPaths = listOf(
                "/sys/class/kgsl/kgsl-3d0/gpuclk",
                "/sys/class/kgsl/kgsl-3d0/gpu_clock_stats",
                "/sys/class/devfreq/kgsl-3d0/cur_freq",
                "/sys/class/devfreq/13000000.mali/cur_freq",
                "/sys/class/devfreq/mtk-dvfsrc-devfreq/cur_freq",
                "/sys/kernel/gpu/gpu_freq",
                "/sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/gpuclk",
            )
            val maxPaths = listOf(
                "/sys/class/kgsl/kgsl-3d0/max_gpuclk",
                "/sys/class/devfreq/kgsl-3d0/max_freq",
                "/sys/class/devfreq/13000000.mali/max_freq",
                "/sys/class/devfreq/mtk-dvfsrc-devfreq/max_freq",
            )
            for (path in freqPaths) {
                try {
                    val v = File(path).readText().trim().toLongOrNull()
                    if (v != null && v > 0) {
                        cachedGpuCurPath = path
                        break
                    }
                } catch (_: Exception) {}
            }
            if (cachedGpuCurPath != null) {
                for (path in maxPaths) {
                    try {
                        val v = File(path).readText().trim().toLongOrNull()
                        if (v != null && v > 0) {
                            cachedGpuMaxPath = path
                            break
                        }
                    } catch (_: Exception) {}
                }
            }
            gpuSysfsProbed = true
        }

        val curPath = cachedGpuCurPath
        val maxPath = cachedGpuMaxPath
        if (curPath != null && maxPath != null) {
            try {
                val cur = File(curPath).readText().trim().toLongOrNull()
                val max = File(maxPath).readText().trim().toLongOrNull()
                if (cur != null && max != null && max > 0) {
                    return ((cur.toFloat() / max.toFloat()) * 100).toInt().coerceIn(0, 100)
                }
            } catch (_: Exception) {
                cachedGpuCurPath = null
                cachedGpuMaxPath = null
            }
        }

        // Deterministic derivation when sysfs is SELinux-blocked (typical on MIUI/MTK)
        val liveFps = getLiveFps()
        val targetRate = if (activePerformanceMode) activeTargetFps else 60
        val fpsLoadRatio = (liveFps.toFloat() / targetRate.toFloat()).coerceIn(0f, 1f)
        return ((fpsLoadRatio * 60f) + (lastValidCpuUsage * 0.35f)).toInt().coerceIn(5, 95)
    }

    private fun readIsLightMode(): Boolean {
        val modeStr = try {
            getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                .getString("flutter.owl_theme_mode", "system")
        } catch (_: Exception) { "system" }
        return when (modeStr) {
            "light" -> true
            "dark" -> false
            else -> {
                val nightMode = resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK
                nightMode != android.content.res.Configuration.UI_MODE_NIGHT_YES
            }
        }
    }

    // ── App scanning ───────────────────────────────────────────────────────────

    private fun scanInstalledGames(onlyGames: Boolean): List<Map<String, Any?>> {
        val pm            = packageManager
        val installedApps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val resultList    = mutableListOf<Map<String, Any?>>()

        val launcherIntent    = Intent(Intent.ACTION_MAIN, null).apply { addCategory(Intent.CATEGORY_LAUNCHER) }
        val launchablePackages = pm.queryIntentActivities(launcherIntent, 0)
            .map { it.activityInfo.packageName }.toSet()

        for (app in installedApps) {
            if (!launchablePackages.contains(app.packageName) || app.packageName == packageName) continue

            val isGameCategory = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                app.category == ApplicationInfo.CATEGORY_GAME else false
            val isLegacyGame   = (app.flags and ApplicationInfo.FLAG_IS_GAME) != 0
            val isKnownGame    = isKnownGamePackage(app.packageName)
            val isGame         = isGameCategory || isLegacyGame || isKnownGame

            if (onlyGames && !isGame) continue

            val label     = pm.getApplicationLabel(app).toString()
            val iconBytes = try { drawableToByteArray(pm.getApplicationIcon(app)) } catch (_: Exception) { null }

            resultList.add(mapOf(
                "packageName" to app.packageName,
                "name"        to label,
                "iconBytes"   to iconBytes,
                "isGame"      to isGame,
                "isSystem"    to ((app.flags and ApplicationInfo.FLAG_SYSTEM) != 0),
            ))
        }
        return resultList
    }

    private fun isKnownGamePackage(pkg: String): Boolean {
        val lower = pkg.lowercase()
        return lower.contains("moba") || lower.contains("riotgames") ||
               lower.contains("wildrift") || lower.contains("mobile.legends") ||
               lower.contains("pokemon.unite") || lower.contains("pubg") ||
               lower.contains("freefire") || lower.contains("codm") ||
               lower.contains("genshin") || lower.contains("honkai") ||
               lower.contains("epicgames") || lower.contains("supercell") ||
               lower.contains("brawlstars") || lower.contains("clashofclans") ||
               lower.contains("roblox") || lower.contains("minecraft") ||
               lower.contains("tencent.ig")
    }

    private fun drawableToByteArray(drawable: Drawable): ByteArray? {
        val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
            drawable.bitmap
        } else {
            val w   = if (drawable.intrinsicWidth  > 0) drawable.intrinsicWidth  else 72
            val h   = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 72
            val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            drawable.setBounds(0, 0, w, h)
            drawable.draw(Canvas(bmp))
            bmp
        }
        return ByteArrayOutputStream().also {
            bitmap.compress(Bitmap.CompressFormat.PNG, 85, it)
        }.toByteArray()
    }

    // ── System Controls (DND ZenMode & Wi-Fi Low-Latency) ─────────────────────

    override fun onDestroy() {
        super.onDestroy()
        HardwareSystemController.stopVoiceProcessing()
        HardwareSystemController.setWifiLowLatency(this, false)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_SCREEN_CAPTURE) {
            if (resultCode == android.app.Activity.RESULT_OK && data != null) {
                GameTurboOverlayService.setMediaProjectionData(resultCode, data)
                pendingScreenCaptureResult?.success(true)
            } else {
                pendingScreenCaptureResult?.success(false)
            }
            pendingScreenCaptureResult = null
        }
    }
}
