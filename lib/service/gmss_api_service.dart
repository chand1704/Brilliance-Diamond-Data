import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/gmss_stone_model.dart';

class _DecodeParams {
  final String jsonString;
  final bool isLab;
  _DecodeParams(this.jsonString, this.isLab);
}

Map<String, dynamic> _decodeAndParseJson(_DecodeParams params) {
  final decoded = jsonDecode(params.jsonString);
  List<dynamic> dataList = [];
  int totalFromApi = 0;
  if (decoded is Map) {
    dataList = decoded['data'] ?? [];
    totalFromApi = int.tryParse(decoded['total']?.toString() ?? '') ?? 0;
  } else if (decoded is List) {
    dataList = decoded;
    totalFromApi = dataList.length;
  }
  final stones = dataList
      .map((item) {
        try {
          return GmssStone.fromJson(item, isLab: params.isLab);
        } catch (e) {
          return null;
        }
      })
      .whereType<GmssStone>()
      .toList();
  return {'stones': stones, 'total': totalFromApi};
}

class GmssApiService {
  static const String baseUrl =
      'https://excellent.kodllin.com/apis/api/getStockN';
  static const String labAuthKey = 'tc682t5vocwa';
  static const String naturalAuthKey = 'jm4hzizpfvs0';
  static Future<Map<String, dynamic>> _fetchDiamondData({
    String? shapeName,
    required bool isLab,
    required String authKey,
    int page = 1,
    int perPage = 5000,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'auth_key': authKey,
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      if (shapeName != null && shapeName.toUpperCase() != "ALL") {
        String upper = shapeName.toUpperCase().trim();
        // Smart mapping for API compatibility
        if (upper == "SQ RADIANT") {
          queryParams['shape'] = "RADIANT";
        } else if (upper == "SQ EMERALD") {
          queryParams['shape'] = "EMERALD";
        } else if (upper == "ROSE") {
          queryParams['shape'] = "ROSE";
        } else {
          queryParams['shape'] = upper;
        }
      }
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      // Reverted to POST as the server returned 405 for GET
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        try {
          final result = await compute(
            _decodeAndParseJson,
            _DecodeParams(response.body, isLab),
          );
          return result;
        } catch (e) {
          return {'stones': <GmssStone>[], 'total': 0};
        }
      } else {
      }
    } catch (e) {
    }
    return {'stones': <GmssStone>[], 'total': 0};
  }

  static Future<Map<String, dynamic>> fetchLabGrownData({
    String? shapeName,
    int page = 1,
    int perPage = 5000,
  }) async {
    return _fetchDiamondData(
      shapeName: shapeName,
      isLab: true,
      authKey: labAuthKey,
      page: page,
      perPage: perPage,
    );
  }

  static Future<Map<String, dynamic>> fetchNaturalData({
    String? shapeName,
    int page = 1,
    int perPage = 5000,
  }) async {
    return _fetchDiamondData(
      shapeName: shapeName,
      isLab: false,
      authKey: naturalAuthKey,
      page: page,
      perPage: perPage,
    );
  }
}
