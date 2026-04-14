// import 'dart:convert';
// import 'dart:html' as html;
//
// class GmssStone {
//   final int id;
//   final String stockNo;
//   final String shapeStr;
//   final String shapeIcon;
//   final double weight;
//   final String colorStr;
//   final String fancy_color;
//   final String clarityStr;
//   final String cut;
//   final String cut_code;
//   final String lab;
//   final String fl_intensity;
//   final String polish;
//   final String image_link;
//   final String video_link;
//   final String stoneName;
//   final String gridle_condition;
//   final String symmetry;
//   final String culet_size;
//   final String? certi_file;
//   final double length;
//   final double ratio;
//   final double depth;
//   final double width;
//   final double table;
//   final double total_price;
//   final bool isLab;
//   GmssStone({
//     required this.id,
//     required this.stockNo,
//     required this.shapeStr,
//     required this.shapeIcon,
//     required this.weight,
//     required this.colorStr,
//     required this.fancy_color,
//     required this.clarityStr,
//     required this.cut,
//     required this.cut_code,
//     required this.lab,
//     required this.fl_intensity,
//     required this.polish,
//     required this.image_link,
//     required this.video_link,
//     required this.stoneName,
//     required this.gridle_condition,
//     required this.symmetry,
//     required this.culet_size,
//     this.certi_file,
//     required this.length,
//     required this.ratio,
//     required this.depth,
//     required this.width,
//     required this.table,
//     required this.total_price,
//     required this.isLab,
//   });
//
//   factory GmssStone.fromJson(Map<String, dynamic> json, {required bool isLab}) {
//     double safeDouble(dynamic v) {
//       if (v == null) return 0.0;
//       if (v is num) return v.toDouble();
//       return double.tryParse(v.toString()) ?? 0.0;
//     }
//
//     String rawShape = json['shape']?.toString() ?? 'ROUND';
//     String normalizedShape = rawShape.trim().toUpperCase();
//
//     if (normalizedShape.contains("ROUND")) {
//       normalizedShape = "ROUND";
//     } else if (normalizedShape.contains("PRINCESS")) {
//       normalizedShape = "PRINCESS";
//     } else if (normalizedShape.contains("EMERALD")) {
//       normalizedShape = "EMERALD";
//     }
//
//     String measurements = json['measurements']?.toString() ?? "";
//     double len = 0.0;
//     double wid = 0.0;
//     double dep = 0.0;
//     if (measurements.contains('*')) {
//       List<String> parts = measurements.split('*');
//       if (parts.length >= 1) len = safeDouble(parts);
//       if (parts.length >= 2) wid = safeDouble(parts);
//       if (parts.length >= 3) dep = safeDouble(parts);
//     } else {
//       len = safeDouble(json['length']);
//       wid = safeDouble(json['width']);
//       dep = safeDouble(json['depth']);
//     }
//     // Use 'Diamond_Type' from your API if available
//     String apiLabInfo =
//         json['Diamond_Type']?.toString() ?? (isLab ? 'LAB GROWN' : 'NATURAL');
//     bool stoneIsLab = apiLabInfo.toUpperCase().contains("LAB") || isLab;
//     String actualShape = json['shape']?.toString() ?? 'ROUND';
//     if (actualShape.toUpperCase().contains("ROUND")) actualShape = "ROUND";
//     return GmssStone(
//       id: json['id'] ?? json['stockNo']?.hashCode ?? 0,
//       stockNo: json['stockNo']?.toString() ?? '',
//       // shapeStr: actualShape.trim(),
//       shapeStr: normalizedShape,
//       shapeIcon: '',
//       weight: safeDouble(json['weight']),
//       colorStr: json['color']?.toString() ?? "",
//       fancy_color: json['fancyColor']?.toString() ?? "",
//       clarityStr: json['clarity']?.toString() ?? "",
//       cut: json['cut']?.toString() ?? '',
//       cut_code: json['cut']?.toString() ?? '',
//       // lab: json['lab'] ?? "GIA",
//       lab: apiLabInfo,
//       isLab: stoneIsLab,
//       // isLab: apiLabInfo.toUpperCase().contains("LAB"),
//       // isLab: isLab,
//       fl_intensity: json['fluorescenceIntensity']?.toString() ?? '',
//       polish: json['polish']?.toString() ?? '',
//       image_link: json['imageLink']?.toString() ?? "",
//       video_link: json['videoLink']?.toString() ?? "",
//       certi_file: json['certiFile']?.toString() ?? "",
//       stoneName:
//           json['stoneName'] ??
//           "${json['weight']} CARAT ${actualShape.toUpperCase()} ${isLab ? 'LAB GROWN' : 'NATURAL'}",
//       gridle_condition:
//           json['girdleCondition']?.toString() ??
//           json['gridle_condition']?.toString() ??
//           '',
//       symmetry: json['symmetry']?.toString() ?? "",
//       culet_size: json['culetSize']?.toString() ?? '',
//       length: len,
//       ratio: safeDouble(json['ratio']),
//       width: wid > 0 ? wid : safeDouble(json['table']),
//       depth: dep > 0 ? dep : safeDouble(json['depth']),
//       table: safeDouble(json['table']),
//       total_price: safeDouble(json['totalPrice']),
//     );
//   }
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'isLab': isLab,
//       'stockNo': stockNo,
//       'shapeStr': shapeStr,
//       'shapeIcon': shapeIcon,
//       'weight': weight,
//       'color': colorStr,
//       'fancyColor': fancy_color,
//       'clarity': clarityStr,
//       'cut': cut,
//       'cut_code': cut_code,
//       'lab': lab,
//       'fluorescenceIntensity': fl_intensity,
//       'polish': polish,
//       'imageLink': image_link,
//       'videoLink': video_link,
//       'certiFile': certi_file,
//       'stoneName': stoneName,
//       'girdleCondition': gridle_condition,
//       'symmetry': symmetry,
//       'culetSize': culet_size,
//       'measurements': "$length*$width*$depth",
//       'ratio': ratio,
//       'depth': depth,
//       'table': table,
//       'totalPrice': total_price,
//     };
//   }
//
//   static void addToHistory(GmssStone stone) {
//     final String? existingHistory = html.window.localStorage['recent_history'];
//     List<dynamic> historyList = [];
//     if (existingHistory != null) {
//       try {
//         historyList = jsonDecode(existingHistory);
//       } catch (_) {}
//     }
//     historyList.removeWhere((item) => item['stockNo'] == stone.stockNo);
//     historyList.insert(0, stone.toJson());
//     if (historyList.length > 20) {
//       historyList = historyList.sublist(0, 20);
//     }
//     html.window.localStorage['recent_history'] = jsonEncode(historyList);
//   }
//
//   static void toggleSaveStone(GmssStone stone) {
//     final String? existing = html.window.localStorage['saved_stones'];
//     List<dynamic> savedList = existing != null ? jsonDecode(existing) : [];
//     bool exists = savedList.any((item) => item['stockNo'] == stone.stockNo);
//     if (exists) {
//       savedList.removeWhere((item) => item['stockNo'] == stone.stockNo);
//     } else {
//       savedList.add(stone.toJson());
//     }
//     html.window.localStorage['saved_stones'] = jsonEncode(savedList);
//   }
//
//   static List<GmssStone> loadSavedStones() {
//     final String? existing = html.window.localStorage['saved_stones'];
//     if (existing == null) return [];
//     List<dynamic> decoded = jsonDecode(existing);
//     return decoded
//         .map(
//           (e) => GmssStone.fromJson(
//             e,
//             isLab: e['stoneName'].toString().contains("LAB"),
//           ),
//         )
//         .toList();
//   }
// }
import 'dart:convert';
import 'dart:html' as html;

