package com.example.owl

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.owl/games"
    private val executor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
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
                    if (packageName.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "Package name cannot be empty", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
                        if (launchIntent != null) {
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
}
