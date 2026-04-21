// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
//
// import '../model/gmss_stone_model.dart';
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
//         'per_page': '100',
//       };
//
//       if (shapeName != null &&
//           shapeName.toUpperCase() != "OTHER" &&
//           shapeName.toUpperCase() != "ALL") {
//         queryParams['shape'] = shapeName.toUpperCase();
//       }
//
//       final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
//       debugPrint("API Calling: $uri");
//
//       final response = await http.post(
//         uri,
//       ); // જો POST માં ઇસ્યુ હોય તો અહિયાં http.get ટ્રાય કરજો
//
//       if (response.statusCode == 200) {
//         final dynamic decoded = jsonDecode(response.body);
//         List<dynamic> dataList = [];
//         int totalCount = 0;
//
//         if (decoded is Map) {
//           dataList = decoded['data'] ?? [];
//           // API માંથી આવતો સાચો 'total' કી અહિયાં લો
//           totalCount =
//               int.tryParse(decoded['total']?.toString() ?? '') ??
//               dataList.length;
//         } else if (decoded is List) {
//           dataList = decoded;
//           totalCount = dataList.length;
//         }
//
//         // સર્વર લિમિટ ઇગ્નોર કરે તો આપણે ક્લાયન્ટ સાઈડ ૧૦૦ લેશું
//         final List<dynamic> limitedData = dataList.length > 100
//             ? dataList.sublist(0, 100)
//             : dataList;
//
//         final List<GmssStone> stones = limitedData
//             .map((item) {
//               try {
//                 return GmssStone.fromJson(item, isLab: isLab);
//               } catch (e) {
//                 return null;
//               }
//             })
//             .whereType<GmssStone>()
//             .toList();
//
//         return {'stones': stones, 'total': totalCount};
//       }
//     } catch (e) {
//       debugPrint("GmssApiService Exception: $e");
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
//
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../model/gmss_stone_model.dart';

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
        'page': page.toString(),
        'per_page': '100',
      };

      if (shapeName != null &&
          shapeName.toUpperCase() != "OTHER" &&
          shapeName.toUpperCase() != "ALL") {
        queryParams['shape'] = shapeName.toUpperCase();
      }

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      debugPrint("API Request: $uri");

      // Pagination માટે POST રિક્વેસ્ટ
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        try {
          final dynamic decoded = jsonDecode(response.body);
          List<dynamic> dataList = [];
          int totalFromApi = 0;

          if (decoded is Map) {
            dataList = decoded['data'] ?? [];
            totalFromApi =
                int.tryParse(decoded['total']?.toString() ?? '') ?? 0;
          } else if (decoded is List) {
            dataList = decoded;
            totalFromApi = dataList.length;
          }

          List<dynamic> finalDataList = [];
          int itemsPerPage = 100;

          if (dataList.length > itemsPerPage) {
            int start = (page - 1) * itemsPerPage;
            int end = start + itemsPerPage;
            if (start < dataList.length) {
              finalDataList = dataList.sublist(
                start,
                end > dataList.length ? dataList.length : end,
              );
            }
          } else {
            finalDataList = dataList;
          }
          final stones =
              finalDataList // limitedData નો ઉપયોગ કરો
                  .map((item) {
                    try {
                      return GmssStone.fromJson(item, isLab: isLab);
                    } catch (e) {
                      return null;
                    }
                  })
                  .whereType<GmssStone>()
                  .toList();

          return {'stones': stones, 'total': totalFromApi};
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
