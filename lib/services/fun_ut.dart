//最底層
// ignore_for_file: prefer_interpolation_to_compose_strings
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

//static class, cannot use _Fun
class FunUt {
  /// appBar pager button gap
  //static const pageBtnGap = EdgeInsets.all(15);
  ///constant
  static const systemError = "System Error, Please Contact Administrator.";

  static const select = '--請選擇--';
  static const notEmpty = '不可空白。';
  static const notZero = '不可為0';
  static const onlyNum = '只能輸入數字。';
  static const timeOut = 300; //http timeout 秒數

  //system config
  static bool logHttpUrl = false;

  //=== style start ===
  /*
  //app bar
  static double appBarFontSize = 42.0;
  static Color appBarColor = Colors.black;
  static Color appBarBgColor = Colors.orange;
  */
  
  //label、text、input
  static double textFontSize = 18.0;
  static Color labelColor = Colors.black;
  static Color textColorYes = Colors.black;
  static Color textColorNo = Colors.grey;
  static Color inputColorYes = Colors.black;
  static Color inputColorNo = Colors.grey;
  static double errorFontSize = 16.0;

  //button
  static double btnFontSize = 18.0;
  static Color? btnColorYes;
  static Color? btnColorNo;
  static Color? btnBgYes;
  static Color? btnBgNo;

  //link button
  static Color? linkBtnColorYes;
  static Color? linkBtnColorNo;

  static double fieldHeight = 45;
  static double fieldHeightLow = 35;

  ///divider height
  static double dividerH = 15;

   // HttpClient httpClient = HttpClient(context: context);

  static HttpClient? http2;
  //=== style end ===

  //label, also for inputDecoration
  static TextStyle labelStyle = TextStyle(
    fontSize: textFontSize,
    color: Colors.grey,
  );

  //label, also for inputDecoration
  static TextStyle decoreStyle = const TextStyle(
    fontSize: 15,
    color: Colors.grey,
    height: 0.8,
  );

  ///indicate error
  static const preError = 'E:';

  static int preErrorLen = preError.length;

  //#region input parameters
  /// api is https or not
  static bool isHttps = false;

  /// api server
  static String apiServer = '';
  //#endregion

  /// login status
  static bool isLogin = false;

  /// app dir
  static String dirApp = '';
  static String dirTemp = '';

  /// initial
  static Future initA(bool isHttps, String apiServer) async {
    if (FunUt.apiServer != '') return;

    FunUt.isHttps = isHttps;
    FunUt.apiServer = apiServer;

    var dir = await getApplicationDocumentsDirectory();
    dirApp = dir.path + '/';
    dirTemp = dirApp + '_temp/';
  }
} //class
