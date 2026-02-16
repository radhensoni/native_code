package com.example.native_code

import android.os.VibrationEffect
import android.os.Vibrator
import android.os.Build
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.native_code/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "vibrate" -> {
                        val pattern = call.argument<List<Int>>("pattern")
                        if (pattern != null) {
                            val success = vibrateWithPattern(pattern)
                            result.success(success)
                        } else {
                            result.error("INVALID_PATTERN", "Pattern is null", null)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun vibrateWithPattern(pattern: List<Int>): Boolean {
        return try {
            val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            
            // Check if device has vibrator
            if (!vibrator.hasVibrator()) {
                return false
            }

            val longPattern = pattern.map { it.toLong() }.toLongArray()
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // For Android 8.0 and above
                vibrator.vibrate(
                    VibrationEffect.createWaveform(longPattern, -1)
                )
            } else {
                // For older versions
                @Suppress("DEPRECATION")
                vibrator.vibrate(longPattern, -1)
            }
            
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}