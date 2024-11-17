import 'dart:io';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class ImageUt {

  /// reload image
  /// flutter image has cache issue !!
  static Image reload(String path){
    var file = File(path);
    var bytes = file.readAsBytesSync();
    return Image.memory(bytes);
  }  

  static Future<Image> reloadAssetA(String path) async {
    var byteData = await rootBundle.load(path); //load sound from assets
    return Image.memory(byteData.buffer.asUint8List());
  }  

  //repaintBoundary to image file
  static Future<void> repaintToImageA(GlobalKey key, String toPath) async{
    //固定寫法
    var boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    var image = await boundary?.toImage();
    var byteData = await image?.toByteData(format: ImageByteFormat.png);  //png only
    var bytes = byteData?.buffer.asUint8List();

    if (bytes != null) {
      var imageFile = await File(toPath).create();
      await imageFile.writeAsBytes(bytes);
    }
  }

  //save image Uint8List to file(overwrited)
  static Future<File> bytesToFileA(Uint8List bytes, String toPath) async{
    return await File(toPath).writeAsBytes(bytes);
  }

} //class
