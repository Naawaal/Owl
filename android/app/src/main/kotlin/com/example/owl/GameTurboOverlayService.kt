package com.example.owl

import android.app.Service
import android.content.Context
import android.content.Intent
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
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.provider.Settings
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Android System Overlay Service for Xiaomi HyperOS Game Turbo 2026.
 *
 * Implements a dual-state System Alert Window (TYPE_APPLICATION_OVERLAY) over running games:
 * 1. Collapsed State: Persistent draggable edge handle ("TURBO 120 FPS") with emerald dot.
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

    private var currentGameName: String = "Mobile Legends: Bang Bang"
    private var currentTargetFps: Int = 120
    private var isPerformanceMode: Boolean = true
    private var isDndActive: Boolean = true
    private var isWifiBoostActive: Boolean = true
    private var isAiActive: Boolean = true
    private var isVoiceChangerActive: Boolean = false

    private var handleX: Int = 40
    private var handleY: Int = 80
    private val mainHandler = Handler(Looper.getMainLooper())

    // Live stat refs — updated by MainActivity.pushStats()
    @Volatile var liveCpu: Int = 30
    @Volatile var liveGpu: Int = 56
    @Volatile var liveBattery: Int = 71
    @Volatile var liveFps: Int = 0
    var onModeUiUpdate: (() -> Unit)? = null

    fun updateWindowPreferredRefreshRate(rate: Float) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                val wm = windowManager ?: return
                collapsedHandleView?.let { v ->
                    (v.layoutParams as? WindowManager.LayoutParams)?.let { lp ->
                        lp.preferredRefreshRate = rate
                        wm.updateViewLayout(v, lp)
                    }
                }
                expandedToolboxView?.let { v ->
                    (v.layoutParams as? WindowManager.LayoutParams)?.let { lp ->
                        lp.preferredRefreshRate = rate
                        wm.updateViewLayout(v, lp)
                    }
                }
            } catch (_: Exception) {}
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        instance = this   // register singleton for pushStats()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
            stopSelf()
            return START_NOT_STICKY
        }

        intent?.getStringExtra("EXTRA_GAME_NAME")?.let {
            if (it.isNotEmpty()) currentGameName = it
        }
        val fpsExtra = intent?.getIntExtra("EXTRA_TARGET_FPS", -1) ?: -1
        if (fpsExtra > 0) {
            currentTargetFps = fpsExtra
        }

        val shouldExpand = intent?.getBooleanExtra("EXTRA_EXPAND", false) ?: false
        if (shouldExpand) {
            expandToolbox()
        } else if (collapsedHandleView == null && expandedToolboxView == null) {
            showCollapsedHandle()
        }
        startAutonomousTicker()
        return START_STICKY
    }

    private fun dp(value: Float): Int {
        return (value * resources.displayMetrics.density).toInt()
    }

    /**
     * Renders the slim, draggable floating trigger handle at the edge of the screen.
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

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = handleX
            y = handleY
        }

        val container = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL

            val bg = GradientDrawable().apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dp(999f).toFloat()
                setColor(Color.parseColor("#E60D121B"))
                setStroke(dp(1.5f), Color.parseColor("#4D3B82F6"))
            }
            background = bg
            setPadding(dp(12f), dp(6f), dp(12f), dp(6f))

            // Glowing Emerald pulse dot
            val dot = View(context).apply {
                background = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(Color.parseColor("#30D158"))
                }
                layoutParams = LinearLayout.LayoutParams(dp(7f), dp(7f)).apply {
                    marginEnd = dp(7f)
                }
            }
            addView(dot)

            val zapIcon = LucideIconView(context, LucideIconView.TYPE_ZAP, Color.parseColor("#FF5A5F"), 1.8f).apply {
                layoutParams = LinearLayout.LayoutParams(dp(11f), dp(11f)).apply {
                    marginEnd = dp(5f)
                }
            }
            addView(zapIcon)

            val text = TextView(context).apply {
                text = "TURBO ${currentTargetFps} FPS"
                setTextColor(Color.WHITE)
                textSize = 10.5f
                typeface = Typeface.DEFAULT_BOLD
                letterSpacing = 0.03f
                tag = "handle_fps_text"
            }
            addView(text)

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
                        if (Math.abs(dx) > dp(6f) || Math.abs(dy) > dp(6f)) {
                            isDrag = true
                        }
                        params.x = initialX + dx
                        params.y = initialY + dy
                        handleX = params.x
                        handleY = params.y
                        wm.updateViewLayout(v, params)
                        true
                    }
                    MotionEvent.ACTION_UP -> {
                        if (!isDrag) {
                            expandToolbox()
                        }
                        true
                    }
                    else -> false
                }
            }
        }

        try {
            wm.addView(container, params)
            collapsedHandleView = container
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    /**
     * Expands the sleek Xiaomi Game Turbo toolbox with Reactor Gauge and Live Telemetry.
     */
    private fun expandToolbox() {
        val wm = windowManager ?: return

        collapsedHandleView?.let {
            try {
                wm.removeView(it)
            } catch (e: Exception) {}
            collapsedHandleView = null
        }

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val rootParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )

        val root = FrameLayout(this).apply {
            setBackgroundColor(Color.parseColor("#33000000"))
            setOnClickListener {
                collapseToHandle()
            }
        }

        val cardWidth = dp(288f)
        val card = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            background = GradientDrawable(
                GradientDrawable.Orientation.TOP_BOTTOM,
                intArrayOf(Color.parseColor("#F5090B12"), Color.parseColor("#FA06070B"))
            ).apply {
                shape = GradientDrawable.RECTANGLE
                cornerRadius = dp(18f).toFloat()
                setStroke(dp(1f), Color.parseColor("#26389BFF"))
            }
            setPadding(dp(12f), dp(9f), dp(12f), dp(9f))
            layoutParams = FrameLayout.LayoutParams(
                cardWidth,
                ViewGroup.LayoutParams.WRAP_CONTENT
            ).apply {
                gravity = Gravity.TOP or Gravity.START
                val screenW = resources.displayMetrics.widthPixels
                val screenH = resources.displayMetrics.heightPixels
                leftMargin = dp(14f).coerceAtLeast(handleX - dp(20f)).coerceAtMost(screenW - cardWidth - dp(14f))
                topMargin = dp(10f).coerceAtLeast(handleY - dp(10f)).coerceAtMost((screenH - dp(270f)).coerceAtLeast(dp(10f)))
            }
            setOnClickListener {
                // Consume click inside card
            }
        }

        buildToolboxContent(card)
        root.addView(card)

        try {
            wm.addView(root, rootParams)
            expandedToolboxView = root
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun collapseToHandle() {
        val wm = windowManager ?: return

        expandedToolboxView?.let {
            try {
                wm.removeView(it)
            } catch (e: Exception) {}
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
                    setTextColor(Color.WHITE)
                }
                addView(title)
            }
            addView(titleLayout)

            val closeBtn = FrameLayout(context).apply {
                background = GradientDrawable().apply {
                    shape = GradientDrawable.OVAL
                    setColor(Color.parseColor("#1AFFFFFF"))
                }
                layoutParams = LinearLayout.LayoutParams(dp(22f), dp(22f))
                val icon = LucideIconView(context, LucideIconView.TYPE_CLOSE, Color.parseColor("#CBD5E1"), 1.8f).apply {
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
                setColor(Color.parseColor("#10FFFFFF"))
                setStroke(dp(1f), Color.parseColor("#1FFFFFFF"))
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
                    setTextColor(Color.parseColor("#8E9BAE"))
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
                        setTextColor(Color.parseColor("#8E9BAE"))
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
                setMode(isPerformanceMode, if (isPerformanceMode) currentTargetFps else 60)
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
                        setTextColor(Color.WHITE)
                        tag = "cpu_val"
                    }

                    val cpuLabelRow = LinearLayout(context).apply {
                        orientation = LinearLayout.HORIZONTAL
                        val l = TextView(context).apply {
                            text = "CPU"
                            textSize = 7.5f
                            setTextColor(Color.parseColor("#8E9BAE"))
                            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                        }
                        addView(l)
                        addView(cpuValText)
                    }
                    addView(cpuLabelRow)

                    val cpuProgress = TelemetryProgressBarView(
                        context,
                        liveCpu / 100f,
                        Color.parseColor("#007AFF"),
                        Color.parseColor("#60A5FA")
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
                        setTextColor(Color.WHITE)
                        tag = "gpu_val"
                    }

                    val gpuLabelRow = LinearLayout(context).apply {
                        orientation = LinearLayout.HORIZONTAL
                        val l = TextView(context).apply {
                            text = "GPU"
                            textSize = 7.5f
                            setTextColor(Color.parseColor("#8E9BAE"))
                            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f)
                        }
                        addView(l)
                        addView(gpuValText)
                    }
                    addView(gpuLabelRow)

                    val gpuProgress = TelemetryProgressBarView(
                        context,
                        liveGpu / 100f,
                        Color.parseColor("#8B5CF6"),
                        Color.parseColor("#C084FC")
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
                setColor(Color.parseColor("#1AFFFFFF"))
                setStroke(dp(1f), Color.parseColor("#1FFFFFFF"))
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
                if (isPerformanceMode) {
                    perfBtn.background = GradientDrawable(
                        GradientDrawable.Orientation.LEFT_RIGHT,
                        intArrayOf(Color.parseColor("#FF3B30"), Color.parseColor("#E63946"))
                    ).apply {
                        cornerRadius = dp(999f).toFloat()
                    }
                    perfBtn.setTextColor(Color.WHITE)
                    balancedBtn.background = null
                    balancedBtn.setTextColor(Color.parseColor("#8E9BAE"))
                } else {
                    balancedBtn.background = GradientDrawable(
                        GradientDrawable.Orientation.LEFT_RIGHT,
                        intArrayOf(Color.parseColor("#007AFF"), Color.parseColor("#0055B8"))
                    ).apply {
                        cornerRadius = dp(999f).toFloat()
                    }
                    balancedBtn.setTextColor(Color.WHITE)
                    perfBtn.background = null
                    perfBtn.setTextColor(Color.parseColor("#8E9BAE"))
                }

                val triple = gaugeContainer.tag as? Triple<*, *, *>
                val gauge = triple?.first as? ReactorGaugeView
                val displayFps = if (liveFps > 0) liveFps else (if (isPerformanceMode) currentTargetFps else 60)
                gauge?.setMode(isPerformanceMode, displayFps)

                val cpuPair = (triple?.second as? View)?.tag as? Pair<*, *>
                (cpuPair?.first as? TextView)?.text = "${liveCpu}%"
                (cpuPair?.second as? TelemetryProgressBarView)?.updateProgress(
                    liveCpu / 100f,
                    if (isPerformanceMode) Color.parseColor("#FF3B30") else Color.parseColor("#007AFF"),
                    if (isPerformanceMode) Color.parseColor("#FF6961") else Color.parseColor("#60A5FA")
                )

                val gpuPair = (triple?.third as? View)?.tag as? Pair<*, *>
                (gpuPair?.first as? TextView)?.text = "${liveGpu}%"
                (gpuPair?.second as? TelemetryProgressBarView)?.updateProgress(
                    liveGpu / 100f,
                    Color.parseColor("#8B5CF6"),
                    Color.parseColor("#C084FC")
                )
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
                    pushStats(liveCpu, liveGpu, liveBattery, 60)
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
                    currentTargetFps = 120
                    updateModeUi()
                    updateWindowPreferredRefreshRate(120f)
                    pushStats(liveCpu, liveGpu, liveBattery, 120)
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

        // 4. Essential 4 Tools (DND / Wi-Fi / AI / Voice) with Lucide vector icons
        val toolsRow = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )

            // DND
            addView(createToggleToolButton(
                LucideIconView.TYPE_BELL_OFF,
                "DND",
                isDndActive,
                Color.parseColor("#FF453A")
            ) { active ->
                isDndActive = active
                Toast.makeText(context, "DND: ${if (active) "ON" else "OFF"}", Toast.LENGTH_SHORT).show()
            })

            // Wi-Fi
            addView(createToggleToolButton(
                LucideIconView.TYPE_WIFI,
                "Wi-Fi",
                isWifiBoostActive,
                Color.parseColor("#389BFF")
            ) { active ->
                isWifiBoostActive = active
                Toast.makeText(context, "Wi-Fi Boost: ${if (active) "18ms" else "OFF"}", Toast.LENGTH_SHORT).show()
            })

            // AI Assistant / Guide
            addView(createToggleToolButton(
                LucideIconView.TYPE_BOT,
                "AI",
                isAiActive,
                Color.parseColor("#389BFF")
            ) { active ->
                isAiActive = active
                Toast.makeText(context, "AI Tactical Guide: ${if (active) "ACTIVE" else "OFF"}", Toast.LENGTH_SHORT).show()
            })

            // Voice Changer
            addView(createToggleToolButton(
                LucideIconView.TYPE_MIC,
                "Voice",
                isVoiceChangerActive,
                Color.parseColor("#A855F7")
            ) { active ->
                isVoiceChangerActive = active
                Toast.makeText(context, "Voice Changer: ${if (active) "ON" else "OFF"}", Toast.LENGTH_SHORT).show()
            })
        }
        card.addView(toolsRow)
    }

    private fun createToggleToolButton(
        iconType: Int,
        labelText: String,
        initialActive: Boolean,
        activeColor: Int,
        onToggle: (Boolean) -> Unit
    ): View {
        var isActive = initialActive
        val inactiveBgColor = Color.parseColor("#14FFFFFF")
        val inactiveBorderColor = Color.parseColor("#1FFFFFFF")
        val inactiveIconColor = Color.parseColor("#99FFFFFF")

        return LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER

            val iconView = LucideIconView(
                context,
                iconType,
                if (isActive) activeColor else inactiveIconColor,
                1.6f
            ).apply {
                layoutParams = LinearLayout.LayoutParams(dp(15f), dp(15f))
            }

            val label = TextView(context).apply {
                text = labelText
                textSize = 7.5f
                typeface = Typeface.DEFAULT_BOLD
                setTextColor(if (isActive) Color.WHITE else inactiveIconColor)
                gravity = Gravity.CENTER
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply { topMargin = dp(3f) }
            }

            fun updateBtnBg() {
                background = GradientDrawable().apply {
                    shape = GradientDrawable.RECTANGLE
                    cornerRadius = dp(10f).toFloat()
                    if (isActive) {
                        val alphaBg = Color.argb(45, Color.red(activeColor), Color.green(activeColor), Color.blue(activeColor))
                        setColor(alphaBg)
                        setStroke(dp(1f), activeColor)
                    } else {
                        setColor(inactiveBgColor)
                        setStroke(dp(1f), inactiveBorderColor)
                    }
                }
                iconView.setIcon(iconType, if (isActive) activeColor else inactiveIconColor)
                label.setTextColor(if (isActive) Color.WHITE else inactiveIconColor)
            }

            updateBtnBg()
            setPadding(dp(4f), dp(6f), dp(4f), dp(6f))
            layoutParams = LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply {
                marginStart = dp(2f)
                marginEnd = dp(2f)
            }

            addView(iconView)
            addView(label)

            setOnClickListener {
                isActive = !isActive
                updateBtnBg()
                onToggle(isActive)
            }
        }
    }

    private fun getBatteryLevel(): Int {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                val bm = getSystemService(BATTERY_SERVICE) as? BatteryManager
                val capacity = bm?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) ?: -1
                if (capacity > 0) capacity else 88
            } else {
                88
            }
        } catch (e: Exception) {
            88
        }
    }

    private var autonomousTicker: Runnable? = null

    private fun startAutonomousTicker() {
        if (autonomousTicker != null) return
        val r = object : Runnable {
            override fun run() {
                val hwFps = readHardwareOverlayFps()
                val batt = getBatteryLevel()
                pushStats(liveCpu, liveGpu, batt, hwFps)
                mainHandler.postDelayed(this, 1000)
            }
        }
        autonomousTicker = r
        mainHandler.postDelayed(r, 1000)
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
        super.onDestroy()
        stopAutonomousTicker()
        instance = null   // clear singleton
        val wm = windowManager
        collapsedHandleView?.let {
            try {
                wm?.removeView(it)
            } catch (e: Exception) {}
            collapsedHandleView = null
        }
        expandedToolboxView?.let {
            try {
                wm?.removeView(it)
            } catch (e: Exception) {}
            expandedToolboxView = null
        }
    }

    companion object {
        // Singleton reference so MainActivity can push live stats
        @Volatile private var instance: GameTurboOverlayService? = null

        fun start(context: Context, gameName: String = "Mobile Legends: Bang Bang", targetFps: Int = 120) {
            val intent = Intent(context, GameTurboOverlayService::class.java).apply {
                putExtra("EXTRA_GAME_NAME", gameName)
                putExtra("EXTRA_TARGET_FPS", targetFps)
            }
            context.startService(intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, GameTurboOverlayService::class.java)
            context.stopService(intent)
        }

        fun setPerformanceMode(isPerf: Boolean, targetFps: Int) {
            val svc = instance ?: return
            Handler(Looper.getMainLooper()).post {
                svc.isPerformanceMode = isPerf
                svc.currentTargetFps = targetFps
                svc.onModeUiUpdate?.invoke()
                svc.updateWindowPreferredRefreshRate(if (isPerf) targetFps.toFloat() else 60f)
                val displayFps = if (isPerf) targetFps else 60
                pushStats(svc.liveCpu, svc.liveGpu, svc.liveBattery, displayFps)
            }
        }

        /** Called by MainActivity's stats loop or autonomous ticker with live real-time values. */
        fun pushStats(cpu: Int, gpu: Int, battery: Int, fps: Int) {
            val svc = instance ?: return
            svc.liveCpu     = cpu
            svc.liveGpu     = gpu
            svc.liveBattery = battery
            svc.liveFps     = fps

            Handler(Looper.getMainLooper()).post {
                try {
                    val displayFps = if (fps > 0) fps else svc.currentTargetFps

                    // 1. ALWAYS update collapsed handle text if visible
                    val handleRoot = svc.collapsedHandleView as? android.view.ViewGroup
                    if (handleRoot != null) {
                        for (i in 0 until handleRoot.childCount) {
                            val child = handleRoot.getChildAt(i)
                            if (child is TextView && (child.tag == "handle_fps_text" || child.text.toString().startsWith("TURBO"))) {
                                child.text = "TURBO $displayFps FPS"
                            }
                        }
                    }

                    // 2. Update the expanded toolbox if currently visible
                    val toolboxRoot = svc.expandedToolboxView as? android.view.ViewGroup ?: return@post
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

                    (findByTag(toolboxRoot, "cpu_val") as? TextView)?.text = "${cpu}%"
                    (findByTag(toolboxRoot, "gpu_val") as? TextView)?.text = "${gpu}%"
                    (findByTag(toolboxRoot, "cpu_bar") as? TelemetryProgressBarView)?.updateProgress(
                        cpu / 100f,
                        if (svc.isPerformanceMode) Color.parseColor("#FF3B30") else Color.parseColor("#007AFF"),
                        if (svc.isPerformanceMode) Color.parseColor("#FF6961") else Color.parseColor("#60A5FA")
                    )
                    (findByTag(toolboxRoot, "gpu_bar") as? TelemetryProgressBarView)?.updateProgress(
                        gpu / 100f,
                        Color.parseColor("#8B5CF6"),
                        Color.parseColor("#C084FC")
                    )
                    // Update FPS gauge
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
                        gauge.setMode(svc.isPerformanceMode, displayFps)
                    }
                } catch (_: Exception) {}
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
    private var isPerformanceMode: Boolean = true
    private var fpsValue: Int = 120

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

    fun setMode(isPerf: Boolean, fps: Int) {
        isPerformanceMode = isPerf
        fpsValue = fps
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

        val accentColor = if (isPerformanceMode) Color.parseColor("#FF3B30") else Color.parseColor("#007AFF")
        val accentCore = if (isPerformanceMode) Color.parseColor("#FF5A5F") else Color.parseColor("#64B5F6")
        val accentGlow = Color.argb(120, Color.red(accentColor), Color.green(accentColor), Color.blue(accentColor))

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
        ringPaint.color = Color.argb(160, Color.red(accentColor), Color.green(accentColor), Color.blue(accentColor))
        ringPaint.strokeWidth = 1.2f * density
        canvas.drawCircle(cx, cy, radius - (0.6f * density), ringPaint)

        // 4. 270-degree Tachometer Sweep Arc (from 135 deg to 405 deg)
        val arcRadius = radius - (3.5f * density)
        val arcRect = RectF(cx - arcRadius, cy - arcRadius, cx + arcRadius, cy + arcRadius)
        val startAngle = 135f
        val totalSweep = 270f
        val progress = (fpsValue.toFloat() / 120f).coerceIn(0.05f, 1.0f)
        val activeSweep = totalSweep * progress

        // Track Arc (Inactive)
        val trackPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = 2.2f * density
            strokeCap = Paint.Cap.ROUND
            color = Color.parseColor("#26FFFFFF")
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
        for (i in 0 until tickCount) {
            val fraction = i.toFloat() / (tickCount - 1).toFloat()
            val angleDeg = startAngle + fraction * totalSweep
            val angleRad = Math.toRadians(angleDeg.toDouble())
            val isActive = fraction <= progress

            val tickLength = if (isActive) 4.2f * density else 2.5f * density
            val rInner = rOuter - tickLength
            tickPaint.color = if (isActive) accentColor else Color.parseColor("#4DFFFFFF")
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
        unitTextPaint.color = if (isPerformanceMode) Color.parseColor("#FF5A5F") else Color.parseColor("#389BFF")
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
    var endColor: Int = Color.parseColor("#60A5FA")
) : View(context) {

    private val bgPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.parseColor("#24FFFFFF")
        style = Paint.Style.FILL
    }

    private val fillPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        style = Paint.Style.FILL
    }

    fun updateProgress(p: Float, start: Int, end: Int) {
        progress = p
        startColor = start
        endColor = end
        invalidate()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val w = width.toFloat()
        val h = height.toFloat()
        if (w <= 0 || h <= 0) return

        val corner = h / 2f
        canvas.drawRoundRect(0f, 0f, w, h, corner, corner, bgPaint)

        val fillW = (w * progress.coerceIn(0f, 1f)).coerceAtLeast(corner * 2)
        fillPaint.shader = LinearGradient(0f, 0f, fillW, 0f, startColor, endColor, Shader.TileMode.CLAMP)
        canvas.drawRoundRect(0f, 0f, fillW, h, corner, corner, fillPaint)
    }
}
