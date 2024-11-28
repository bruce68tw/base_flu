import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path; //or will conflict
import 'fun_ut.dart';
import 'str_ut.dart';

//static class for file & directory
class FileUt {
  //check file existed under app folder
  static bool exist(String filePath) {
    return File(filePath).existsSync();
  }

  /*
  static bool dirExist(String dirPath) {
    return Directory(dirPath).existsSync();
  }
  */

  //dirPath: no tail '/'
  static bool dirExist(String dirPath) {
    return Directory(dirPath).existsSync();
  }

  //create folder if not exists
  //dirPath: no tail '/'
  static void createDir(String dirPath) {
    var dir = Directory(dirPath);
    if (!dir.existsSync()) dir.createSync(recursive: true);
  }

  ///目錄是否存在 fileStem
  ///@param fullMatch true(檔名完全相同), false(部分相同)
  static bool dirHasFileStem(String dirPath, String fileStem, bool fullMatch) {
    var dir = Directory(dirPath);
    if (dir.existsSync()) {
      return fullMatch 
        ? dir.listSync().any((a) => a is File && path.basename(a.path) == fileStem)
        : dir.listSync().any((a) => a is File && path.basename(a.path).contains(fileStem));
    } else {
      try {
        dir.createSync(recursive: true);
      } catch (e) {
        var aa='aa';
      }
      //todo
      return false;
    }
  }

  ///目錄是否存在 fileStem
  ///@param fullMatch true(檔名完全相同), false(部分相同)
  static FileSystemEntity? dirGetFileByStem(String dirPath, String fileStem, bool fullMatch) {
    var dir = Directory(dirPath);
    if (dir.existsSync()) {
      return fullMatch 
        ? dir.listSync().firstWhere((a) => a is File && path.basename(a.path) == fileStem)
        : dir.listSync().firstWhere((a) => a is File && path.basename(a.path).contains(fileStem));
    } else {
      return null;
    }
  }

  //await _appDocDirFolder.create(recursive: true);

  /*
  static Future<String> getAppDir() async {
    var dir = await getApplicationDocumentsDirectory();
    return dir.path + '/';
  }

  static Future<String> getInfoPath() async {
    return await FileHp.getFilePath(FunHp.infoFile);
  }
  */

  static String getFilePath(String fileName) {
    return FunUt.dirApp + fileName;
  }

  static String getName(String filePath) {
    return path.basename(filePath);
  }

  static String getStem(String filePath) {
    var fileName = path.basename(filePath);
    var pos = fileName.lastIndexOf('.');
    return (pos < 0) ? fileName : fileName.substring(0, pos);
  }

  /// get file extension in lowercase  without '.'
  static String getExt(String filePath) {
    var pos = filePath.lastIndexOf('.');
    return (pos < 0) ? '' : filePath.substring(pos + 1).toLowerCase();
  }

  ///json to image file ext
  static String jsonToImageExt(Map<String, dynamic>? json,
      [String fid = 'FileName']) {
    if (json == null || StrUt.isEmpty(json[fid])) return '';

    String fileName = json[fid];
    var pos = fileName.indexOf('.');
    return (pos < 0) ? '' : fileName.substring(pos + 1);
  }

  /// delete files in directory
  static deleteDirFiles(String dirPath) {
    var dir = Directory(dirPath);
    if (!dir.existsSync()) return;

    var files = dir.listSync();
    for (var file in files) {
      file.deleteSync();
    }
  }

  static deleteDir(String dirPath) {
    var dir = Directory(dirPath);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }

  static renameDir(String fromDir, String toDir) {
    var dirFrom = Directory(fromDir);
    dirFrom.rename(toDir);
  }

  /// zip files of folder (into temp folder)
  /// return file list, empty if no files
  static List<String>? zipDir(String fromDir, String toPath) {
    if (!FileUt.dirExist(fromDir)) return null;

    var files = Directory(fromDir).listSync();
    if (files.isEmpty) return null;

    //var toPath = FunUt.dirTemp + getDirName(fromDir) + '.zip';
    var encoder = ZipFileEncoder();
    encoder.create(toPath);

    List<String> result = [];
    for (var file in files) {
      //var path = file.path;
      encoder.addFile(File(file.path));
      result.add(path.basename(file.path));
    }
    encoder.close();
    return result;
  }

  static String getDirName(String dir) {
    var len = dir.length;
    if (dir.substring(len - 1) == '/') {
      dir = dir.substring(0, len - 1);
    }
    var pos = dir.lastIndexOf('/');
    return (pos < 0) ? dir : dir.substring(pos + 1);
  }
} //class
