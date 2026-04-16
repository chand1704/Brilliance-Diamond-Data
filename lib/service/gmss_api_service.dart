import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../model/gmss_stone_model.dart';

class GmssApiService {
  static const String baseUrl =
      'https://excellent.kodllin.com/apis/api/getStockN';
  static const String currentAuthKey = 'tc682t5vocwa';

  static Future<List<GmssStone>> _fetchDiamondData({
    String? shapeName,
    required bool isLab,
    int page = 1,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'auth_key': currentAuthKey,
        'page': page.toString(),
        'per-page': '50',
      };

      if (shapeName != null && shapeName.toUpperCase() != "OTHER") {
        queryParams['shape'] = shapeName.toUpperCase();
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      debugPrint("Requesting URL: $uri");

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> dataList = decoded is List ? decoded : decoded['data'];
        // ? decoded
        // : (decoded['data'] ?? []);

        return dataList
            .map((item) {
              try {
                return GmssStone.fromJson(item, isLab: isLab);
              } catch (e) {
                return null;
              }
            })
            .whereType<GmssStone>()
            .toList();
        // dataList
        //   .map((e) => GmssStone.fromJson(e, isLab: isLab))
        //   .toList();
      }
    } catch (e) {
      debugPrint("GmssApiService Exception: $e");
    }
    return [];
  }

  static Future<List<GmssStone>> fetchLabGrownData({
    String? shapeName,
    int page = 1,
  }) async {
    return _fetchDiamondData(shapeName: shapeName, isLab: true, page: page);
  }

  static Future<List<GmssStone>> fetchNaturalData({
    String? shapeName,
    int page = 1,
  }) async {
    return _fetchDiamondData(shapeName: shapeName, isLab: false, page: page);
  }
}
