// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'fun_ut.dart';
import 'log_ut.dart';
import 'str_ut.dart';
import 'tool_ut.dart'; //need !!

//static class
class HttpUt {
  /// jwt token
  static String _token = '';

  static void setToken(String token) {
    _token = token;
    FunUt.isLogin = true;
  }

  /*
   get api uri
   @param json 傳入資料, 格式為 Map<String, dynamic>?
  */
  static Uri _apiUri(String action, [Map<String, dynamic>? json]) {
    if (FunUt.logHttpUrl) {
      LogUt.info(FunUt.apiServer + '/' + action);
    }

    return FunUt.isHttps
        ? Uri.https(FunUt.apiServer, action, json)
        : Uri.http(FunUt.apiServer, action, json);
  }

  //get url string
  //param action : no left slash
  static String getUrl(String action) {
    return (FunUt.isHttps ? 'https://' : 'http://') +
        FunUt.apiServer +
        '/' +
        action;
  }

  /// get str
  /// if jsonArg=false, json must be <String, String> !!
  static Future<void> getStrA(BuildContext context, String action, bool jsonArg,
      Map<String, dynamic> json, Function fnOk,
      [File? file, bool showWait = true]) async {
    await _checkRespResultA(
        context, action, jsonArg, false, json, fnOk, file, showWait);
  }

  //可傳回json或jarray
  static Future<void> getJsonA(BuildContext context, String action,
      bool jsonArg, Map<String, dynamic> json, Function fnOk,
      {File? file, bool showWait = true}) async {
    await _checkRespResultA(
        context, action, jsonArg, true, json, fnOk, file, showWait);
  }

  static Future<Image?> getImageA(
      BuildContext context, String action, Map<String, String> json,
      [bool showWait = true]) async {
    var resp = await _getRespA(context, action, false, json, null, showWait);
    //檢查回傳image是否有效
    //後端return null時, bytes length < 10000(暫時 !!)
    return (resp == null || resp.bodyBytes.length < 10000)
        ? null
        : Image.memory(resp.bodyBytes);
  }

  static Future<void> uploadZipA(BuildContext context, String action,
      File? file, Map<String, dynamic> json, bool jsonOut, Function fnOk,
      [bool showWait = true]) async {
    await _checkRespResultA(
        context, action, false, jsonOut, json, fnOk, file, showWait);
  }

  /// download and unzip
  /// @param json 後端傳入參數
  static Future saveUnzipA(BuildContext context, String action,
      Map<String, String> json, String dirSave) async {
    //create folder if need
    var dir = Directory(dirSave);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    //if no file, download it
    var bytes = await _getFileBytesA(context, action, json);
    if (bytes != null) {
      var files = ZipDecoder().decodeBytes(bytes);
      var dirBase = dir.path + '/';
      for (var file in files) {
        //..cascade operator
        File(dirBase + file.name)
          ..createSync()
          ..writeAsBytesSync(file.content as List<int>, flush: true);
      }
    }
  }

  static Future<Uint8List?> _getFileBytesA(BuildContext? context, String action,
      [Map<String, String>? json]) async {
    var resp = await _getRespA(context, action, false, json);
    return (resp == null) ? null : resp.bodyBytes;
  }

  ///get response
  ///called by: _rpcAsync, getFileBytesAsync
  ///file不為空白時, jsonArg必須為false, 因為後端無法以object接受參數
  static Future<http.Response?> _getRespA(BuildContext? context, String action,
      [bool jsonArg = false,
      Map<String, dynamic>? json,
      File? file,
      bool showWait = true]) async {
    String body = '';
    String conType;
    Map<String, dynamic>? arg;
    //1.set content type
    if (jsonArg) {
      body = (json == null) ? '' : jsonEncode(json);
      conType = 'application/json';
    } else {
      conType = 'plain/text';
      arg = json; //as query string
    }
    var headers = {
      'Content-Type': conType + '; charset=utf-8',
      //'Access-Control-Allow-Origin': '*',
      //'Cache-Control': 'no-cache',
    };

    //2.add token if existed
    if (StrUt.notEmpty(_token)) headers['Authorization'] = 'Bearer ' + _token;

    //3.show waiting
    if (showWait) ToolUt.openWait(context);

    //4.http request
    http.Response? resp;
    try {
      if (file == null) {
        resp = await http
            .post(_apiUri(action, arg), headers: headers, body: body)
            .timeout(const Duration(seconds: FunUt.timeOut));
      } else {
        var request = http.MultipartRequest('POST', _apiUri(action, arg));
        request.headers.addAll(headers);

        //add text fields
        var file2 = await http.MultipartFile.fromPath('file', file.path,
            contentType: MediaType('zip', 'applicaiton/zip'));

        request.files.add(file2);
        var stream = await request.send();
        resp = await http.Response.fromStream(stream);
      }
      /*
    } on TimeoutException {
      log('Error: 連線時間超過20秒。');
      return null;
    */
    } catch (e) {
      LogUt.error(e.toString());
      //} finally {
    }

    //close waiting
    if (showWait) ToolUt.closeWait(context);
    return resp;
  }

  //get response result
  static Future<void> _checkRespResultA(BuildContext context, String action,
      bool jsonArg, bool jsonOut, Map<String, dynamic> json, Function fnOk,
      [File? file, bool showWait = true]) async {
    //get response & check error
    var resp = await _getRespA(context, action, jsonArg, json, file, showWait);
    if (resp == null) {
      ToolUt.msg(context, '無法存取遠端主機 !!');
      return;
    } else if (resp.statusCode == 401) {
      ToolUt.msg(context, '因為長時間閒置, 系統已經離線, 請重新執行這個程式。');
      return;
    } else if (resp.statusCode >= 400) {
      ToolUt.msg(context, 'Error: ${resp.reasonPhrase}!(${resp.statusCode})');
      return;
    }

    //show error msg if any
    var str = utf8.decode(resp.bodyBytes);
    dynamic json2;
    var error = '';
    if (jsonOut) {
      json2 = StrUt.toJson2(str, showLog: false);
      //若為陣列表示後端傳回多筆
      if (json2 is! List) {
        error = (json2 == null) ? _getStrError(str) : _getJsonError(json2);
      }
    } else {
      error = _getStrError(str);
    }

    if (error != '') {
      ToolUt.msg(context, error);
      return;
    }

    //callback, fnOk可為同步/非同步函數, 這裡一律使用await呼叫流程才不會異常(都不會error)
    await fnOk(jsonOut ? json2 : str);
  }

  ///result to error msg
  static String _getJsonError(dynamic result) {
    return (result['ErrorMsg'] == null) ? '' : result['ErrorMsg'];
  }

  ///string to error msg
  static String _getStrError(String str) {
    return (StrUt.notEmpty(str) &&
            str.length > FunUt.preErrorLen &&
            str.substring(0, FunUt.preErrorLen) == FunUt.preError)
        ? str.substring(FunUt.preErrorLen)
        : '';
  }

  /*
  //get public ip address
  static Future<String> getIp() async {
    if (isDev)
      return ':::1';

    var uri = Uri.https('api.ipify.org', '');
    var response = await http.get(uri);
    return (response.statusCode == 200)
        ? response.body
        : '';
  }
  */
} //class
