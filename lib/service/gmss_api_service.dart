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
//   // static Future<Map<String, dynamic>> _fetchDiamondData({
//   //   String? shapeName,
//   //   required bool isLab,
//   //   required String authKey,
//   //   int page = 1,
//   // }) async {
//   //   try {
//   //     final Map<String, String> queryParams = {
//   //       'auth_key': authKey,
//   //       'page': page.toString(),
//   //       'per_page': '100',
//   //     };
//   //
//   //     if (shapeName != null &&
//   //         shapeName.toUpperCase() != "OTHER" &&
//   //         shapeName.toUpperCase() != "ALL") {
//   //       queryParams['shape'] = shapeName.toUpperCase();
//   //     }
//   //
//   //     final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
//   //     debugPrint("Requesting URL(${isLab ? 'LAB' : 'NATURAL '}): $uri");
//   //     debugPrint("Fetching Page $page: $uri");
//   //
//   //     final response = await http.post(uri);
//   //
//   //     if (response.statusCode == 200) {
//   //       final dynamic decoded = jsonDecode(response.body);
//   //       List<dynamic> dataList = [];
//   //       int totalCount = 0;
//   //       // ? decoded
//   //       // : (decoded['data'] ?? []);
//   //       if (decoded is Map) {
//   //         dataList = decoded['data'] ?? [];
//   //         totalCount = decoded['total'] ?? dataList.length;
//   //       } else if (decoded is List) {
//   //         dataList = decoded;
//   //         totalCount = decoded.length;
//   //       }
//   //       final List<dynamic> finalData = dataList.length > 100
//   //           ? dataList.sublist(0, 100)
//   //           : dataList;
//   //       final List<GmssStone> stones = finalData
//   //           .map((item) {
//   //             try {
//   //               return GmssStone.fromJson(item, isLab: isLab);
//   //             } catch (e) {
//   //               return null;
//   //             }
//   //           })
//   //           .whereType<GmssStone>()
//   //           .toList();
//   //
//   //       return {'stones': stones, 'total': totalCount};
//   //     }
//   //   } catch (e) {
//   //     debugPrint("Error: $e");
//   //   }
//   //   return {'stones': <GmssStone>[], 'total': 0};
//   // }
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
//       // Pagination માટે POST ને બદલે GET ટ્રાય કરજો જો સર્વર સપોર્ટ કરતું હોય, અત્યારે POST રાખીએ છીએ
//       final response = await http.post(uri);
//
//       if (response.statusCode == 200) {
//         final dynamic decoded = jsonDecode(response.body);
//         List<dynamic> dataList = [];
//         int totalCount = 0;
//
//         if (decoded is Map) {
//           dataList = decoded['data'] ?? [];
//           totalCount =
//               int.tryParse(decoded['total']?.toString() ?? '') ??
//               dataList.length;
//         } else if (decoded is List) {
//           dataList = decoded;
//           totalCount = dataList.length;
//         }
//
//         // Client-side limit જો સર્વર બધો ડેટા મોકલી દેતું હોય તો
//         final List<dynamic> limitedList = dataList.length > 100
//             ? dataList.sublist(0, 100)
//             : dataList;
//
//         final List<GmssStone> stones = limitedList
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
//       debugPrint("API Error: $e");
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
      debugPrint("API Calling: $uri");

      final response = await http.post(
        uri,
      ); // જો POST માં ઇસ્યુ હોય તો અહિયાં http.get ટ્રાય કરજો

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> dataList = [];
        int totalCount = 0;

        if (decoded is Map) {
          dataList = decoded['data'] ?? [];
          // API માંથી આવતો સાચો 'total' કી અહિયાં લો
          totalCount =
              int.tryParse(decoded['total']?.toString() ?? '') ??
              dataList.length;
        } else if (decoded is List) {
          dataList = decoded;
          totalCount = dataList.length;
        }

        // સર્વર લિમિટ ઇગ્નોર કરે તો આપણે ક્લાયન્ટ સાઈડ ૧૦૦ લેશું
        final List<dynamic> limitedData = dataList.length > 100
            ? dataList.sublist(0, 100)
            : dataList;

        final List<GmssStone> stones = limitedData
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
      debugPrint("GmssApiService Exception: $e");
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

// import 'dart:convert
//
// import 'package:flutter/cupertino.dart';
// import 'package:http/http.dart' as http;
//
// import '../model/gmss_stone_model.dart';
//
// class GmssApiService {
//   static const String baseUrl =
//       'https://excellent.kodllin.com/apis/api/getStockN';
//   static const String currentAuthKey = 'tc682t5vocwa';
//
//   static Future<List<GmssStone>> _fetchDiamondData({
//     String? shapeName,
//     required bool isLab,
//     int page = 1,
//   }) async {
//     try {
//       final Map<String, String> queryParams = {
//         'auth_key': currentAuthKey,
//         'page': page.toString(),
//         'per-page': '50',
//       };
//
//       if (shapeName != null && shapeName.toUpperCase() != "OTHER") {
//         queryParams['shape'] = shapeName.toUpperCase();
//       }
//
//       final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
//       debugPrint("Requesting URL: $uri");
//
//       final response = await http.post(uri);
//
//       if (response.statusCode == 200) {
//         final dynamic decoded = jsonDecode(response.body);
//         List<dynamic> dataList = decoded is List ? decoded : decoded['data'];
//         // ? decoded
//         // : (decoded['data'] ?? []);
//
//         return dataList
//             .map((item) {
//               try {
//                 return GmssStone.fromJson(item, isLab: isLab);
//               } catch (e) {
//                 return null;
//               }
//             })
//             .whereType<GmssStone>()
//             .toList();
//         // dataList
//         //   .map((e) => GmssStone.fromJson(e, isLab: isLab))
//         //   .toList();
//       }
//     } catch (e) {
//       debugPrint("GmssApiService Exception: $e");
//     }
//     return [];
//   }
//
//   static Future<List<GmssStone>> fetchLabGrownData({
//     String? shapeName,
//     int page = 1,
//   }) async {
//     return _fetchDiamondData(shapeName: shapeName, isLab: true, page: page);
//   }
//
//   static Future<List<GmssStone>> fetchNaturalData({
//     String? shapeName,
//     int page = 1,
//   }) async {
//     return _fetchDiamondData(shapeName: shapeName, isLab: false, page: page);
//   }
// }
