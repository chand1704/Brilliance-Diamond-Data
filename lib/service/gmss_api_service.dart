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
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> dataList = [];
        int totalCount = 0;

        if (decoded is Map) {
          dataList = decoded['data'] ?? [];
          totalCount = int.tryParse(decoded['total']?.toString() ?? '') ?? 0;
        } else if (decoded is List) {
          dataList = decoded;
          totalCount = dataList.length;
        }

        // જો સર્વર લિમિટ ઇગ્નોર કરે, તો આપણે ક્લાયન્ટ સાઈડ ૧૦૦ લઈશું
        final List<dynamic> finalDataList = dataList.length > 100
            ? dataList.sublist(0, 100)
            : dataList;

        final stones = finalDataList
            .map((item) {
              try {
                return GmssStone.fromJson(item, isLab: isLab);
              } catch (e) {
                return null;
              }
            })
            .whereType<GmssStone>()
            .toList();

        return {'stones': stones, 'total': totalCount};
      }
    } catch (e) {
      debugPrint("API Error: $e");
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
