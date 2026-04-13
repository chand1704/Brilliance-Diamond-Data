import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/gmss_stone_model.dart';

class GmssApiService {
  static const String baseUrl = 'https://dev2.kodllin.com/apis/api/getStockN';
  static const String currentAuthKey = 'jrn2m0veeul6';
  static Future<List<GmssStone>> fetchLabGrownData({int? shapeId}) async {
    print("API REQUEST FOR SHAPE ID: $shapeId");
    String shapeParam = (shapeId != null && shapeId > 0)
        ? "&shape=$shapeId"
        : "";
    final uri = Uri.parse(
      '$baseUrl?auth_key=$currentAuthKey&per_page=100000&page=1$shapeParam',
    );
    final response = await http.post(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['data'] != null) {
        final List<dynamic> dataList = body['data'];
        return dataList.map((e) => GmssStone.fromJson(e, isLab: true)).toList();
      }
    }
    return [];
  }

  static Future<List<GmssStone>> fetchNaturalData({int? shapeId}) async {
    String shapeParam = (shapeId != null && shapeId > 0)
        ? "&shape=$shapeId"
        : "";
    final uri = Uri.parse(
      '$baseUrl?auth_key=$currentAuthKey&per_page=1000&page=1$shapeParam',
    );
    final response = await http.post(uri);
    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body['data'] != null) {
        final List<dynamic> dataList = body['data'];
        return dataList
            .map((e) => GmssStone.fromJson(e, isLab: false))
            .toList();
      }
    }
    return [];
  }
}
