import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PickColorFromCamera {
  static const MethodChannel _channel = MethodChannel('color_picker_camera');

  static Future<String?> pickColor() async {
    try {
      if (await Permission.camera.request().isGranted) {
        var result = await _channel.invokeMethod('startNewActivity');
        return result;
      } else {
        throw "Permission not granted";
      }
    } on PlatformException catch (e) {
      throw e.message!;
    } catch (e) {
      throw e.toString();
    }
  }
}
