import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../model/gmss_stone_model.dart';

class _DecodeParams {
  final String jsonString;
  final bool isLab;
  _DecodeParams(this.jsonString, this.isLab);
}

// Top-level function for background isolate
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

  final stones = dataList.map((item) {
    try {
      return GmssStone.fromJson(item, isLab: params.isLab);
    } catch (e) {
      return null;
    }
  }).whereType<GmssStone>().toList();

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
  }) async {
    try {
      final Map<String, String> queryParams = {
        'auth_key': authKey,
        'page': '1', // હવે લોકલ પેજિનેશન કરીશું
        'per_page': '100000', // બધો ડેટા એકસાથે લાવવા
      };

      if (shapeName != null &&
          shapeName.toUpperCase() != "OTHER" &&
          shapeName.toUpperCase() != "ALL") {
        queryParams['shape'] = shapeName.toUpperCase();
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      debugPrint("API Request: $uri");

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        try {
          // JSON Decoding and Mapping in background to prevent UI freeze
          final result = await compute(
              _decodeAndParseJson, _DecodeParams(response.body, isLab));

          return result;
        } catch (e) {
          debugPrint("JSON Parsing Error: $e");
          return {'stones': <GmssStone>[], 'total': 0};
        }
      }
    } catch (e) {
      debugPrint("Network Error: $e");
    }
    return {'stones': <GmssStone>[], 'total': 0};
  }

  static Future<Map<String, dynamic>> fetchLabGrownData({
    String? shapeName,
    int page = 1,
  }) async {
    return _fetchDiamondData(
      shapeName: shapeName,
      isLab: true,
      authKey: labAuthKey,
      page: page,
    );
  }

  static Future<Map<String, dynamic>> fetchNaturalData({
    String? shapeName,
    int page = 1,
  }) async {
    return _fetchDiamondData(
      shapeName: shapeName,
      isLab: false,
      authKey: naturalAuthKey,
      page: page,
    );
  }
}

// import 'dart:convert';
//
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
//
// import '../model/gmss_stone_model.dart';
//
// // Top-level function for background isolate
// dynamic _decodeJson(String text) {
//   return jsonDecode(text);
// }
//
// class GmssApiService {
//   static const String baseUrl =
//       'https://excellent.kodllin.com/apis/api/getStockN';
//   static const String labAuthKey = 'tc682t5vocwa';
//   static const String naturalAuthKey = 'jm4hzizpfvs0';
//
//   static Future<Map<String, dynamic>> _fetchDiamondData({
//     String? shapeName,
//     required bool isLab,
//     required String authKey,
//     int page = 1,
//   }) async {
//     try {
//       final Map<String, String> queryParams = {
//         'auth_key': authKey,
//         'page': page.toString(),
//         'per_page': '100', // API ને પેજિનેશન કરવા દો
//       };
//
//       if (shapeName != null &&
//           shapeName.toUpperCase() != "OTHER" &&
//           shapeName.toUpperCase() != "ALL") {
//         queryParams['shape'] = shapeName.toUpperCase();
//       }
//
//       final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
//       debugPrint("API Request: $uri");
//
//       final response = await http.post(uri);
//
//       if (response.statusCode == 200) {
//         try {
//           // JSON Decoding in background to prevent UI freeze
//           final dynamic decoded = await compute(_decodeJson, response.body);
//           List<dynamic> dataList = [];
//           int totalFromApi = 0;
//
//           if (decoded is Map) {
//             dataList = decoded['data'] ?? [];
//             totalFromApi =
//                 int.tryParse(decoded['total']?.toString() ?? '') ?? 0;
//           } else if (decoded is List) {
//             dataList = decoded;
//             totalFromApi = dataList.length;
//           }
//
//           List<dynamic> finalDataList = [];
//           int itemsPerPage = 100;
//
//           if (dataList.length > itemsPerPage) {
//             int start = (page - 1) * itemsPerPage;
//             int end = start + itemsPerPage;
//             if (start < dataList.length) {
//               finalDataList = dataList.sublist(
//                 start,
//                 end > dataList.length ? dataList.length : end,
//               );
//             }
//           } else {
//             finalDataList = dataList;
//           }
//           final stones =
//               finalDataList // limitedData નો ઉપયોગ કરો
//                   .map((item) {
//                     try {
//                       return GmssStone.fromJson(item, isLab: isLab);
//                     } catch (e) {
//                       return null;
//                     }
//                   })
//                   .whereType<GmssStone>()
//                   .toList();
//
//           return {'stones': stones, 'total': totalFromApi};
//         } catch (e) {
//           debugPrint("JSON Parsing Error: $e");
//           return {'stones': <GmssStone>[], 'total': 0};
//         }
//       }
//     } catch (e) {
//       debugPrint("Network Error: $e");
//     }
//     return {'stones': <GmssStone>[], 'total': 0};
//   }
//
//   static Future<Map<String, dynamic>> fetchLabGrownData({
//     String? shapeName,
//     int page = 1,
//   }) async {
//     return _fetchDiamondData(
//       shapeName: shapeName,
//       isLab: true,
//       authKey: labAuthKey,
//       page: page,
//     );
//   }
//
//   static Future<Map<String, dynamic>> fetchNaturalData({
//     String? shapeName,
//     int page = 1,
//   }) async {
//     return _fetchDiamondData(
//       shapeName: shapeName,
//       isLab: false,
//       authKey: naturalAuthKey,
//       page: page,
//     );
//   }
// }
