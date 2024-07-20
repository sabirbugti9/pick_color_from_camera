package com.sabir.pick_color_from_camera

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull

import com.sabir.pick_color_from_camera.CameraActivity

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** ColorPickerCameraPlugin */
class ColorPickerCameraPlugin: FlutterPlugin, MethodCallHandler , ActivityAware, io.flutter.plugin.common.PluginRegistry.ActivityResultListener {


  private lateinit var channel: MethodChannel
  private lateinit var f: FlutterPlugin.FlutterPluginBinding
  var CHANNEL = "color_picker_camera"

  private var pendingResult: Result? = null
  private lateinit var context: Context
  private lateinit var activity: Activity
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    f = flutterPluginBinding


    channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL)
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${Build.VERSION.RELEASE}")
    } else if (call.method == "startNewActivity") {


      pendingResult = result
      val intent = Intent(f.applicationContext, CameraActivity::class.java)
      activity!!.startActivityForResult(intent, 666)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity;
    binding.addActivityResultListener(this);

  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (resultCode === Activity.RESULT_OK) {

      Log.i("ActivityResult", "onActivity REsult")


      var image = data?.getStringExtra("image")
      var color = data?.getStringExtra("colorCode")

      var myColor=color?.replace("#","0xff")


      pendingResult!!.success(myColor)
      return true
    }
    return false


  }
}
