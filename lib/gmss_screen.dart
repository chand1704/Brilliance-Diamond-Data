import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:brilliance_diamond_data/model/gmss_stone_model.dart';
import 'package:brilliance_diamond_data/service/gmss_api_service.dart';
import 'package:brilliance_diamond_data/utils/diamond_painter_utils.dart';
import 'package:brilliance_diamond_data/widgets/diamond_card.dart';
import 'package:brilliance_diamond_data/widgets/main_header.dart';
import 'package:brilliance_diamond_data/widgets/sidebar_filters.dart';
import 'package:flutter/material.dart';

class GmssScreen extends StatefulWidget {
  const GmssScreen({super.key});
  @override
  State<GmssScreen> createState() => _GmssScreenState();
}

class _GmssScreenState extends State<GmssScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 1;
  int _localVisibleCount = 6; // લોકલ પેજિનેશન માટે 5-6 નુ ગ્રુપ
  int _totalFilteredStonesCount = 0; // કુલ ફિલ્ટર થયેલા ડાયમંડની સંખ્યા
  bool _isMoreLoading = false; // Nava data load thai rahya che ke nahi
  List<GmssStone> _displayedStones =
      []; // Display thava vala stones ni main list
  bool _hasMoreData = true; // Have vadhare data API ma che ke nahi
  int _totalStonesFromApi = 0;
  final Set<String> _expandedStoneStockNos = {};
  late AnimationController _shimmerController;
  final Map<int, Map<String, dynamic>> _cachedLabGrownMap = {};
  final Map<int, Map<String, dynamic>> _cachedNaturalMap = {};
  int? selectedFancyColorId;
  double selectedSaturation = 0;
  RangeValues _saturationRange = const RangeValues(0, 5);
  final List<String> saturationLabels = [
    "Light",
    "Fancy",
    "Intense",
    "Vivid",
    "Deep",
    "Dark",
  ];
  bool isFancySearch = false;
  bool isFancyExpanded = false;
  String? selectedFancyColor;
  final List<Map<String, dynamic>> fancyColors = [
    {
      'id': 7,
      'name': 'Green',
      'url':
          'https://www.brilliance.com/sites/default/files/vue/fancy-search/RD_Green.png',
    },
    {
      'id': 8,
      'name': 'Orange',
      'url':
          'https://www.brilliance.com/sites/default/files/vue/fancy-search/RD_Orange.png',
    },
    {
      'id': 9,
      'name': 'Pink',
      'url':
          'https://www.brilliance.com/sites/default/files/vue/fancy-search/RD_Pink.png',
    },
    {
      'id': 11,
      'name': 'Purple',
      'url':
          'https://www.brilliance.com/sites/default/files/vue/fancy-search/RD_Purple.png',
    },
    {
      'id': 14,
      'name': 'Yellow',
      'url':
          'https://www.brilliance.com/sites/default/files/vue/fancy-search/RD_Yellow.png',
    },
    {
      'id': 2,
      'name': 'Blue',
      'url':
          'https://www.brilliance.com/sites/default/files/vue/fancy-search/RD_Blue.png',
    },
    {
      'id': 6,
      'name': 'Grey',
      'url':
          'https://www.brilliance.com/sites/default/files/vue/fancy-search/RD_Grey.png',
    },
    {
      'id': 3,
      'name': 'Brown',
      'url':
          'https://www.brilliance.com/sites/default/files/vue/fancy-search/RD_Brown.png',
    },
    {
      'id': 10,
      'name': 'NZ',
      'url':
          'https://www.brilliance.com/sites/default/files/vue/fancy-search/RD_NZ.png',
    },
  ];
  final ScrollController _scrollController = ScrollController();
  late Future<List<GmssStone>> _future;
  bool showOnlyWithImages = false;
  bool quickShipping = false;
  bool isGridView = true;
  final List<GmssStone> _savedStones = [];
  final List<GmssStone> _recentlyViewed = [];
  String selectedShape = 'Round';
  int selectedShapeId = 1;
  RangeValues _caratRange = const RangeValues(0.0, 15.00);
  RangeValues _priceRange = const RangeValues(0.0, 100000);
  int _currentTab = 0;
  bool showAdvancedFilters = false;
  List<String> selectedCerts = [];
  List<String> certLabels = ["GIA", "IGI", "HRD"];
  RangeValues _certRange = const RangeValues(0, 2);
  final List<String> symLabels = ["FAIR", "GOOD", "VERY GOOD", "EXCELLENT"];
  RangeValues _symRange = const RangeValues(0, 3);
  RangeValues _depthRange = const RangeValues(0, 90);
  RangeValues _tableRange = const RangeValues(0, 90);
  final List<String> cutLabels = [
    "IDEAL",
    "EXCELLENT",
    "VERY GOOD",
    "GOOD",
    "FAIR",
  ];
  final List<String> polishLabels = ["EXCELLENT", "VERY GOOD", "GOOD", "FAIR"];
  final List<String> flLabels = ["NONE", "FAINT", "MEDIUM", "STRONG"];
  RangeValues _cutRange = const RangeValues(0, 4);
  RangeValues _polishRange = const RangeValues(0, 3);
  RangeValues _flRange = const RangeValues(0, 3);
  final List<String> shadeLabels = [
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
  ];
  RangeValues _colorRange = const RangeValues(0, 8);
  final List<String> clarityLabels = [
    "FL",
    "IF",
    "VVS1",
    "VVS2",
    "VS1",
    "VS2",
    "SI1",
    "SI2",
    "I1",
  ];
  RangeValues _clarityRange = const RangeValues(0, 8);
  List<GmssStone>? _lastRetrievedData;
  int selectedOrigin = 1;
  final String baseAssetUrl = "https://dev2.kodllin.com/";
  static const String shapeBaseUrl =
      "https://demo.kodllin.com/apis/storage/app/shape_images/";
  final List<Map<String, dynamic>> shapeCategories = [
    {'id': 1, 'name': 'Round', 'icon': '${shapeBaseUrl}Round.svg'},
    {'id': 2, 'name': 'Princess', 'icon': '${shapeBaseUrl}Princess.svg'},
    {'id': 3, 'name': 'Emerald', 'icon': '${shapeBaseUrl}Emerald.svg'},
    {'id': 4, 'name': 'Cushion', 'icon': '${shapeBaseUrl}Cushion.svg'},
    {'id': 5, 'name': 'Radiant', 'icon': '${shapeBaseUrl}L%20Radiant.svg'},
    {'id': 6, 'name': 'Marquise', 'icon': '${shapeBaseUrl}Marquise.svg'},
    {'id': 7, 'name': 'Pear', 'icon': '${shapeBaseUrl}Pear.svg'},
    {'id': 8, 'name': 'Oval', 'icon': '${shapeBaseUrl}Oval.svg'},
    {'id': 9, 'name': 'Heart', 'icon': '${shapeBaseUrl}Heart.svg'},
    {'id': 27, 'name': 'Asscher', 'icon': '${shapeBaseUrl}1_sf_1734065506.svg'},
    {'id': -1, 'name': 'Other', 'icon': '${shapeBaseUrl}white/Other.svg'},
  ];
  final List<Map<String, dynamic>> otherShapes = [
    {'id': 10, 'name': 'Rose', 'icon': '${shapeBaseUrl}Other.svg'},
    {'id': 11, 'name': 'Baguette', 'icon': '${shapeBaseUrl}Other.svg'},
    {'id': 23, 'name': 'SQ Radiant', 'icon': '${shapeBaseUrl}Sq%20Radiant.svg'},
    {
      'id': 38,
      'name': 'SQ Emerald',
      'icon': '${shapeBaseUrl}1_sf_1734065422.svg',
    },
    {
      'id': 43,
      'name': 'Half Moon',
      'icon': '${shapeBaseUrl}1_sf_1734074276.svg',
    },
    {
      'id': 44,
      'name': 'Trapezoid',
      'icon': '${shapeBaseUrl}1_sf_1734074928.svg',
    },
    {
      'id': 47,
      'name': 'Pentagonal',
      'icon': '${shapeBaseUrl}1_sf_1734074321.svg',
    },
    {
      'id': 48,
      'name': 'Hexagonal',
      'icon': '${shapeBaseUrl}1_sf_1734074309.svg',
    },
    {
      'id': 50,
      'name': 'Triangular',
      'icon': '${shapeBaseUrl}1_sf_1734074973.svg',
    },
    {
      'id': 51,
      'name': 'Trilliant',
      'icon': '${shapeBaseUrl}1_sf_1734074959.svg',
    },
    {'id': 53, 'name': 'Shield', 'icon': '${shapeBaseUrl}1_sf_1734075003.svg'},
    {'id': 54, 'name': 'Lozenge', 'icon': '${shapeBaseUrl}1_sf_1734075016.svg'},
    {'id': 55, 'name': 'Kite', 'icon': '${shapeBaseUrl}1_sf_1734075038.svg'},
    {
      'id': 77,
      'name': 'Portuguese',
      'icon': '${shapeBaseUrl}50_sf_1737092508.svg',
    },
  ];

  // Future<List<GmssStone>> _getSmartData() async {
  //   int shapeId = selectedShapeId;
  //   String? apiShapeName = (selectedShape == "Other") ? null : selectedShape;
  //
  //   // ૧. કેશ ચેક: ફક્ત પહેલા પેજ માટે અને જો લિસ્ટ ખાલી હોય તો જ
  //   if (_currentPage == 1 && _displayedStones.isEmpty) {
  //     Map<int, List<GmssStone>> targetCache = (selectedOrigin == 1)
  //         ? _cachedLabGrownMap
  //         : _cachedNaturalMap;
  //
  //     if (targetCache.containsKey(shapeId)) {
  //       _displayedStones = targetCache[shapeId]!;
  //       // અહીં રિટર્ન નથી કરવાનું, API કોલ ચાલુ રાખવો જેથી ટોટલ કાઉન્ટ અપડેટ થાય
  //     }
  //   }
  //
  //   // ૨. API કોલ
  //   final Map<String, dynamic> responseMap = (selectedOrigin == 1)
  //       ? await GmssApiService.fetchLabGrownData(
  //           shapeName: apiShapeName,
  //           page: _currentPage,
  //         )
  //       : await GmssApiService.fetchNaturalData(
  //           shapeName: apiShapeName,
  //           page: _currentPage,
  //         );
  //
  //   final List<GmssStone> newData = responseMap['stones'];
  //   final int totalFromApi = responseMap['total'];
  //
  //   if (mounted) {
  //     setState(() {
  //       _totalStonesFromApi = totalFromApi; // API માંથી આવતો સાચો કાઉન્ટ
  //       _displayedStones = newData; // ફક્ત નવા ૧૦૦ ડેટા
  //       if (_currentPage == 1) {
  //         if (selectedOrigin == 1)
  //           _cachedLabGrownMap[shapeId] = newData;
  //         else
  //           _cachedNaturalMap[shapeId] = newData;
  //       }
  //     });
  //   }
  //   return newData;
  // }
  Future<List<GmssStone>> _getSmartData({bool isLoadMore = false}) async {
    int shapeId = selectedShapeId;

    if (!isLoadMore) {
      _localVisibleCount = 6;
    }

    Map<int, Map<String, dynamic>> targetCache = (selectedOrigin == 1)
        ? _cachedLabGrownMap
        : _cachedNaturalMap;

    if (!targetCache.containsKey(shapeId)) {
      final Map<String, dynamic> responseMap = (selectedOrigin == 1)
          ? await GmssApiService.fetchLabGrownData(shapeName: selectedShape)
          : await GmssApiService.fetchNaturalData(shapeName: selectedShape);

      targetCache[shapeId] = {
        'stones': responseMap['stones'],
        'total': responseMap['total'],
      };
    }

    _refreshDisplayedStones();
    return _displayedStones;
  }

  void _refreshDisplayedStones() {
    if (!mounted) return;
    int shapeId = selectedShapeId;
    Map<int, Map<String, dynamic>> targetCache = (selectedOrigin == 1)
        ? _cachedLabGrownMap
        : _cachedNaturalMap;

    List<GmssStone> allCachedStones = targetCache[shapeId]?['stones'] ?? [];
    int totalFromApi = targetCache[shapeId]?['total'] ?? 0;
    if (totalFromApi == 0 && allCachedStones.isNotEmpty) {
      totalFromApi = allCachedStones
          .length; // જો API માંથી ટોટલ 0 આવે તો લોકલ લિસ્ટની સાઇઝ વાપરો
    }

    List<GmssStone> filteredAllStones = _applyFiltering(allCachedStones);

    setState(() {
      _totalFilteredStonesCount = filteredAllStones.length;
      _totalStonesFromApi = totalFromApi;
      _displayedStones = filteredAllStones.take(_localVisibleCount).toList();
      _hasMoreData = _localVisibleCount < filteredAllStones.length;
      _isMoreLoading = false;
    });
  }

  void _handleLoadMore() {
    if (!_isMoreLoading && _hasMoreData) {
      setState(() {
        _isMoreLoading = true;
      });
      // થોડો સમય રાહ જોઈને સ્મૂથ લોડિંગનો અહેસાસ આપવા
      Future.delayed(const Duration(milliseconds: 300), () {
        _localVisibleCount += 6; // 5-6 નુ ગ્રુપ
        _refreshDisplayedStones();
      });
    }
  }

  // પેજ બદલવાનું ફંક્શન
  void _changePage(int newPage) {
    if (newPage < 1) return;
    int maxPages = (_totalStonesFromApi / 100).ceil();
    if (newPage > maxPages) return;

    setState(() {
      _currentPage = newPage;
      _displayedStones = []; // શિમર બતાવવા માટે લિસ્ટ ખાલી કરો

      // નવો Future ઓબ્જેક્ટ બનાવો (આનાથી જ ડેટા બદલાશે)
      _future = _getSmartData();
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Future<void> _loadNextPage() async {
    if (_isMoreLoading) return;

    setState(() => _isMoreLoading = true);
    _currentPage++;

    final response = await GmssApiService.fetchLabGrownData(
      shapeName: selectedShape,
      page: _currentPage,
    );

    setState(() {
      _displayedStones.addAll(response['stones']);
      _isMoreLoading = false;
    });
  }

  void _updateTotalCount(int count) {
    if (mounted) setState(() => _totalStonesFromApi = count);
  }

  StreamSubscription? _storageSubscription;

  void _scrollListener() {
    // જો યુઝર લિસ્ટના અંતથી 300 પિક્સેલ નજીક હોય, તો નવો ડેટા મંગાવો
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (!_isMoreLoading && _hasMoreData && _currentTab == 0) {
        _handleLoadMore();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener); // સ્ક્રોલ લિસનર ઉમેર્યું
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _future = _getSmartData();
    _startGentlePrefetch(); // ધીમે ધીમે બેકગ્રાઉન્ડમાં અન્ય શેપ મંગાવો
    _loadHistoryFromStorage();
    _loadSavedFromStorage();
    // html.window.onStorage.listen((html.StorageEvent e) {
    //   if (e.key == 'recent_history' || e.key == 'saved_stones') {
    //     _loadHistoryFromStorage();
    //     _loadSavedFromStorage();
    //   }
    // });
    _storageSubscription = html.window.onStorage.listen((html.StorageEvent e) {
      if (e.key == 'recent_history' || e.key == 'saved_stones') {
        if (mounted) {
          setState(() {
            _loadHistoryFromStorage();
            _loadSavedFromStorage();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener); // લિસનર રિમૂવ કરો
    _storageSubscription?.cancel(); // લિસનર બંધ કરો
    _shimmerController.stop(); // dispose કરતા પહેલા stop કરો
    _shimmerController.dispose();
    _scrollController.dispose(); // આ લાઈન ખાસ ઉમેરજો જો બાકી હોય તો
    super.dispose();
  }

  void _startGentlePrefetch() async {
    // મુખ્ય શેપ (Round સિવાયના) નું બેકગ્રાઉન્ડ ડાઉનલોડ
    final List<String> topShapes = [
      'Princess',
      'Emerald',
      'Cushion',
      'Radiant',
      'Marquise',
      'Pear',
      'Oval',
      'Heart',
      'Asscher',
    ];

    for (String shapeName in topShapes) {
      if (!mounted) break;
      // એક શેપ મંગાવતા પહેલા ૨ સેકન્ડ રાહ જુઓ જેથી નેટવર્ક ફ્રીઝ ન થાય અને UI સ્મૂથ રહે
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) break;

      try {
        final shapeInfo = shapeCategories.firstWhere(
          (s) => s['name'] == shapeName,
        );
        int shapeId = shapeInfo['id'];

        // Lab Grown પ્રીફેચ (હાલ પૂરતું Lab Grown જ મંગાવીએ, Natural જોતું હોય તો એ પણ મંગાવી શકાય)
        if (!_cachedLabGrownMap.containsKey(shapeId)) {
          final res = await GmssApiService.fetchLabGrownData(
            shapeName: shapeName,
          );
          if (mounted && res['stones'] != null) {
            _cachedLabGrownMap[shapeId] = {
              'stones': res['stones'],
              'total': res['total'],
            };
          }
        }
      } catch (e) {
        debugPrint("Gentle prefetch error for $shapeName: $e");
      }
    }
  }

  void _loadHistoryFromStorage() {
    final String? historyJson = html.window.localStorage['recent_history'];
    if (historyJson != null && historyJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(historyJson);
        if (mounted) {
          setState(() {
            _recentlyViewed.clear();
            _recentlyViewed.addAll(
              decoded.map((e) {
                bool labFlag =
                    e['stoneName']?.toString().contains("LAB") ?? true;
                return GmssStone.fromJson(e, isLab: labFlag);
              }).toList(),
            );
          });
        }
      } catch (e) {
        debugPrint("Error loading history: $e");
      }
    }
  }

  void _toggleSave(GmssStone stone) {
    setState(() {
      GmssStone.toggleSaveStone(stone);
      _loadSavedFromStorage();
      _loadHistoryFromStorage();
    });
  }

  void _loadSavedFromStorage() {
    final List<GmssStone> saved = GmssStone.loadSavedStones();
    if (mounted) {
      setState(() {
        _savedStones.clear();
        _savedStones.addAll(saved);
      });
    }
  }

  void _handleCardTap(GmssStone stone) {
    html.window.localStorage['selected_stone_data'] = jsonEncode(
      stone.toJson(),
    );
    GmssStone.addToHistory(stone);
    _loadHistoryFromStorage();

    // final String url =
    //     "${html.window.location.origin}/#/details?id=${stone.id}";
    // html.window.open(url, "_blank");
    final String url =
        "${html.window.location.origin}/#/details?id=${stone.id}";

    // નવી ટેબ ખોલો, બ્રાઉઝર આપોઆપ ત્યાં જ ફોકસ કરશે
    // html.window.open(url, "_blank");

    // નવી ટેબને બદલે આ જ ટેબમાં ખોલો
    Navigator.pushNamed(context, '/details', arguments: stone.id);
  }

  List<GmssStone> _applyFiltering(List<GmssStone> allStones) {
    final String searchShapeUpper = selectedShape.toUpperCase().trim();
    final String searchFancyUpper = selectedFancyColor?.toUpperCase() ?? "";
    const cutMapping = {
      'ID': 0, // IDEAL
      'EX': 1, // EXCELLENT
      'VG': 2, // VERY GOOD
      'GD': 3, // GOOD
      'FR': 4, // FAIR
    };
    const polishMapping = {
      'EX': 0, // EXCELLENT (Matches your first label)
      'VG': 1, // VERY GOOD
      'GD': 2, // GOOD
      'FR': 3, // FAIR
    };
    const symMapping = {
      'EX': 3, // EXCELLENT
      'VG': 2, // VERY GOOD
      'GD': 1, // GOOD
      'FAIR': 0, // FAIR
      'PR': 0, // POOR (Mapping Poor to the start of the slider)
      'POOR': 0,
    };
    const flMapping = {
      'NONE': 0,
      'NON': 0,
      'VERY SLIGHT': 0,
      'SLIGHT': 1,
      'FAINT': 1,
      'FNT': 1,
      'MEDIUM': 2,
      'MED': 2,
      'STRONG': 3,
      'STG': 3,
      'VERY STRONG': 3,
      'VST': 3,
    };
    return allStones.where((stone) {
      // --- 2. ORIGIN CHECK (Fastest) ---
      final bool matchesOrigin = (selectedOrigin == 1)
          ? stone.isLab
          : !stone.isLab;
      if (!matchesOrigin) return false;

      // --- 3. SHAPE CHECK ---
      bool matchesShape = (searchShapeUpper == "OTHER")
          ? stone.shapeStr.toUpperCase() != "ROUND"
          : (selectedShapeId <= 0 || searchShapeUpper == "ALL")
          ? true
          : stone.shapeStr.toUpperCase().contains(searchShapeUpper);
      if (!matchesShape) return false;

      // --- 4. CARAT & PRICE RANGE ---
      if (stone.weight < _caratRange.start || stone.weight > _caratRange.end)
        return false;
      if (stone.total_price < _priceRange.start ||
          stone.total_price > _priceRange.end)
        return false;

      // --- 5. COLOR / FANCY LOGIC ---
      bool isStoneFancy =
          stone.colorStr.toLowerCase().contains("fancy") ||
          (stone.fancy_color.isNotEmpty);

      if (isFancySearch) {
        if (selectedFancyColorId == null) {
          if (!isStoneFancy) return false;
        } else {
          bool colorMatch =
              (stone.id == selectedFancyColorId) ||
              stone.colorStr.toUpperCase().contains(searchFancyUpper) ||
              stone.fancy_color.toUpperCase().contains(searchFancyUpper);
          if (!colorMatch) return false;
        }

        // Saturation
        String intensitySearchString = "${stone.fancy_color} ${stone.colorStr}"
            .toUpperCase();
        int stoneIntensityIdx = saturationLabels.indexWhere(
          (label) => intensitySearchString.contains(label.toUpperCase()),
        );
        if (stoneIntensityIdx != -1) {
          if (stoneIntensityIdx < _saturationRange.start.toInt() ||
              stoneIntensityIdx > _saturationRange.end.toInt())
            return false;
        }
      } else {
        if (isStoneFancy) return false; // નોર્મલ સર્ચમાં ફેન્સી ડાયમંડ ના બતાવો

        int colorIdx = shadeLabels.indexOf(stone.colorStr.trim().toUpperCase());
        if (colorIdx != -1) {
          if (colorIdx < _colorRange.start.toInt() ||
              colorIdx > _colorRange.end.toInt())
            return false;
        }
      }

      // --- 6. CLARITY ---
      int stoneClarityIdx = clarityLabels.indexOf(
        stone.clarityStr.trim().toUpperCase(),
      );
      if (stoneClarityIdx != -1) {
        if (stoneClarityIdx < _clarityRange.start.toInt() ||
            stoneClarityIdx > _clarityRange.end.toInt())
          return false;
      }

      // --- 7. CUT GRADE ---
      String cutCode = stone.cut_code.trim().toUpperCase();
      int stoneCutIdx =
          cutMapping[cutCode] ??
          cutLabels.indexOf(stone.cut.trim().toUpperCase());
      if (stoneCutIdx != -1) {
        if (stoneCutIdx < _cutRange.start.toInt() ||
            stoneCutIdx > _cutRange.end.toInt())
          return false;
      }

      // --- 8. POLISH ---
      String pCode = stone.polish.trim().toUpperCase();
      int stonePolishIdx = polishMapping[pCode] ?? polishLabels.indexOf(pCode);
      if (stonePolishIdx != -1) {
        if (stonePolishIdx < _polishRange.start.toInt() ||
            stonePolishIdx > _polishRange.end.toInt())
          return false;
      }

      // --- 9. SYMMETRY ---
      String sCode = stone.symmetry.trim().toUpperCase();
      int stoneSymIdx = symMapping[sCode] ?? symLabels.indexOf(sCode);
      if (stoneSymIdx != -1) {
        if (stoneSymIdx < _symRange.start.toInt() ||
            stoneSymIdx > _symRange.end.toInt())
          return false;
      }
      // --- 10. FLUORESCENCE (ADDED HERE) ---
      String flIntensity = stone.fl_intensity.trim().toUpperCase();
      int stoneFlIdx = flMapping[flIntensity] ?? flLabels.indexOf(flIntensity);
      if (stoneFlIdx != -1) {
        if (stoneFlIdx < _flRange.start.toInt() ||
            stoneFlIdx > _flRange.end.toInt())
          return false;
      }
      // --- 11. MEASUREMENTS (Depth/Table) ---
      if (stone.depth != 0 &&
          (stone.depth < _depthRange.start || stone.depth > _depthRange.end))
        return false;
      if (stone.table != 0 &&
          (stone.table < _tableRange.start || stone.table > _tableRange.end))
        return false;

      return true; // Diamond passed all tests!
    }).toList();
    // final List<GmssStone> filtered = allStones.where((stone) {
    //   bool matchesColor = false;
    //   if (isFancySearch) {
    //     bool isStoneFancy =
    //         stone.colorStr.toLowerCase().contains("fancy") ||
    //         (stone.fancy_color != null && stone.fancy_color.isNotEmpty);
    //     if (selectedFancyColorId == null) {
    //       matchesColor = isStoneFancy;
    //     } else {
    //       String searchColor = selectedFancyColor?.toUpperCase() ?? "";
    //       matchesColor =
    //           (stone.id == selectedFancyColorId) ||
    //           stone.colorStr.toUpperCase().contains(searchColor) ||
    //           stone.fancy_color.toUpperCase().contains(searchColor);
    //     }
    //     int stoneIntensityIdx = -1;
    //
    //     String intensitySearchString = "${stone.fancy_color} ${stone.colorStr}"
    //         .toUpperCase();
    //
    //     stoneIntensityIdx = saturationLabels.indexWhere(
    //       (label) => intensitySearchString.contains(label.toUpperCase()),
    //     );
    //
    //     if (stoneIntensityIdx != -1) {
    //       bool matchesSaturation =
    //           (stoneIntensityIdx >= _saturationRange.start.toInt() &&
    //           stoneIntensityIdx <= _saturationRange.end.toInt());
    //       if (!matchesSaturation) return false;
    //     }
    //   } else {
    //     int colorIdx = shadeLabels.indexOf(stone.colorStr.trim().toUpperCase());
    //     matchesColor =
    //         (colorIdx >= _colorRange.start.toInt() &&
    //         colorIdx <= _colorRange.end.toInt());
    //   }
    //   // 2. Clarity Logic
    //   int stoneClarityIdx = clarityLabels.indexOf(
    //     stone.clarityStr.trim().toUpperCase(),
    //   );
    //   bool matchesClarity =
    //       (stoneClarityIdx >= _clarityRange.start.toInt() &&
    //       stoneClarityIdx <= _clarityRange.end.toInt());
    //   // 1. CUT LOGIC
    //   int stoneCutIdx = -1;
    //
    //   String code = stone.cut_code.trim().toUpperCase();
    //   if (cutMapping.containsKey(code)) {
    //     stoneCutIdx = cutMapping[code]!;
    //   } else {
    //     stoneCutIdx = cutLabels.indexOf(stone.cut.trim().toUpperCase());
    //   }
    //   bool matchesCut =
    //       (stoneCutIdx >= _cutRange.start.toInt() &&
    //       stoneCutIdx <= _cutRange.end.toInt());
    //   if (stoneCutIdx == -1) matchesCut = true;
    //   // 2. POLISH LOGIC
    //   int stonePolishIdx = -1;
    //
    //   String polishCode = stone.polish.trim().toUpperCase();
    //   if (polishMapping.containsKey(polishCode)) {
    //     stonePolishIdx = polishMapping[polishCode]!;
    //   } else {
    //     stonePolishIdx = polishLabels.indexOf(polishCode);
    //   }
    //   bool matchesPolish =
    //       (stonePolishIdx >= _polishRange.start.toInt() &&
    //       stonePolishIdx <= _polishRange.end.toInt());
    //   if (stonePolishIdx == -1) matchesPolish = true;
    //   //  3. FLUORESCENCE LOGIC
    //   int stoneFlIdx = -1;
    //
    //   String intensity = stone.fl_intensity.trim().toUpperCase();
    //   if (flMapping.containsKey(intensity)) {
    //     stoneFlIdx = flMapping[intensity]!;
    //   } else {
    //     stoneFlIdx = flLabels.indexOf(intensity);
    //   }
    //   bool matchesFl =
    //       (stoneFlIdx >= _flRange.start.toInt() &&
    //       stoneFlIdx <= _flRange.end.toInt());
    //   if (stoneFlIdx == -1) matchesFl = true;
    //   // 5. SYMMETRY LOGIC
    //   int stoneSymIdx = -1;
    //
    //   String symmetryCode = stone.symmetry.trim().toUpperCase();
    //   if (symMapping.containsKey(symmetryCode)) {
    //     stoneSymIdx = symMapping[symmetryCode]!;
    //   } else {
    //     stoneSymIdx = symLabels.indexOf(symmetryCode);
    //   }
    //   bool matchesSym =
    //       (stoneSymIdx >= _symRange.start.toInt() &&
    //       stoneSymIdx <= _symRange.end.toInt());
    //   if (stoneSymIdx == -1) matchesSym = true;
    //   // 6. DEPTH % LOGIC
    //   double stoneDepth = 0.0;
    //   if (stone.depth is String) {
    //     stoneDepth = double.tryParse(stone.depth as String) ?? 0.0;
    //   } else {
    //     stoneDepth = stone.depth.toDouble();
    //   }
    //   bool matchesDepth =
    //       (stoneDepth >= _depthRange.start && stoneDepth <= _depthRange.end);
    //   if (stoneDepth == 0) matchesDepth = true;
    //   // 7. TABLE % LOGIC
    //   double stoneTable = 0.0;
    //   if (stone.table is String) {
    //     stoneTable = double.tryParse(stone.table as String) ?? 0.0;
    //   } else {
    //     stoneTable = (stone.table as num).toDouble();
    //   }
    //   bool matchesTable =
    //       (stoneTable >= _tableRange.start && stoneTable <= _tableRange.end);
    //   if (stoneTable == 0) matchesTable = true;
    //
    //   final bool matchesShape = (searchShapeUpper == "OTHER")
    //       ? stone.shapeStr.toUpperCase() != "ROUND"
    //       : (selectedShapeId <= 0 || selectedShape == "ALL")
    //       ? true
    //       : stone.shapeStr.toUpperCase().contains(searchShapeUpper);
    //   if (!matchesShape) return false;
    //
    //   // final bool matchesShape =
    //   //     (selectedShapeId <= 0 ||
    //   //         selectedShape == "ALL" ||
    //   //         selectedShape == "Other")
    //   //     ? true
    //   //     : stone.shapeStr.toUpperCase().contains(
    //   //         selectedShape.toUpperCase().trim(),
    //   //       );
    //   final bool matchesCarat =
    //       stone.weight >= _caratRange.start && stone.weight <= _caratRange.end;
    //   final bool matchesPrice =
    //       stone.total_price >= _priceRange.start &&
    //       stone.total_price <= _priceRange.end;
    //   final String stoneName = (stone.stoneName).toUpperCase();
    //   // final bool matchesOrigin = (selectedOrigin == 1)
    //   //     ? (stoneName.contains("LAB") || stoneName.contains("LGD"))
    //   //     : (stoneName.contains("NATURAL") || stoneName.contains("NAT"));
    //   final bool matchesOrigin = (selectedOrigin == 1)
    //       ? stone.isLab
    //       : !stone.isLab;
    //   return matchesShape &&
    //       matchesCarat &&
    //       matchesPrice &&
    //       matchesColor &&
    //       matchesOrigin &&
    //       matchesClarity &&
    //       matchesCut &&
    //       matchesPolish &&
    //       matchesFl &&
    //       matchesSym &&
    //       matchesDepth &&
    //       matchesTable;
    // }).toList();
    // return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = (selectedOrigin == 1)
        ? Colors.teal
        : Colors.blue.shade700;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 340,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade100)),
            ),
            child: SingleChildScrollView(
              child: SidebarFilters(
                themeColor: themeColor,
                selectedOrigin: selectedOrigin,
                isFancySearch: isFancySearch,
                caratRange: _caratRange,
                priceRange: _priceRange,
                colorRange: _colorRange,
                clarityRange: _clarityRange,
                showOnlyWithImages: showOnlyWithImages,
                quickShipping: quickShipping,
                showAdvancedFilters: showAdvancedFilters,
                cutRange: _cutRange,
                polishRange: _polishRange,
                flRange: _flRange,
                certRange: _certRange,
                symRange: _symRange,
                depthRange: _depthRange,
                tableRange: _tableRange,
                selectedFancyColorId: selectedFancyColorId,
                isFancyExpanded: isFancyExpanded,
                saturationRange: _saturationRange,
                fancyColors: fancyColors,
                saturationLabels: saturationLabels,
                selectedShape: selectedShape,
                shadeLabels: shadeLabels,
                clarityLabels: clarityLabels,
                cutLabels: cutLabels,
                polishLabels: polishLabels,
                flLabels: flLabels,
                certLabels: certLabels,
                symLabels: symLabels,
                onOriginChanged: (val) {
                  setState(() {
                    selectedOrigin = val;
                    _currentPage = 1; // પેજ ૧ કરો
                    _displayedStones = []; // લિસ્ટ ખાલી કરો
                    _totalStonesFromApi = 0; // નવો ડેટા આવે ત્યાં સુધી 0 બતાવો
                    _hasMoreData = true;
                    _future = _getSmartData(
                      isLoadMore: false,
                    ); // નવો ડેટા મંગાવો
                  });
                },
                onCaratChanged: (val) {
                  setState(() => _caratRange = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onPriceChanged: (val) {
                  setState(() => _priceRange = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onColorChanged: (val) {
                  setState(() => _colorRange = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onClarityChanged: (val) {
                  setState(() => _clarityRange = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onImageToggle: (val) {
                  setState(() => showOnlyWithImages = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onShippingToggle: (val) {
                  setState(() => quickShipping = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onAdvancedToggle: () =>
                    setState(() => showAdvancedFilters = !showAdvancedFilters),
                onCutChanged: (val) {
                  setState(() => _cutRange = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onPolishChanged: (val) {
                  setState(() => _polishRange = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onFlChanged: (val) {
                  setState(() => _flRange = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onCertChanged: (val) {
                  setState(() => _certRange = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onSymChanged: (val) {
                  setState(() => _symRange = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onDepthChanged: (val) {
                  setState(() => _depthRange = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onTableChanged: (val) {
                  setState(() => _tableRange = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onFancyColorTap: (id, name) {
                  setState(() {
                    selectedFancyColorId = id;
                    selectedFancyColor = name;
                    _localVisibleCount = 6;
                  });
                  _refreshDisplayedStones();
                },
                onFancyExpandToggle: () =>
                    setState(() => isFancyExpanded = !isFancyExpanded),
                onSaturationChanged: (val) {
                  setState(() => _saturationRange = val);
                  _localVisibleCount = 6;
                  _refreshDisplayedStones();
                },
                onReset: () {
                  setState(() {
                    showOnlyWithImages = false;
                    quickShipping = false;
                    _caratRange = const RangeValues(0.0, 15.0);
                    _priceRange = const RangeValues(0.0, 100000.0);
                    selectedOrigin = 1;
                    _colorRange = const RangeValues(0, 8);
                    selectedShape = 'Round';
                    selectedShapeId = 1;
                    selectedFancyColorId = null;
                    selectedFancyColor = null;
                    isFancySearch = false;
                    _localVisibleCount = 6;
                    _future = _getSmartData();
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: MainHeader(
                    themeColor: themeColor,
                    shapeCategories: shapeCategories,
                    onNaturalDiamondsTap: () {
                      setState(() {
                        isFancySearch = false;
                      });
                    },
                    onFancyDiamondsTap: (colorName) {
                      setState(() {
                        isFancySearch = true;
                        _currentTab = 0;
                        if (colorName != null) {
                          final foundColor = fancyColors.firstWhere(
                            (c) =>
                                c['name'].toString().toLowerCase() ==
                                colorName.toLowerCase(),
                            orElse: () => {'id': null},
                          );
                          selectedFancyColor = colorName;
                          selectedFancyColorId = foundColor['id'];
                        } else {
                          selectedFancyColor = null;
                          selectedFancyColorId = null;
                        }
                        _future = _getSmartData();
                      });
                    },
                    onShapeTap: (shapeName, shapeId) {
                      if (selectedShapeId == shapeId) return;
                      setState(() {
                        selectedShape = shapeName;
                        selectedShapeId = shapeId;
                        _currentPage = 1;
                        _displayedStones = [];
                        _totalStonesFromApi =
                            0; // નવો ડેટા આવે ત્યાં સુધી 0 બતાવો
                        _hasMoreData = true;
                        _future = _getSmartData(isLoadMore: false);
                      });

                      // ફક્ત શેપ બદલાય ત્યારે જ પેજને ઉપર લઈ જવું
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0);
                      }
                    },
                  ),
                ),
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildShapeSelector(shapeCategories)),

                FutureBuilder<List<GmssStone>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      _lastRetrievedData = snapshot.data;
                    }
                    final allStones = snapshot.data ?? _lastRetrievedData ?? [];
                    final filteredCount = _applyFiltering(
                      _displayedStones,
                    ).length;

                    final filteredCompareCount = _savedStones.where((stone) {
                      bool matchesShape = stone.shapeStr.toLowerCase().contains(
                        selectedShape.toLowerCase().trim(),
                      );
                      final String stoneName = stone.stoneName.toUpperCase();
                      bool matchesOrigin = (selectedOrigin == 1)
                          ? (stoneName.contains("LAB") ||
                                stoneName.contains("LGD"))
                          : (stoneName.contains("NATURAL") ||
                                stoneName.contains("NAT"));
                      return matchesShape && matchesOrigin;
                    }).length;
                    return SliverToBoxAdapter(
                      child: _buildUnifiedInventoryToolbar(
                        mainCount: _totalStonesFromApi,
                        historyCount: _recentlyViewed.length,
                        compareCount: filteredCompareCount,
                        themeColor: themeColor,
                      ),
                    );
                  },
                ),

                // FutureBuilder<List<GmssStone>>(
                //   future: _future,
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting &&
                //         _displayedStones.isEmpty) {
                if (_displayedStones.isEmpty && _currentPage == 1)
                  // જ્યારે પહેલી વાર ડેટા લોડ થતો હોય ત્યારે જ Skeleton બતાવવું
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.87,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (c, i) => _buildSkeletonCard(),
                        childCount: 8,
                      ),
                    ),
                  ),
                if (_displayedStones.isNotEmpty || _currentPage > 1)
                  SliverPadding(
                    key: ValueKey("page-$selectedShapeId"),
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 20,
                    ),
                    sliver: isGridView
                        ? SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 300,
                                  childAspectRatio: 0.92,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                // અહીં ફિલ્ટરિંગ લોજિક મુજબ ડેટા ફિલ્ટર કરવો
                                // ડેટા સોર્સ તરીકે _displayedStones જ વાપરો
                                final List<GmssStone> sourceData =
                                    _displayedStones;
                                final List<GmssStone> filteredStones =
                                    _currentTab == 0
                                    ? _applyFiltering(sourceData)
                                    : (_currentTab == 1
                                          ? _recentlyViewed
                                          : _savedStones);

                                // જો ડેટા લોડ થઈ ગયો હોય પણ ખાલી હોય
                                // if (snapshot.connectionState == ConnectionState.done &&
                                //     filteredStones.isEmpty) {
                                //   return const SliverToBoxAdapter(
                                //     child: Center(
                                //       child: Padding(
                                //         padding: EdgeInsets.all(100),
                                //         child: Text(
                                //           "No diamonds found matching your filters.",
                                //         ),
                                //       ),
                                //     ),
                                //   );
                                // }
                                if (index >= filteredStones.length) return null;

                                final stone = filteredStones[index];
                                // return SliverPadding(
                                //   // પેજ નંબર સાથે કી જોડો જેથી Flutter દર વખતે નવું લિસ્ટ રેન્ડર કરે
                                //   key: ValueKey("page-$_currentPage-$selectedShapeId"),
                                //   padding: const EdgeInsets.only(
                                //     left: 24,
                                //     right: 24,
                                //     bottom: 20,
                                //   ),
                                //   sliver: isGridView
                                //       ? SliverGrid(
                                //           gridDelegate:
                                //               const SliverGridDelegateWithMaxCrossAxisExtent(
                                //                 maxCrossAxisExtent: 300,
                                //                 childAspectRatio: 0.92,
                                //                 crossAxisSpacing: 15,
                                //                 mainAxisSpacing: 15,
                                //               ),
                                //           delegate: SliverChildBuilderDelegate((
                                //             context,
                                //             index,
                                //           ) {
                                //             final stone = filteredStones[index];
                                return DiamondCard(
                                  key: ValueKey(
                                    "diamond-${stone.stockNo}",
                                  ), // ફક્ત સ્ટોક નંબર સાથે કી જોડો
                                  stone: stone,
                                  isFavorite: _savedStones.any(
                                    (s) => s.stockNo == stone.stockNo,
                                  ),
                                  onFavoriteTap: () => _toggleSave(stone),
                                  onCardTap: () => _handleCardTap(stone),
                                  themeColor: themeColor,
                                );
                              },
                              childCount:
                                  (_currentTab == 0
                                          ? _applyFiltering(_displayedStones)
                                          : (_currentTab == 1
                                                ? _recentlyViewed
                                                : _savedStones))
                                      .length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final List<GmssStone> sourceData =
                                    _displayedStones;
                                final List<GmssStone> filteredStones =
                                    _currentTab == 0
                                    ? _applyFiltering(sourceData)
                                    : (_currentTab == 1
                                          ? _recentlyViewed
                                          : _savedStones);
                                return _buildDiamondRow(
                                  filteredStones[index],
                                  themeColor,
                                );
                              },
                              childCount:
                                  (_currentTab == 0
                                          ? _applyFiltering(_displayedStones)
                                          : (_currentTab == 1
                                                ? _recentlyViewed
                                                : _savedStones))
                                      .length,
                            ),
                          ),
                  ),
                // },
                // ),
                // SliverToBoxAdapter(
                //   child: (_currentTab != 0 || _totalStonesFromApi == 0)
                //       ? const SizedBox.shrink()
                //       : Container(
                //           padding: const EdgeInsets.symmetric(vertical: 40),
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               IconButton(
                //                 onPressed: _currentPage > 1
                //                     ? () => _changePage(_currentPage - 1)
                //                     : null,
                //                 icon: const Icon(
                //                   Icons.arrow_back_ios,
                //                   size: 18,
                //                 ),
                //                 color: themeColor,
                //               ),
                //               const SizedBox(width: 10),
                //               Container(
                //                 padding: const EdgeInsets.symmetric(
                //                   horizontal: 20,
                //                   vertical: 10,
                //                 ),
                //                 decoration: BoxDecoration(
                //                   color: themeColor.withOpacity(0.1),
                //                   borderRadius: BorderRadius.circular(30),
                //                 ),
                //                 child: Text(
                //                   "Page $_currentPage of ${(_totalStonesFromApi / 100).ceil() == 0 ? 1 : (_totalStonesFromApi / 100).ceil()}",
                //                   style: TextStyle(
                //                     fontWeight: FontWeight.bold,
                //                     color: themeColor,
                //                   ),
                //                 ),
                //               ),
                //               const SizedBox(width: 10),
                //               IconButton(
                //                 onPressed:
                //                     _currentPage <
                //                         (_totalStonesFromApi / 100).ceil()
                //                     ? () => _changePage(_currentPage + 1)
                //                     : null,
                //                 icon: const Icon(
                //                   Icons.arrow_forward_ios,
                //                   size: 18,
                //                 ),
                //                 color: themeColor,
                //               ),
                //             ],
                //           ),
                //         ),
                // ),
                SliverToBoxAdapter(
                  child: (_currentTab != 0 || !_hasMoreData || !_isMoreLoading)
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Center(
                            child: CircularProgressIndicator(color: themeColor),
                          ),
                        ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalComparison(GmssStone stone) {
    final rowColor = stone.isLab ? Colors.teal : Colors.blue.shade900;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: rowColor.withOpacity(0.08), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: rowColor.withOpacity(0.02),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      stone.image_link,
                      height: 130,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Icon(
                        Icons.diamond_outlined,
                        size: 50,
                        color: rowColor.withOpacity(0.2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${stone.weight.toStringAsFixed(2)} CT ${stone.shapeStr}"
                      .toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.8,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: rowColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    stone.isLab ? "Lab Grown Diamonds" : "Natural Diamonds",
                    style: TextStyle(
                      color: rowColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                children: [
                  _compareDataTile("Color: ", stone.colorStr),
                  _compareDataTile("Clarity: ", stone.clarityStr),
                  _compareDataTile(
                    "Cut: ",
                    stone.cut.isEmpty ? "-" : stone.cut,
                  ),
                  _compareDataTile("Polish: ", stone.polish),
                  _compareDataTile("Symmetry: ", stone.symmetry),
                  _compareDataTile("Depth: ", "${stone.depth}%"),
                  _compareDataTile("Table: ", "${stone.table}%"),
                  _compareDataTile(
                    "Girdle: ",
                    stone.gridle_condition,
                    isLast: true,
                  ),
                  Text(
                    "\$${stone.total_price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 26,
                      color: rowColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: rowColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "ADD TO CART",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _handleCardTap(stone),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: rowColor.withOpacity(0.5),
                              width: 1.5,
                            ),
                            foregroundColor: rowColor,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "DETAILS",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  InkWell(
                    onTap: () => _toggleSave(stone),
                    child: Text(
                      "Remove from comparison",
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _compareDataTile(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.5),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade50, width: 1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF2D3142),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF2D3142),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        double value = (_shimmerController.value * 3.0) - 1.0;
        return Container(
          height: 350, // ચોક્કસ ઊંચાઈ સેટ કરો
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200, // ફિક્સ હાઇટ
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(height: 14, width: 140, color: Colors.white),
                      const SizedBox(height: 10),
                      Container(height: 12, width: 80, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 1,
            child: Text(
              "Compare",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Shape",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Carat",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Cut",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Color",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Clarity",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Report",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Price",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Actions",
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiamondRow(GmssStone stone, Color themeColor) {
    bool isFavorite = _savedStones.any((s) => s.id == stone.id);
    bool isCompareTab = _currentTab == 2;
    bool isExpanded = _expandedStoneStockNos.contains(stone.stockNo);
    final Color rowThemeColor = stone.isLab
        ? Colors.teal
        : Colors.blue.shade700;
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        color: Colors.white,
      ),
      child: InkWell(
        onTap: () {
          if (isCompareTab) {
            setState(() {
              if (_expandedStoneStockNos.contains(stone.stockNo)) {
                _expandedStoneStockNos.remove(stone.stockNo);
              } else {
                _expandedStoneStockNos.add(stone.stockNo);
              }
            });
          } else {
            _handleCardTap(stone);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () => _toggleSave(stone),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? rowThemeColor
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CustomPaint(
                            painter: DiamondPainterUtils.getPainterForShapeName(
                              stone.shapeStr,
                              false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          stone.shapeStr.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      stone.weight.toStringAsFixed(2),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      stone.cut.length >= 2
                          ? stone.cut.substring(0, 2).toUpperCase()
                          : (stone.cut.isEmpty ? "-" : stone.cut.toUpperCase()),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      stone.colorStr,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      stone.clarityStr,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      stone.lab,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "\$${stone.total_price.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: () => _handleCardTap(stone),
                      child: Text(
                        "Details",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: rowThemeColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isCompareTab && isExpanded) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSubDetail("Stock #: ", stone.stockNo),
                            _buildSubDetail(
                              "Report: ",
                              "${stone.lab} Certificate",
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: rowThemeColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                stone.isLab
                                    ? "Lab Grown Diamond"
                                    : "Natural Diamond",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSubDetail("Depth: ", "${stone.depth}%"),
                            _buildSubDetail("Table: ", "${stone.table}%"),
                            _buildSubDetail("Cut Grade: ", stone.cut),
                            _buildSubDetail(
                              "Measurements: ",
                              "${stone.length}x${stone.width}x${stone.depth} mm",
                            ),
                            _buildSubDetail(
                              "Girdle: ",
                              stone.gridle_condition.isEmpty
                                  ? "-"
                                  : stone.gridle_condition,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSubDetail("Polish: ", stone.polish),
                            _buildSubDetail("Symmetry: ", stone.symmetry),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: rowThemeColor,
                                minimumSize: const Size(double.infinity, 40),
                                shape: const RoundedRectangleBorder(),
                              ),
                              child: const Text(
                                "ADD TO CART",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => _handleCardTap(stone),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: rowThemeColor),
                                minimumSize: const Size(double.infinity, 40),
                                shape: const RoundedRectangleBorder(),
                              ),
                              child: Text(
                                "FULL DETAILS",
                                style: TextStyle(
                                  color: rowThemeColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, bottom: 10),
      child: Column(
        children: [
          Text(
            "${selectedOrigin == 1 ? 'Lab Grown' : 'Natural'} $selectedShape Diamonds",
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2D3142),
            ),
          ),
          const Text(
            "HAND-SELECTED BRILLIANCE",
            style: TextStyle(
              letterSpacing: 2,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeSelector(dynamic shapeCategories) {
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 0),
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: shapeCategories.length,
        itemBuilder: (context, index) {
          final s = shapeCategories[index];
          bool active = selectedShapeId == s['id'];
          final painter = DiamondPainterUtils.getPainterForShapeName(
            s['name'],
            active,
          );
          return GestureDetector(
            onTap: () {
              if (s['name'] == 'Other') {
                _showOtherShapesPopup();
              } else {
                setState(() {
                  selectedShapeId = s['id'];
                  selectedShape = s['name'];

                  // --- આ ૩ લાઈનો અહીં ઉમેરો ---
                  _currentPage = 1; // પેજ રીસેટ કરશે
                  _displayedStones = []; // લિસ્ટ ખાલી કરશે
                  _totalStonesFromApi = 0; // નવો ડેટા આવે ત્યાં સુધી 0 બતાવો
                  _hasMoreData = true; // નવો ડેટા લાવવા દેશે
                  // ----------------------------

                  _future = _getSmartData();
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 2),
              width: 90,
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: active ? Colors.teal : Colors.grey.shade200,
                  width: active ? 2 : 1,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: painter != null
                        ? CustomPaint(painter: painter)
                        : Icon(
                            Icons.diamond_outlined,
                            size: 24,
                            color: active ? Colors.teal : Colors.grey,
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s['name']!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: active ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOtherShapesPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "OtherShapes",
      transitionDuration: const Duration(milliseconds: 2),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              titlePadding: EdgeInsets.zero,
              title: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 24,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFB),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Browse More Shapes",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              content: Container(
                width: 500,
                padding: const EdgeInsets.only(top: 10),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.50,
                  ),
                  itemCount: otherShapes.length,
                  itemBuilder: (context, index) {
                    final shape = otherShapes[index];
                    return _buildShapeGridItem(shape);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShapeGridItem(Map<String, dynamic> shape) {
    bool isSelected = selectedShapeId == shape['id'];
    final painter = DiamondPainterUtils.getPainterForShapeName(
      shape['name'],
      isSelected,
    );
    return InkWell(
      onTap: () {
        setState(() {
          selectedShapeId = shape['id'];
          selectedShape = shape['name'];

          // --- આ ૩ લાઈનો અહીં ઉમેરો ---
          _currentPage = 1;
          _displayedStones = [];
          _totalStonesFromApi = 0; // નવો ડેટા આવે ત્યાં સુધી 0 બતાવો
          _hasMoreData = true;
          // -------------------------

          _future = _getSmartData();
        });
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.teal.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 45,
              width: 45,
              child: painter != null
                  ? CustomPaint(painter: painter)
                  : Icon(
                      Icons.diamond_outlined,
                      size: 32,
                      color: isSelected ? Colors.teal : Colors.grey,
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              shape['name'].toString().toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.teal : Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedInventoryToolbar({
    required int mainCount,
    required int historyCount,
    required int compareCount,
    required Color themeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Row(
        children: [
          const SizedBox(width: 96),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tabItem("Diamond", 0, mainCount, themeColor),
                const SizedBox(width: 30),
                _tabItem("Recently Viewed", 1, historyCount, themeColor),
                const SizedBox(width: 30),
                _tabItem("Compare", 2, compareCount, themeColor),
              ],
            ),
          ),
          if (_currentTab == 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.grid_view_rounded,
                    color: isGridView ? Colors.black : Colors.grey,
                  ),
                  onPressed: () => setState(() => isGridView = true),
                ),
                IconButton(
                  icon: Icon(
                    Icons.view_list_rounded,
                    color: !isGridView ? Colors.black : Colors.grey,
                  ),
                  onPressed: () => setState(() => isGridView = false),
                ),
              ],
            )
          else
            const SizedBox(width: 96),
        ],
      ),
    );
  }

  Widget _tabItem(String label, int index, int count, Color themeColor) {
    bool active = _currentTab == index;

    // અહીં આપણે નવું લખાણ બનાવીએ છીએ
    String displayCount = "";

    if (index == 0) {
      // ૧. ફિલ્ટર થયેલા ડેટાનો સાચો કુલ આંકડો વાપરો
      final filteredCount = _totalFilteredStonesCount;

      // માત્ર ફિલ્ટર થયેલો કાઉન્ટ જ બતાવો
      displayCount = "$filteredCount";
    } else {
      // બાકીની ટેબ માટે જૂનું લોજિક
      displayCount = "$count";
    }

    return InkWell(
      onTap: () {
        setState(() {
          _currentTab = index;

          if (index == 0) {
            isGridView = true;
          } else {
            isGridView = false;
          }
          if (index == 1) {
            _loadHistoryFromStorage();
          } else if (index == 2) {
            _loadSavedFromStorage();
          }
        });
      },
      child: Column(
        children: [
          Text(
            "$label ($displayCount)", // અહીં displayCount નો ઉપયોગ કર્યો
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: active ? Colors.black : Colors.grey,
              letterSpacing: 1,
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 20,
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
