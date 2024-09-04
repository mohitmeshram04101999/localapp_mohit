import 'dart:developer';

import 'package:dio/dio.dart';

class FlashFileModel {
  final String id;
  final String name;
  final String? icon;
  final String? pFlashFiles;
  final bool disable;
  final DateTime createdAt;
  final DateTime updatedAt;

  FlashFileModel({
    required this.id,
    required this.name,
    this.icon,
    this.pFlashFiles,
    required this.disable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FlashFileModel.fromJson(Map<String, dynamic> json) {
    return FlashFileModel(
      id: json['_id'],
      name: json['name'],
      icon: json['icon'],
      pFlashFiles: json['pFlashFiles'],
      disable: json['disable'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class FlashFilesResponse {
  final bool success;
  final String message;
  final List<FlashFileModel> data;
  final List<FlashFilePdfModel>? flashFilesPdf;
  final int? page;

  FlashFilesResponse({
    required this.success,
    required this.message,
    required this.data,
    this.flashFilesPdf,
    this.page,
  });

  factory FlashFilesResponse.fromJson(Map<String, dynamic> json) {
    return FlashFilesResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => FlashFileModel.fromJson(item))
          .toList(),
      flashFilesPdf: json['flashFilesPdf'] != null
          ? (json['flashFilesPdf'] as List)
              .map((item) => FlashFilePdfModel.fromJson(item))
              .toList()
          : null,
      page: json['page'],
    );
  }
}

class FlashFilePdfModel {
  final String id;
  final String flashFiles;
  final String name;
  final String fileLink;
  final String? icon;

  FlashFilePdfModel({
    required this.id,
    required this.flashFiles,
    required this.name,
    required this.fileLink,
    this.icon,
  });

  factory FlashFilePdfModel.fromJson(Map<String, dynamic> json) {
    return FlashFilePdfModel(
      id: json['_id'],
      flashFiles: json['flashFiles'],
      name: json['name'],
      fileLink: json['fileLink'],
      icon: json['icon'],
    );
  }
}

class DailyUpdateResponse {
  final bool success;
  final String message;
  final List<DailyUpdate> data;

  DailyUpdateResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DailyUpdateResponse.fromJson(Map<String, dynamic> json) {
    return DailyUpdateResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => DailyUpdate.fromJson(item))
          .toList(),
    );
  }
}

class DailyUpdate {
  final String id;
  final String message;
  final String image;
  final bool disable;
  final bool latestUpdates;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  DailyUpdate({
    required this.id,
    required this.message,
    required this.image,
    required this.disable,
    required this.latestUpdates,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory DailyUpdate.fromJson(Map<String, dynamic> json) {
    return DailyUpdate(
      id: json['_id'],
      message: json['message'],
      image: json['image'],
      disable: json['disable'],
      latestUpdates: json['latestUpdates'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }
}

class FlashFilesController {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.mooxy.co.in/api/'));

  Future<FlashFilesResponse?> getAllParentFlashFiles() async {
    try {
      final response = await dio.get('getAllpFlashFiles?disable=false&page=1');
      if (response.statusCode == 200) {
        log(response.data.toString());
        return FlashFilesResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch parent flash files');
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<FlashFilesResponse?> getAllChildFlashFiles(String pFileId) async {
    try {
      final response = await dio.get(
          'getAllSubFlashFilesBypFlashFiles?pFlashFiles=$pFileId&disable=false');
      if (response.statusCode == 200) {
        log(response.data.toString());
        return FlashFilesResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch child flash files');
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  Future<DailyUpdateResponse?> getAllDailyUpdate() async {
    try {
      final response = await dio.get('/getAllDailyUpdate');
      if (response.statusCode == 200) {
        // log(response.data.toString());
        return DailyUpdateResponse.fromJson(response.data);
      } else {
        throw Exception('Something went wrong!');
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }

  postQuery({
    required String query,
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      final response = await dio.post('createQueryGenarate', data: {
        'query': query,
        'userId': userId,
        'name': name,
        'email': email,
      });
      if (response.statusCode == 201) {
        log(response.data.toString());
        return response.data;
      } else {
        log(response.data.toString());
        throw Exception('Something went wrong!');
      }
    } catch (e) {
      log(e.toString());
      return null;
    }
  }
}
