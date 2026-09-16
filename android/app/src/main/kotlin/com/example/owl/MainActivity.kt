package com.example.owl

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
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import android.provider.Settings
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.owl/games"
    private val executor = Executors.newSingleThreadExecutor()
    private var floatingHandleView: View? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(Settings.canDrawOverlays(this))
                    } else {
                        result.success(true)
                    }
                }
                "requestOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } else {
                        result.success(true)
                    }
                }
                "showFloatingOverlay" -> {
                    GameTurboOverlayService.start(this)
                    result.success(true)
                }
                "hideFloatingOverlay" -> {
                    GameTurboOverlayService.stop(this)
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
                    val gameName = call.argument<String>("gameName") ?: "Game"
                    val targetFps = call.argument<Int>("targetFps") ?: 120
                    if (packageName.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "Package name cannot be empty", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                        if (launchIntent != null) {
                            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)) {
                                GameTurboOverlayService.start(this, gameName, targetFps)
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
                "getBatteryLevel" -> {
                    try {
                        val level = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            val bm = getSystemService(BATTERY_SERVICE) as BatteryManager
                            bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                        } else {
                            val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
                            val lvl = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
                            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
                            if (lvl >= 0 && scale > 0) (lvl * 100 / scale) else -1
                        }
                        result.success(level)
                    } catch (e: Exception) {
                        result.success(-1)
                    }
                }
                "getCpuUsage" -> {
                    executor.execute {
                        try {
                            fun readCpuStats(): Pair<Long, Long> {
                                val line = File("/proc/stat").readLines().firstOrNull() ?: return Pair(0L, 0L)
                                val parts = line.trim().split("\\s+".toRegex()).drop(1).map { it.toLongOrNull() ?: 0L }
                                val idle = if (parts.size > 3) parts[3] else 0L
                                val total = parts.sum()
                                return Pair(idle, total)
                            }
                            val (idle1, total1) = readCpuStats()
                            Thread.sleep(250)
                            val (idle2, total2) = readCpuStats()
                            val diffTotal = total2 - total1
                            val diffIdle = idle2 - idle1
                            val usage = if (diffTotal > 0) ((diffTotal - diffIdle) * 100 / diffTotal).toInt() else 0
                            runOnUiThread { result.success(usage) }
                        } catch (e: Exception) {
                            runOnUiThread { result.success(0) }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scanInstalledGames(onlyGames: Boolean): List<Map<String, Any?>> {
        val pm = packageManager
        val installedApps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        val resultList = mutableListOf<Map<String, Any?>>()

        // Query launcher intents to guarantee the app is user-launchable
        val launcherIntent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val launchablePackages = pm.queryIntentActivities(launcherIntent, 0)
            .map { it.activityInfo.packageName }
            .toSet()

        for (app in installedApps) {
            // Must be launchable and not our own companion app
            if (!launchablePackages.contains(app.packageName) || app.packageName == packageName) {
                continue
            }

            val isGameCategory = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                app.category == ApplicationInfo.CATEGORY_GAME
            } else {
                false
            }
            val isLegacyGame = (app.flags and ApplicationInfo.FLAG_IS_GAME) != 0
            val isKnownGame = isKnownGamePackage(app.packageName)

            val isGame = isGameCategory || isLegacyGame || isKnownGame

            if (onlyGames && !isGame) {
                continue
            }

            val label = pm.getApplicationLabel(app).toString()
            val iconBytes = try {
                val iconDrawable = pm.getApplicationIcon(app)
                drawableToByteArray(iconDrawable)
            } catch (e: Exception) {
                null
            }

            val appMap = HashMap<String, Any?>()
            appMap["packageName"] = app.packageName
            appMap["name"] = label
            appMap["iconBytes"] = iconBytes
            appMap["isGame"] = isGame
            appMap["isSystem"] = (app.flags and ApplicationInfo.FLAG_SYSTEM) != 0

            resultList.add(appMap)
        }

        return resultList
    }

    private fun isKnownGamePackage(pkg: String): Boolean {
        val lower = pkg.lowercase()
        return lower.contains("moba") ||
                lower.contains("riotgames") ||
                lower.contains("wildrift") ||
                lower.contains("mobile.legends") ||
                lower.contains("pokemon.unite") ||
                lower.contains("pubg") ||
                lower.contains("freefire") ||
                lower.contains("codm") ||
                lower.contains("genshin") ||
                lower.contains("honkai") ||
                lower.contains("epicgames") ||
                lower.contains("supercell") ||
                lower.contains("brawlstars") ||
                lower.contains("clashofclans") ||
                lower.contains("roblox") ||
                lower.contains("minecraft") ||
                lower.contains("tencent.ig")
    }

    private fun drawableToByteArray(drawable: Drawable): ByteArray? {
        val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
            drawable.bitmap
        } else {
            val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 72
            val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 72
            val bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }

        val outputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 85, outputStream)
        return outputStream.toByteArray()
    }

    private fun showNativeFloatingHandle() {
        if (floatingHandleView != null) return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) return

        runOnUiThread {
            try {
                val wm = getSystemService(WINDOW_SERVICE) as WindowManager
                val layoutParams = WindowManager.LayoutParams(
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
                    } else {
                        @Suppress("DEPRECATION")
                        WindowManager.LayoutParams.TYPE_PHONE
                    },
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                    PixelFormat.TRANSLUCENT
                ).apply {
                    gravity = Gravity.TOP or Gravity.START
                    x = 100
                    y = 30
                }

                val pill = FrameLayout(this).apply {
                    val bg = GradientDrawable().apply {
                        shape = GradientDrawable.RECTANGLE
                        cornerRadius = 50f
                        setColor(Color.parseColor("#E60D121B"))
                        setStroke(2, Color.parseColor("#40FFFFFF"))
                    }
                    background = bg
                    setPadding(28, 14, 28, 14)

                    val text = TextView(context).apply {
                        text = "⚡ TURBO 120 FPS"
                        setTextColor(Color.WHITE)
                        textSize = 11f
                        typeface = Typeface.DEFAULT_BOLD
                    }
                    addView(text)

                    setOnClickListener {
                        val bringToFront = Intent(context, MainActivity::class.java).apply {
                            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_SINGLE_TOP
                        }
                        startActivity(bringToFront)
                    }
                }

                wm.addView(pill, layoutParams)
                floatingHandleView = pill
            } catch (e: Exception) {
                // Ignore overlay errors on devices without permission
            }
        }
    }

    private fun hideNativeFloatingHandle() {
        runOnUiThread {
            try {
                if (floatingHandleView != null) {
                    val wm = getSystemService(WINDOW_SERVICE) as WindowManager
                    wm.removeView(floatingHandleView)
                    floatingHandleView = null
                }
            } catch (e: Exception) {}
        }
    }
}
