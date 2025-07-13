package com.example.paylogs0

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "paylogs/share_intent"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger!!, CHANNEL).setMethodCallHandler { call, result ->
            // No Dart->Android calls needed
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleShareIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleShareIntent(intent)
    }

    private fun handleShareIntent(intent: Intent?) {
        if (intent == null) return
        if (Intent.ACTION_SEND == intent.action && intent.type != null) {
            if (intent.type!!.startsWith("image/")) {
                val imageUri = intent.getParcelableExtra<android.net.Uri>(Intent.EXTRA_STREAM)
                if (imageUri != null) {
                    val path = getPathFromUri(imageUri)
                    if (path != null) {
                        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL).invokeMethod("onImageShared", path)
                    }
                }
            }
        }
    }

    private fun getPathFromUri(uri: android.net.Uri): String? {
        // Try to get the file path from the URI
        var path: String? = null
        val projection = arrayOf(android.provider.MediaStore.Images.Media.DATA)
        val cursor = contentResolver.query(uri, projection, null, null, null)
        if (cursor != null) {
            val columnIndex = cursor.getColumnIndexOrThrow(android.provider.MediaStore.Images.Media.DATA)
            if (cursor.moveToFirst()) {
                path = cursor.getString(columnIndex)
            }
            cursor.close()
        }
        if (path == null) {
            // Fallback: try to use uri path
            path = uri.path
        }
        return path
    }
}
