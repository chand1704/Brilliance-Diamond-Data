import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/gmss_stone_model.dart';

class GmssApiService {
  static const String baseUrl = 'https://app.prajesh.co/apis/api/getStockN';
  static const String labAuthKey = 'nigtw54xafke';
  static const String naturalAuthKey = 'wwoy95kxfwll';
  static List<GmssStone>? _cachedLabStones;
  static List<GmssStone>? _cachedNaturalStones;
  static Future<GmssStone> fetchStoneById(String id) async {
    final labData = await fetchLabGrownData();
    final naturalData = await fetchNaturalData();

    return [
      ...labData,
      ...naturalData,
    ].firstWhere((stone) => stone.id.toString() == id);
  }

  static Future<List<GmssStone>> fetchLabGrownData() async {
    if (_cachedLabStones != null && _cachedLabStones!.isNotEmpty) {
      return _cachedLabStones!;
    }
    final uri = Uri.parse('$baseUrl?auth_key=$labAuthKey');
    final response = await http.post(uri);
    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      _cachedLabStones = decoded
          .map((e) => GmssStone.fromJson(e, isLab: true))
          .toList();
      return _cachedLabStones!;
    }
    return [];
  }

  static Future<List<GmssStone>> fetchNaturalData() async {
    if (_cachedNaturalStones != null && _cachedNaturalStones!.isNotEmpty) {
      return _cachedNaturalStones!;
    }
    final uri = Uri.parse('$baseUrl?auth_key=$naturalAuthKey');
    final response = await http.post(uri);
    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      _cachedNaturalStones = decoded
          .map((e) => GmssStone.fromJson(e, isLab: false))
          .toList();
      return _cachedNaturalStones!;
    } else {
      throw Exception('Failed to load Natural data');
    }
  }

  static void clearCache() {
    _cachedLabStones = null;
    _cachedNaturalStones = null;
  }
}

// class GmssApiService {
//   static const String apiUrl = 'https://dev2.kodllin.com/apis/api/gmss';
//   static Future<List<GmssStone>> fetchGmssData({required int shapeId}) async {
//     final body = {
//       "fl_ar": {
//         "stone_lab": [],
//         "supplier_id": [],
//         "shape": shapeId != null ? [shapeId] : [],
//         "color": [],
//         "fancy_color": [],
//         "fancy_intensity": [],
//         "fancy_overtone": [],
//         "clarity": [],
//         "fluorescence_color": [],
//         "gridle_thick": [],
//         "gridle_thin": [],
//         "fluorescence_intensity": [],
//         "milky": [],
//         "color_shade": [],
//         "lab": [],
//         "cut": [],
//         "inclusion": [],
//         "open_inclusion": [],
//         "luster": [],
//         "eye_clean": [],
//         "location": [],
//         "treatment": [],
//         "growth_type": [],
//         "polish": [],
//         "symmetry": [],
//         "heart_arrow": [],
//         "carate_range": [],
//         "manual_range": [],
//         "selected_range": [],
//         "stock_type": 2,
//         "stock_type_growth": 5,
//         "stone_list": "",
//         "arrival_from": "",
//         "arrival_to": "",
//         "ratio_from": "",
//         "ratio_to": "",
//         "packet_no": "",
//         "inclusion_str": "",
//         "rate": {
//           "type": "1",
//           "price_order": "2",
//           "order_apply": true,
//           "min": "",
//           "max": "",
//         },
//         "color_type": {"type": 1},
//         "cps": {"th_ex": false, "ex_cut": false, "th_vg": false},
//         "parameters": {
//           "length": {"min": "", "max": ""},
//           "width": {"min": "", "max": ""},
//           "depth": {"min": "", "max": ""},
//           "lw_ratio": {"min": "", "max": ""},
//           "crown_deg": {"min": "", "max": ""},
//           "pavilion_deg": {"min": "", "max": ""},
//           "table": {"min": "", "max": ""},
//           "depth_per": {"min": "", "max": ""},
//           "per_ratio": 0,
//         },
//         "shape_other": false,
//         "unknown_shade": true,
//         "no_bgm": false,
//         "unknown_luster": true,
//         "unknown_eye_clean": true,
//         "all_button": {
//           "shape_all": false,
//           "color_all": false,
//           "fancy_color_all": false,
//           "fancy_intensity_all": false,
//           "fancy_overtone_all": false,
//           "clarity_all": false,
//           "fluorescence_color_all": false,
//           "gridle_thin_all": false,
//           "gridle_thick_all": false,
//           "fluorescence_intensity_all": false,
//           "milky_all": false,
//           "color_shade_all": false,
//           "lab_all": false,
//           "cut_all": false,
//           "inclusion_all": false,
//           "open_inclusion_all": false,
//           "luster_all": false,
//           "eye_clean_all": false,
//           "location_all": false,
//           "treatment_all": false,
//           "growth_type_all": false,
//           "polish_all": false,
//           "symmetry_all": false,
//           "heart_arrow_all": false,
//           "carate_range_all": false,
//         },
//       },
//       "per_page": 200,
//       "page": 1,
//       "shape": shapeId != null ? [shapeId] : [],
//       "stock_no": "",
//       "stone_type": [],
//       "stone_lab": [],
//       "user_sk": "IEx6bkZGMWxwU2NaYWVZM3hFZHBH",
//       "sort": "",
//     };
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {
//         "Content-Type": "application/json",
//         "Accept": "application/json",
//       },
//       body: jsonEncode(body),
//     );
//     if (response.statusCode != 200) {
//       throw Exception('GMSS API Error: ${response.statusCode}');
//     }
//     final decoded = jsonDecode(response.body);
//     final List list = decoded['data'] ?? [];
//     return list.map((e) => GmssStone.fromJson(e)).toList();
//   }
// }
