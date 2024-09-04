import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class FileModel {
  FileInfo fileInfo;
  String key;
  FileModel({
    required this.fileInfo,
    required this.key,
  });
  Map<String, dynamic> toMap() {
    return {
      'fileInfo': this.fileInfo,
      'key': this.key,
    };
  }

  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      fileInfo: map['fileInfo'] as FileInfo,
      key: map['key'] as String,
    );
  }
}
