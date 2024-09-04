import 'dart:developer';

import 'package:dio/dio.dart';

// Model for the FullForm data
class FullFormModel {
  final String id;
  final String fullForm;
  final String shortName;

  FullFormModel({
    required this.id,
    required this.fullForm,
    required this.shortName,
  });

  factory FullFormModel.fromJson(Map<String, dynamic> json) {
    return FullFormModel(
      id: json['_id'],
      fullForm: json['fullForm'],
      shortName: json['shortName'],
    );
  }
}

// Model for the FullForm API response
class FullFormResponse {
  final bool success;
  final String message;
  final List<FullFormModel> data;
  final int page;

  FullFormResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.page,
  });

  factory FullFormResponse.fromJson(Map<String, dynamic> json) {
    return FullFormResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => FullFormModel.fromJson(item))
          .toList(),
      page: json['page'],
    );
  }
}

// Model for the Component data
class ComponentModel {
  final String name;
  final String? icon;

  ComponentModel({
    required this.name,
    this.icon,
  });

  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    return ComponentModel(
      name: json['name'],
      icon: json['icon'],
    );
  }
}

// Model for the Component API response
class ComponentResponse {
  final bool success;
  final String message;
  final List<ComponentModel> data;

  ComponentResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ComponentResponse.fromJson(Map<String, dynamic> json) {
    return ComponentResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => ComponentModel.fromJson(item))
          .toList(),
    );
  }
}

class ComponentPartModel {
  final String id;
  final String partNo;
  final String icName;
  final String model;
  final String? thumbnail;
  final String componentBrandName;
  final String location;
  final String description;
  final String? schematicPdf;
  final DateTime createdAt;
  final DateTime updatedAt;

  ComponentPartModel({
    required this.id,
    required this.partNo,
    required this.icName,
    required this.model,
    this.thumbnail,
    required this.componentBrandName,
    required this.location,
    required this.description,
    this.schematicPdf,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComponentPartModel.fromJson(Map<String, dynamic> json) {
    return ComponentPartModel(
      id: json['_id'],
      partNo: json['partNo'],
      icName: json['icName'],
      model: json['model'],
      thumbnail: json['thumbnail'],
      componentBrandName: json['componentBrandName'],
      location: json['location'],
      description: json['description'],
      schematicPdf: json['schematicPdf'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Model for the ComponentPart API response
class ComponentPartResponse {
  final bool success;
  final String message;
  final List<ComponentPartModel> data;
  final int page;

  ComponentPartResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.page,
  });

  factory ComponentPartResponse.fromJson(Map<String, dynamic> json) {
    return ComponentPartResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => ComponentPartModel.fromJson(item))
          .toList(),
      page: json['page'],
    );
  }
}

class FullFormComponentSearchController {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.mooxy.co.in/api'));

  Future<FullFormResponse?> getFullFormResults(String query) async {
    try {
      final response = await dio.get('/getAllFullForm?shortName=$query');
      log(response.data.toString());
      return FullFormResponse.fromJson(response.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<ComponentResponse?> getComponentResults(String query) async {
    try {
      final response = await dio.get('/componentFilter?search=$query');
      log(response.data.toString());
      return ComponentResponse.fromJson(response.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<ComponentPartResponse?> getComponentPartResult(
      String query, String component) async {
    try {
      final response = await dio
          .get('/getAllComponentByComponentBrandId/$component?search=$query');
      log(response.data.toString());
      return ComponentPartResponse.fromJson(response.data);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