class GmssStone {
  final int id;
  final String stockNo;
  final String shapeStr;
  final String shapeIcon;
  final double weight;
  final String colorStr;
  final String fancy_color;
  final String clarityStr;
  final String cut;
  final String cut_code;
  final String lab;
  final String fl_intensity;
  final String polish;
  final String image_link;
  final String video_link;
  final String stoneName;
  final String gridle_condition;
  final String symmetry;
  final String culet_size;
  final String? certi_file;
  final double length;
  final double ratio;
  final double depth;
  final double width;
  final double table;
  final double total_price;
  final bool isLab;
  GmssStone({
    required this.id,
    required this.stockNo,
    required this.shapeStr,
    required this.shapeIcon,
    required this.weight,
    required this.colorStr,
    required this.fancy_color,
    required this.clarityStr,
    required this.cut,
    required this.cut_code,
    required this.lab,
    required this.fl_intensity,
    required this.polish,
    required this.image_link,
    required this.video_link,
    required this.stoneName,
    required this.gridle_condition,
    required this.symmetry,
    required this.culet_size,
    this.certi_file,
    required this.length,
    required this.ratio,
    required this.depth,
    required this.width,
    required this.table,
    required this.total_price,
    required this.isLab,
  });

  factory GmssStone.fromJson(Map<String, dynamic> json, {required bool isLab}) {
    double safeDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    String rawShape = json['shape']?.toString() ?? 'ROUND';
    String normalizedShape = rawShape.trim().toUpperCase();

    if (normalizedShape.contains("ROUND")) {
      normalizedShape = "ROUND";
    } else if (normalizedShape.contains("PRINCESS")) {
      normalizedShape = "PRINCESS";
    } else if (normalizedShape.contains("EMERALD")) {
      normalizedShape = "EMERALD";
    }

    String measurements = json['measurements']?.toString() ?? "";
    double len = 0.0;
    double wid = 0.0;
    double dep = 0.0;
    if (measurements.contains('*')) {
      List<String> parts = measurements.split('*');
      if (parts.length >= 1) len = safeDouble(parts);
      if (parts.length >= 2) wid = safeDouble(parts);
      if (parts.length >= 3) dep = safeDouble(parts);
    } else {
      len = safeDouble(json['length']);
      wid = safeDouble(json['width']);
      dep = safeDouble(json['depth']);
    }
    // Use 'Diamond_Type' from your API if available
    String apiLabInfo =
        json['Diamond_Type']?.toString() ?? (isLab ? 'LAB GROWN' : 'NATURAL');
    bool stoneIsLab = apiLabInfo.toUpperCase().contains("LAB") || isLab;
    String actualShape = json['shape']?.toString() ?? 'ROUND';
    if (actualShape.toUpperCase().contains("ROUND")) actualShape = "ROUND";
    return GmssStone(
      id: json['id'] ?? json['stockNo']?.hashCode ?? 0,
      stockNo: json['stockNo']?.toString() ?? '',
      // shapeStr: actualShape.trim(),
      shapeStr: normalizedShape,
      shapeIcon: '',
      weight: safeDouble(json['weight']),
      colorStr: json['color']?.toString() ?? "",
      fancy_color: json['fancyColor']?.toString() ?? "",
      clarityStr: json['clarity']?.toString() ?? "",
      cut: json['cut']?.toString() ?? '',
      cut_code: json['cut']?.toString() ?? '',
      // lab: json['lab'] ?? "GIA",
      lab: apiLabInfo,
      isLab: stoneIsLab,
      // isLab: apiLabInfo.toUpperCase().contains("LAB"),
      // isLab: isLab,
      fl_intensity: json['fluorescenceIntensity']?.toString() ?? '',
      polish: json['polish']?.toString() ?? '',
      image_link: json['imageLink']?.toString() ?? "",
      video_link: json['videoLink']?.toString() ?? "",
      certi_file: json['certiFile']?.toString() ?? "",
      stoneName:
          json['stoneName'] ??
          "${json['weight']} CARAT ${actualShape.toUpperCase()} ${isLab ? 'LAB GROWN' : 'NATURAL'}",
      gridle_condition:
          json['girdleCondition']?.toString() ??
          json['gridle_condition']?.toString() ??
          '',
      symmetry: json['symmetry']?.toString() ?? "",
      culet_size: json['culetSize']?.toString() ?? '',
      length: len,
      ratio: safeDouble(json['ratio']),
      width: wid > 0 ? wid : safeDouble(json['table']),
      depth: dep > 0 ? dep : safeDouble(json['depth']),
      table: safeDouble(json['table']),
      total_price: safeDouble(json['totalPrice']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isLab': isLab,
      'stockNo': stockNo,
      'shapeStr': shapeStr,
      'shapeIcon': shapeIcon,
      'weight': weight,
      'color': colorStr,
      'fancyColor': fancy_color,
      'clarity': clarityStr,
      'cut': cut,
      'cut_code': cut_code,
      'lab': lab,
      'fluorescenceIntensity': fl_intensity,
      'polish': polish,
      'imageLink': image_link,
      'videoLink': video_link,
      'certiFile': certi_file,
      'stoneName': stoneName,
      'girdleCondition': gridle_condition,
      'symmetry': symmetry,
      'culetSize': culet_size,
      'measurements': "$length*$width*$depth",
      'ratio': ratio,
      'depth': depth,
      'table': table,
      'totalPrice': total_price,
    };
  }

  static void addToHistory(GmssStone stone) {
    final String? existingHistory = html.window.localStorage['recent_history'];
    List<dynamic> historyList = [];
    if (existingHistory != null) {
      try {
        historyList = jsonDecode(existingHistory);
      } catch (_) {}
    }
    historyList.removeWhere((item) => item['stockNo'] == stone.stockNo);
    historyList.insert(0, stone.toJson());
    if (historyList.length > 20) {
      historyList = historyList.sublist(0, 20);
    }
    html.window.localStorage['recent_history'] = jsonEncode(historyList);
  }

  static void toggleSaveStone(GmssStone stone) {
    final String? existing = html.window.localStorage['saved_stones'];
    List<dynamic> savedList = existing != null ? jsonDecode(existing) : [];
    bool exists = savedList.any((item) => item['stockNo'] == stone.stockNo);
    if (exists) {
      savedList.removeWhere((item) => item['stockNo'] == stone.stockNo);
    } else {
      savedList.add(stone.toJson());
    }
    html.window.localStorage['saved_stones'] = jsonEncode(savedList);
  }

  static List<GmssStone> loadSavedStones() {
    final String? existing = html.window.localStorage['saved_stones'];
    if (existing == null) return [];
    List<dynamic> decoded = jsonDecode(existing);
    return decoded
        .map(
          (e) => GmssStone.fromJson(
            e,
            isLab: e['stoneName'].toString().contains("LAB"),
          ),
        )
        .toList();
  }
}
