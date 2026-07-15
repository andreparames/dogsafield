package com.spectrumveil.dogsafield

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.spectrumveil.dogsafield.plugin.AzureLivenessPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AzureLivenessPlugin.registerWith(flutterEngine, this)
    }
}
