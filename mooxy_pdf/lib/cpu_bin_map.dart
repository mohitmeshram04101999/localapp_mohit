import 'package:dio/dio.dart';

class CpuBrandResponse {
  final bool success;
  final String message;
  final CpuBrandCount count;
  final List<CpuBrand> data;
  final int page;

  CpuBrandResponse({
    required this.success,
    required this.message,
    required this.count,
    required this.data,
    required this.page,
  });

  factory CpuBrandResponse.fromJson(Map<String, dynamic> json) {
    return CpuBrandResponse(
      success: json['success'],
      message: json['message'],
      count: CpuBrandCount.fromJson(json['count']),
      data: (json['data'] as List)
          .map((item) => CpuBrand.fromJson(item))
          .toList(),
      page: json['page'],
    );
  }
}

class CpuBrandCount {
  final int totalBrand;
  final int activeBrand;
  final int disablaBrand;
  final int hardwareCount;
  final int diodeCount;

  CpuBrandCount({
    required this.totalBrand,
    required this.activeBrand,
    required this.disablaBrand,
    required this.hardwareCount,
    required this.diodeCount,
  });

  factory CpuBrandCount.fromJson(Map<String, dynamic> json) {
    return CpuBrandCount(
      totalBrand: json['totalBrand'],
      activeBrand: json['activeBrand'],
      disablaBrand: json['disablaBrand'],
      hardwareCount: json['hardwareCount'],
      diodeCount: json['diodeCount'],
    );
  }
}

class CpuBrand {
  final String id;
  final String name;
  final String icon;
  final String type;
  final String? pBrand;
  final bool disable;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? v;

  CpuBrand({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.pBrand,
    required this.disable,
    required this.createdAt,
    required this.updatedAt,
    this.v,
  });

  factory CpuBrand.fromJson(Map<String, dynamic> json) {
    return CpuBrand(
      id: json['_id'],
      name: json['name'],
      icon: json['icon'],
      type: json['type'],
      pBrand: json['pBrand'],
      disable: json['disable'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      v: json['__v'],
    );
  }
}

class CpuBinMap {
  final String id;
  final String name;
  final String pdfFile;
  final DateTime createdAt;
  final DateTime updatedAt;

  CpuBinMap({
    required this.id,
    required this.name,
    required this.pdfFile,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CpuBinMap.fromJson(Map<String, dynamic> json) {
    return CpuBinMap(
      id: json['_id'],
      name: json['name'],
      pdfFile: json['pdfFile'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class CpuBinMapResponse {
  final bool success;
  final String message;
  final List<CpuBinMap> data;
  final int totalPage;

  CpuBinMapResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.totalPage,
  });

  factory CpuBinMapResponse.fromJson(Map<String, dynamic> json) {
    return CpuBinMapResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => CpuBinMap.fromJson(item))
          .toList(),
      totalPage: json['totalPage'],
    );
  }
}

class CpuBinMapController {
  final Dio _dio = Dio();

  Future<CpuBrandResponse> getCpuBrand(
      {String search = '', int page = 1}) async {
    try {
      final response = await _dio.get(
        'https://api.mooxy.co.in/api//getAllpBrand?type=CPUBINMAP',
      );

      if (response.statusCode == 200) {
        return CpuBrandResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load CPU brand data',
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Error fetching CPU brand data: ${e.message}');
      }
      throw Exception('Error fetching CPU brand data: $e');
    }
  }

  Future<CpuBinMapResponse> getCpuBinMap(String id,
      {String search = '', int page = 1}) async {
    try {
      final response = await _dio.get(
        'https://api.mooxy.co.in/api/getCpuBinMapByCpuId?brandId=$id',
      );

      if (response.statusCode == 200) {
        return CpuBinMapResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to load CPU bin map data',
        );
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Error fetching CPU bin map data: ${e.message}');
      }
      throw Exception('Error fetching CPU bin map data: $e');
    }
  }
}
