package com.example.game_live_platform

import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    
    // Method channel for native communication
    private val CHANNEL = "com.example.game_live_platform/native"
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        
        // Setup method channel for platform-specific functionality
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getDeviceInfo" -> {
                        result.success(getDeviceInfo())
                    }
                    "setFullScreen" -> {
                        val isFullScreen = call.argument<Boolean>("isFullScreen") ?: false
                        setFullScreen(isFullScreen)
                        result.success(null)
                    }
                    "getBatteryLevel" -> {
                        result.success(getBatteryLevel())
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Make the app fullscreen with transparent navigation bar
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
            window.insetsController?.hide(android.view.WindowInsets.Type.navigationBars())
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_FULLSCREEN
                or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
            )
        }
        
        // Keep screen on for video/live content
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
    
    private fun getDeviceInfo(): Map<String, Any> {
        return mapOf(
            "model" to Build.MODEL,
            "brand" to Build.BRAND,
            "manufacturer" to Build.MANUFACTURER,
            "version" to Build.VERSION.RELEASE,
            "sdkInt" to Build.VERSION.SDK_INT,
            "device" to Build.DEVICE,
            "product" to Build.PRODUCT,
            "display" to Build.DISPLAY,
            "hardware" to Build.HARDWARE,
            "board" to Build.BOARD,
            "bootloader" to Build.BOOTLOADER,
            "fingerprint" to Build.FINGERPRINT,
            "host" to Build.HOST,
            "id" to Build.ID,
            "tags" to Build.TAGS,
            "time" to Build.TIME,
            "type" to Build.TYPE,
            "user" to Build.USER
        )
    }
    
    private fun getBatteryLevel(): Int {
        val batteryLevel = with(context) {
            val batteryManager = getSystemService(android.content.Context.BATTERY_SERVICE) as android.os.BatteryManager
            batteryManager.getIntProperty(android.os.BatteryManager.BATTERY_PROPERTY_CAPACITY)
        }
        return batteryLevel
    }
    
    private fun setFullScreen(isFullScreen: Boolean) {
        runOnUiThread {
            if (isFullScreen) {
                // Hide system UI for full screen mode
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    window.setDecorFitsSystemWindows(false)
                    window.insetsController?.hide(android.view.WindowInsets.Type.navigationBars())
                    window.insetsController?.hide(android.view.WindowInsets.Type.statusBars())
                } else {
                    @Suppress("DEPRECATION")
                    window.decorView.systemUiVisibility = (
                        View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                        or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                        or View.SYSTEM_UI_FLAG_FULLSCREEN
                        or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    )
                }
            } else {
                // Show system UI for normal mode
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    window.setDecorFitsSystemWindows(true)
                    window.insetsController?.show(android.view.WindowInsets.Type.navigationBars())
                    window.insetsController?.show(android.view.WindowInsets.Type.statusBars())
                } else {
                    @Suppress("DEPRECATION")
                    window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
                }
            }
        }
    }
    
    override fun onBackPressed() {
        // Handle back press for Flutter
        if (!isFinishing) {
            moveTaskToBack(false)
        }
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        // Handle permission results here if needed
    }
}