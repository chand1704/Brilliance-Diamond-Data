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
  try {
    final decoded = jsonDecode(params.jsonString);
    List<dynamic> dataList = [];
    int totalFromApi = 0;

    if (decoded is Map) {
      // Try multiple common keys for data list
      dataList =
          decoded['data'] ??
          decoded['stones'] ??
          decoded['response'] ??
          decoded['list'] ??
          [];

      // Try multiple common keys for total count
      totalFromApi =
          int.tryParse(decoded['total']?.toString() ?? '') ??
          int.tryParse(decoded['total_records']?.toString() ?? '') ??
          int.tryParse(decoded['count']?.toString() ?? '') ??
          dataList.length;
    } else if (decoded is List) {
      dataList = decoded;
      totalFromApi = dataList.length;
    }

    final stones = dataList
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return GmssStone.fromJson(item, isLab: params.isLab);
            }
            return null;
          } catch (e) {
            return null;
          }
        })
        .whereType<GmssStone>()
        .toList();

    return {'stones': stones, 'total': totalFromApi};
  } catch (e) {
    return {'stones': <GmssStone>[], 'total': 0};
  }
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

    // Hybrid approach: Put parameters in both URL and Body for maximum compatibility
    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    try {
      if (kDebugMode) {
        print("Fetching data from: $uri");
        print("Request body: $queryParams");
      }

      final response = await http
          .post(uri, body: queryParams)
          .timeout(const Duration(seconds: 120));

      if (kDebugMode) {
        print("API Response Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        if (kDebugMode) {
          final bodyPreview = response.body.length > 200
              ? "${response.body.substring(0, 200)}..."
              : response.body;
          print("API Response Body Preview: $bodyPreview");
        }
        final result = await compute(
          _decodeAndParseJson,
          _DecodeParams(response.body, isLab),
        );
        return result;
      } else {
        if (kDebugMode) {
          print("API Error: ${response.statusCode} - ${response.body}");
        }
        throw Exception("API Error: ${response.statusCode}");
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print("API Exception: $e");
        print(stack);
      }
      rethrow;
    }
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
