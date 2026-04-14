import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/gmss_stone_model.dart';

class GmssApiService {
  static const String baseUrl = 'https://dev2.kodllin.com/apis/api/getStockN';
  static const String currentAuthKey = 'jrn2m0veeul6';

  static Future<List<GmssStone>> fetchLabGrownData({String? shapeName}) async {
    return _fetchDiamondData(shapeName: shapeName, isLab: true);
  }

  static Future<List<GmssStone>> fetchNaturalData({String? shapeName}) async {
    return _fetchDiamondData(shapeName: shapeName, isLab: false);
  }

  /// Private helper to avoid code duplication and handle logic in one place
  static Future<List<GmssStone>> _fetchDiamondData({
    String? shapeName,
    required bool isLab,
  }) async {
    try {
      // 2. Build URI cleanly
      final queryParams = {
        'auth_key': currentAuthKey,
        'per_page': '1000',
        'page': '1',
      };
      // 1. Handle "Other" or "All" logic
      // If shape is 'Other' or null, we don't send the shape param to get all available stock
      String? apiShape;
      if (shapeName != null && shapeName.toLowerCase() != "other") {
        queryParams['shape'] = shapeName.toUpperCase();
      }

      // 2. Build URI cleanly
      // final queryParams = {
      //   'auth_key': currentAuthKey,
      //   'per_page': '1000',
      //   'page': '1',
      // };

      // Only add shape if it's a specific valid shape
      if (apiShape != null) {
        queryParams['shape'] = apiShape;
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

      print("API REQUEST (${isLab ? 'LAB' : 'NATURAL'}): $uri");

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['data'] != null && body['data'] is List) {
          final List<dynamic> dataList = body['data'];
          return dataList
              .map((e) => GmssStone.fromJson(e, isLab: isLab))
              .toList();
        }
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("GmssApiService Exception: $e");
    }
    return [];
  }
}
