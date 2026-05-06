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
  String get displayColor {
    if (fancy_color.isNotEmpty) {
      if (colorStr.toLowerCase().contains("fancy") && colorStr.length > 5) {
        return colorStr;
      }
      return fancy_color;
    }
    return colorStr;
  }

  factory GmssStone.fromJson(Map<String, dynamic> json, {required bool isLab}) {
    double safeDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString().replaceAll(',', '')) ?? 0.0;
    }

    // Measurement parsing
    String measurements = (json['measurements'] ?? json['measurement'] ?? json['meas'] ?? "").toString();
    double len = 0.0, wid = 0.0, dep = 0.0;
    if (measurements.contains('*')) {
      List<String> parts = measurements.split('*');
      if (parts.isNotEmpty) len = safeDouble(parts[0]);
      if (parts.length >= 2) wid = safeDouble(parts[1]);
      if (parts.length >= 3) dep = safeDouble(parts[2]);
    } else if (measurements.contains('x')) {
      List<String> parts = measurements.split('x');
      if (parts.isNotEmpty) len = safeDouble(parts[0]);
      if (parts.length >= 2) wid = safeDouble(parts[1]);
      if (parts.length >= 3) dep = safeDouble(parts[2]);
    } else {
      len = safeDouble(json['length'] ?? json['l']);
      wid = safeDouble(json['width'] ?? json['w']);
      dep = safeDouble(json['depth'] ?? json['d']);
    }

    String growthType = (json['growthType'] ?? json['growth_type'] ?? "").toString().toUpperCase();
    bool stoneIsLab = isLab;
    if (growthType.contains("LAB") ||
        growthType.contains("CVD") ||
        growthType.contains("HPHT") ||
        (json['is_lab_grown'] == true || json['isLab'] == true)) {
      stoneIsLab = true;
    } else if (growthType.contains("NATURAL") || growthType.contains("NAT")) {
      stoneIsLab = false;
    }

    return GmssStone(
      id: json['id']?.hashCode ?? json['stockNo']?.hashCode ?? json['stock_no']?.hashCode ?? 0,
      stockNo: (json['stockNo'] ?? json['stock_no'] ?? json['stock_number'] ?? '').toString(),
      shapeStr: (json['shape'] ?? json['shape_name'] ?? 'ROUND').toString().toUpperCase(),
      shapeIcon: '',
      weight: safeDouble(json['weight'] ?? json['carat'] ?? json['cts']),
      colorStr: (json['color'] ?? json['color_name'] ?? "").toString(),
      fancy_color: (json['fancyColor'] ?? json['fancy_color'] ?? json['fancy_color_name'] ?? "").toString(),
      clarityStr: (json['clarity'] ?? json['clarity_name'] ?? "").toString(),
      cut: (json['cut'] ?? json['cut_grade'] ?? json['cut_name'] ?? '').toString(),
      cut_code: (json['cut_code'] ?? json['cut'] ?? '').toString(),
      lab: (json['lab'] ?? json['lab_name'] ?? json['certificate'] ?? "IGI").toString(),
      isLab: stoneIsLab,
      fl_intensity: (json['fluorescenceIntensity'] ?? json['fluorescence_intensity'] ?? json['fl_intensity'] ?? json['fluor'] ?? '').toString(),
      polish: (json['polish'] ?? json['polish_name'] ?? '').toString(),
      image_link: (json['imageLink'] ?? json['image_link'] ?? json['image_url'] ?? "").toString(),
      video_link: (json['videoLink'] ?? json['video_link'] ?? json['video_url'] ?? "").toString(),
      certi_file: (json['certiFile'] ?? json['certi_file'] ?? json['certificate_url'] ?? "").toString(),
      stoneName:
          "${json['weight'] ?? json['carat'] ?? ''} CT ${json['shape'] ?? ''} ${stoneIsLab ? 'LAB' : 'NATURAL'}",
      gridle_condition: (json['girdleCondition'] ?? json['girdle_condition'] ?? json['girdle'] ?? '').toString(),
      symmetry: (json['symmetry'] ?? json['symmetry_name'] ?? "").toString(),
      culet_size: (json['culetSize'] ?? json['culet_size'] ?? json['culet'] ?? '').toString(),
      length: len,
      ratio: safeDouble(json['ratio'] ?? json['measurement_ratio']),
      width: wid,
      depth: dep > 0 ? dep : safeDouble(json['depth'] ?? json['depth_percent']),
      table: safeDouble(json['table'] ?? json['table_percent']),
      total_price: safeDouble(json['totalPrice'] ?? json['total_price'] ?? json['price'] ?? json['price_total']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isLab': isLab,
      'stockNo': stockNo,
      'shape': shapeStr,
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
