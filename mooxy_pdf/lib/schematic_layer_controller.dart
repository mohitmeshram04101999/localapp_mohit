import 'dart:developer';

import 'package:dio/dio.dart';

class BrandResponse {
  final bool success;
  final String message;
  final CountInfo count;
  final List<Brand> data;

  BrandResponse({
    required this.success,
    required this.message,
    required this.count,
    required this.data,
  });

  factory BrandResponse.fromJson(Map<String, dynamic> json) {
    return BrandResponse(
      success: json['success'],
      message: json['message'],
      count: CountInfo.fromJson(json['count']),
      data: (json['data'] as List).map((item) => Brand.fromJson(item)).toList(),
    );
  }
}

class CountInfo {
  final int totalBrand;
  final int activeBrand;
  final int disablaBrand;
  final int hardwareCount;
  final int diodeCount;

  CountInfo({
    required this.totalBrand,
    required this.activeBrand,
    required this.disablaBrand,
    required this.hardwareCount,
    required this.diodeCount,
  });

  factory CountInfo.fromJson(Map<String, dynamic> json) {
    return CountInfo(
      totalBrand: json['totalBrand'],
      activeBrand: json['activeBrand'],
      disablaBrand: json['disablaBrand'],
      hardwareCount: json['hardwareCount'],
      diodeCount: json['diodeCount'],
    );
  }
}

class Brand {
  final String id;
  final String name;
  final String icon;
  final String type;
  final dynamic pBrand;
  final bool disable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Brand({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.pBrand,
    required this.disable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'],
      name: json['name'],
      icon: json['icon'],
      type: json['type'],
      pBrand: json['pBrand'],
      disable: json['disable'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class SubBrandResponse {
  final bool success;
  final String message;
  final List<SubBrand> data;
  final List<dynamic> pdfData;
  final int page;

  SubBrandResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pdfData,
    required this.page,
  });

  factory SubBrandResponse.fromJson(Map<String, dynamic> json) {
    return SubBrandResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => SubBrand.fromJson(item))
          .toList(),
      pdfData: json['pdfData'],
      page: json['page'],
    );
  }
}

class SubBrand {
  final String id;
  final String name;
  final String icon;
  final String type;
  final String pBrand;
  final bool disable;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubBrand({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    required this.pBrand,
    required this.disable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubBrand.fromJson(Map<String, dynamic> json) {
    return SubBrand(
      id: json['_id'],
      name: json['name'],
      icon: json['icon'],
      type: json['type'],
      pBrand: json['pBrand'],
      disable: json['disable'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class SchematicPdfResponse {
  final bool success;
  final String message;
  final List<SchematicPdf> data;

  SchematicPdfResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SchematicPdfResponse.fromJson(Map<String, dynamic> json) {
    return SchematicPdfResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => SchematicPdf.fromJson(item))
          .toList(),
    );
  }
}

class SchematicPdf {
  final String id;
  final String brandId;
  final List<String?> pdfFile;
  final DateTime createdAt;
  final DateTime updatedAt;

  SchematicPdf({
    required this.id,
    required this.brandId,
    required this.pdfFile,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SchematicPdf.fromJson(Map<String, dynamic> json) {
    return SchematicPdf(
      id: json['_id'],
      brandId: json['brandId'],
      pdfFile:
          (json['pdfFile'] as List).map((item) => item as String?).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class SchematicLayerAppControllers {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.mooxy.co.in'));

  Future<BrandResponse> getAllSchematicLayerBrands() async {
    try {
      final response = await dio.request(
        '/api/getAllpBrand?type=SCHEMATIC&name=&disable=false&page=1',
        options: Options(method: 'GET'),
      );

      if (response.statusCode == 200) {
        // log("SCHEMATIC BRANDS: ${response.data}");
        return BrandResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Unexpected status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching brands: $e');
      rethrow;
    }
  }

  Future<SubBrandResponse> getAllSubBrandsByPBrand(String pBrandId) async {
    try {
      final response = await dio.request(
        '/api/getAllSubBrandBypBrand?pBrandId=$pBrandId&type=SCHEMATIC&search=',
        options: Options(method: 'GET'),
      );

      if (response.statusCode == 200) {
        // log("SCHEMATIC SUB BRANDS: ${response.data}");
        return SubBrandResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Unexpected status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching sub-brands: $e');
      rethrow;
    }
  }

  Future<SchematicPdfResponse> getAllSubSubBrandsByPBrand(
      String pBrandId) async {
    try {
      final response = await dio.request(
        '/api/SchematicLayer/getAllPdfByBrandId/$pBrandId',
        options: Options(method: 'GET'),
      );
      log(response.data.toString());
      if (response.statusCode == 200) {
        log("SCHEMATIC SUB SUB BRANDS: ${response.data}");
        return SchematicPdfResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Unexpected status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching schematic PDFs: $e');
      rethrow;
    }
  }
}
