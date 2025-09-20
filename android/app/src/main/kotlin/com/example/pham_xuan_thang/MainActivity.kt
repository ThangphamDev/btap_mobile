package com.example.pham_xuan_thang

import android.content.Intent
import android.os.Bundle
import android.provider.AlarmClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "alarm_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setAlarm" -> {
                    val hour = call.argument<Int>("hour") ?: 0
                    val minute = call.argument<Int>("minute") ?: 0
                    val message = call.argument<String>("message") ?: "Báo thức từ Pham Xuan Thang"
                    
                    try {
                        val intent = Intent(AlarmClock.ACTION_SET_ALARM).apply {
                            putExtra(AlarmClock.EXTRA_HOUR, hour)
                            putExtra(AlarmClock.EXTRA_MINUTES, minute)
                            putExtra(AlarmClock.EXTRA_MESSAGE, message)
                            putExtra(AlarmClock.EXTRA_VIBRATE, true)
                            putExtra(AlarmClock.EXTRA_SKIP_UI, false)
                        }
                        
                        if (intent.resolveActivity(packageManager) != null) {
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.error("UNAVAILABLE", "Không tìm thấy ứng dụng đồng hồ", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", "Lỗi khi đặt báo thức: ${e.message}", null)
                    }
                }
                "openClock" -> {
                    try {
                        val intent = Intent(AlarmClock.ACTION_SHOW_ALARMS)
                        if (intent.resolveActivity(packageManager) != null) {
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.error("UNAVAILABLE", "Không tìm thấy ứng dụng đồng hồ", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", "Lỗi khi mở đồng hồ: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
