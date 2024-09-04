import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mooxy_pdf/providers.dart';

class BannerResponse {
  final bool success;
  final String message;
  final BannerData data;

  BannerResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      success: json['success'],
      message: json['message'],
      data: BannerData.fromJson(json['data']),
    );
  }
}

class BannerData {
  final String id;
  final String type;
  final List<String> banner;

  BannerData({
    required this.id,
    required this.type,
    required this.banner,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      id: json['_id'],
      type: json['type'],
      banner: List<String>.from(json['banner']),
    );
  }
}

class HomePageBanners extends StatefulWidget {
  const HomePageBanners({Key? key}) : super(key: key);

  @override
  State<HomePageBanners> createState() => _HomePageBannersState();
}

class _HomePageBannersState extends State<HomePageBanners> {
  late Future<BannerResponse> _bannersFuture;

  @override
  void initState() {
    super.initState();
    _bannersFuture = fetchBanners();
  }

  Future<BannerResponse> fetchBanners() async {
    final response = await http.get(Uri.parse(
        'https://api.mooxy.co.in/api/desktop/getBanners?type=homeBanner'));

    if (response.statusCode == 200) {
      return BannerResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load banners');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BannerResponse>(
      future: _bannersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.data.banner.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: AspectRatio(
                  aspectRatio: 16 / 5,
                  child: Image.network(
                    AppStateProviders.prifixUrl +
                        snapshot.data!.data.banner[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
