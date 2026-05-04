package com.rutexgo.mobile_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "rutexgo/api_keys"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "googleDirectionsApiKey" -> result.success(BuildConfig.GOOGLE_DIRECTIONS_API_KEY)
                else -> result.notImplemented()
            }
        }
    }
}
