package com.spectrumveil.dogsafield.plugin

import android.app.Activity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class AzureLivenessPlugin(private val activity: Activity) :
    MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL = "com.dogsafield.dogsafield/azure_liveness"

        fun registerWith(flutterEngine: FlutterEngine, activity: Activity) {
            val channel = MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger,
                CHANNEL
            )
            channel.setMethodCallHandler(AzureLivenessPlugin(activity))
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startLivenessSession" -> {
                val authToken = call.argument<String>("authToken")
                if (authToken == null) {
                    result.error("INVALID_ARGS", "authToken is required", null)
                    return
                }
                startLivenessSession(authToken, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun startLivenessSession(authToken: String, result: MethodChannel.Result) {
        result.success(authToken)
    }
}
