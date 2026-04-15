import 'dart:convert';

import 'package:flutter/cupertino.dart';
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

  static Future<List<GmssStone>> _fetchDiamondData({
    String? shapeName,
    required bool isLab,
  }) async {
    try {
      final Map<String, String> queryParams = {
        'auth_key': currentAuthKey,
        'per_page': '1000',
        'page': '1',
      };

      if (shapeName != null &&
          shapeName.toLowerCase() != "other" &&
          shapeName.toLowerCase() != "all") {
        queryParams['shape'] = shapeName.toUpperCase();
      }
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      print("Api REQUEST(${isLab ? 'LAB' : 'NATURAL'}):$uri");

      final response = await http.post(uri).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['data'] != null && body['data'] is List) {
          final List<dynamic> dataList = body['data'];
          return dataList
              .map((e) => GmssStone.fromJson(e, isLab: isLab))
              .toList();
        }
      } else {
        debugPrint("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("GmssApiService Exception: $e");
    }
    return [];
  }
}
