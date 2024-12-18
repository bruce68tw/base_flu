//import 'dart:developer';
import 'package:flutter/material.dart';
import 'log_ut.dart';

//static class, cannot use _Fun
//waiting & message 不可同時顯示!!
class ToolUt {
  //目前是否顯示waiting
  static bool _isWaiting = false;
  //static BuildContext? _waitCnt;

  //show msg box
  static void msg(BuildContext? context, String info, [Function? fnOk]) {
    if (context == null){
      LogUt.error(info);
      return;
    }

    //close wait first if need
    closeWait(context);

    // set up the button
    var okBtn = TextButton(
      child: const Text('OK'),
      onPressed: (){
        Navigator.pop(context);
        if (fnOk != null){
          fnOk();
        } 
    });

    // set up the AlertDialog
    var dialog = AlertDialog(
      //title: Text('My title'),
      content: Text(info),
      actions: [
        okBtn,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context2) {
        return dialog;
      },
    );
  }

  //show msg box
  static void ans(BuildContext? context, String info, [Function? onYes]) {
    if (context == null) return;
    
    //close waiting first
    closeWait(context);

    // set up the button
    var okBtn = TextButton(
      child: const Text('Yes'),
      onPressed: () {
        closeForm(context);
        if (onYes != null) onYes();
      },
    );
    var cancelBtn = TextButton(
      child: const Text('No'),
      onPressed: () => Navigator.pop(context),
    );

    // set up the AlertDialog
    var alert = AlertDialog(
      content: Text(info),
      actions: [
        okBtn,
        cancelBtn,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  //open waiting msg
  static void openWait(BuildContext? context) {
    if (context == null) return;

    //set global
    _isWaiting = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context2) {
        //_waitCnt = context2;  //set global
        return Dialog(
          child: Container(
            width: 150,
            height: 70,
            padding: const EdgeInsets.all(10),
            child: const ListTile(
              horizontalTitleGap: 20,
              leading: CircularProgressIndicator(),
              title: Text('Working...'),
            ),
          ),
        );
      },
    );
  }

  //close waiting msg
  static void closeWait(BuildContext? context) {
    if (context == null || !_isWaiting) return;

    _isWaiting = false; //reset
    //_waitCnt == null;
    Navigator.of(context, rootNavigator: true).pop(context);
    //closeForm(_waitCnt!);
  }

  //close popup
  static void closeForm(BuildContext? context) {
    if (context == null) return;
    Navigator.pop(context);
  }

  //close popup and return msg
  static void closeFormMsg(BuildContext? context, String msg) {
    if (context == null) return;
    Navigator.pop(context, msg);
  }

  ///open form, 子畫面可以使用WillPopScope+Navigator.pop來傳回值<br>
  ///@replace true 表示開啟後關閉本身視窗
  static Future<dynamic> openFormA(BuildContext? context, Widget form, [bool replace = false]) async {
    if (context == null) return null;

    //close waiting first
    closeWait(context);

    if (replace){
      return await Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context2) => form),
      );
    } else {
      return await Navigator.push(context,
        MaterialPageRoute(builder: (context2) => form),
      );
    }
  }

  /*
  ///open form & show msg
  static Future<String> openFormMsgA(BuildContext context, Widget form) async {
    //close waiting first
    closeWait(context);

    var msg = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => form)
    );
    return (msg == null) ? '' : msg.toString();
  }
  */
  
  static Future<void> openInputA(BuildContext context, String title, Function fnOnOk) async {
    var ctrl = TextEditingController();
    return showDialog(
      context: context,
      builder: (context2) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: ctrl,
            //decoration: InputDecoration(hintText: "Text Field in Dialog"),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                var text = ctrl.text;
                if (text != ''){
                  closeForm(context2);
                  fnOnOk(text);
                }
    })]);});
  }

  /*
  static void openModal(BuildContext context, Widget form, [bool replace = false]) {
    if (context == null) return;
    if (replace){
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => form),
      );
    } else {
      Navigator.push(context,
        MaterialPageRoute(builder: (context) => form),
      );
    }
  }
  */
  
} //class
