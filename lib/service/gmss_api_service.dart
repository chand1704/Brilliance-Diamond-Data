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
  }) async {
    try {
      final queryParams = {'auth_key': currentAuthKey};

      if (shapeName != null &&
          shapeName.toUpperCase() != "OTHER" &&
          shapeName.toUpperCase() != "ALL") {
        queryParams['shape'] = shapeName.toUpperCase();
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      debugPrint("Requesting URL: $uri");

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> dataList = (decoded is List)
            ? decoded
            : (decoded['data'] ?? []);

        List<GmssStone> stones = [];

        int renderLimit = dataList.length > 1000 ? 1000 : dataList.length;
        for (int i = 0; i < renderLimit; i++) {
          try {
            stones.add(GmssStone.fromJson(dataList[i], isLab: isLab));
          } catch (e) {
            debugPrint("Skipping diamond at index $i  due to error: $e");
          }
        }
        debugPrint(
          "Successfully parsed: ${dataList.length} items for the UI display",
        );
        return stones;
        // dataList
        //   .map((e) => GmssStone.fromJson(e, isLab: isLab))
        //   .toList();
      }
    } catch (e) {
      debugPrint("GmssApiService Exception: $e");
    }
    return [];
  }

  static Future<List<GmssStone>> fetchLabGrownData({String? shapeName}) async {
    return _fetchDiamondData(shapeName: shapeName, isLab: true);
  }

  static Future<List<GmssStone>> fetchNaturalData({String? shapeName}) async {
    return _fetchDiamondData(shapeName: shapeName, isLab: false);
  }
}
