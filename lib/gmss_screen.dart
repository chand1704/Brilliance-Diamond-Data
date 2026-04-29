import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:brilliance_diamond_data/model/gmss_stone_model.dart';
import 'package:brilliance_diamond_data/service/gmss_api_service.dart';
import 'package:brilliance_diamond_data/utils/diamond_painter_utils.dart';
import 'package:brilliance_diamond_data/widgets/diamond_card.dart';
import 'package:brilliance_diamond_data/widgets/main_header.dart';
import 'package:brilliance_diamond_data/widgets/sidebar_filters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GmssScreen extends StatefulWidget {
  const GmssScreen({super.key});
  @override
  State<GmssScreen> createState() => _GmssScreenState();
}

class _GmssScreenState extends State<GmssScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 1;
  int _localVisibleCount = 5;
  int _totalFilteredStonesCount = 0;
  bool _isMoreLoading = false;
  List<GmssStone> _displayedStones = [];
  List<GmssStone> _allFilteredStones = [];
  int _filteredCompareCount = 0;
  bool _isFiltering = false;
  bool _hasMoreData = true;
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
  Future<List<GmssStone>> _getSmartData({bool isLoadMore = false}) async {
    int shapeId = selectedShapeId;
    if (!isLoadMore) {
      _localVisibleCount = 6;
    }
    Map<int, Map<String, dynamic>> targetCache = (selectedOrigin == 1)
        ? _cachedLabGrownMap
        : _cachedNaturalMap;

    debugPrint(
      "--- SmartData: Shape=$selectedShape, Origin=${selectedOrigin == 1 ? 'Lab' : 'Natural'}, Cached=${targetCache.containsKey(shapeId)} ---",
    );

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

  void _refreshDisplayedStones() async {
    if (!mounted) return;
    int shapeId = selectedShapeId;
    Map<int, Map<String, dynamic>> targetCache = (selectedOrigin == 1)
        ? _cachedLabGrownMap
        : _cachedNaturalMap;
    List<GmssStone> allCachedStones = targetCache[shapeId]?['stones'] ?? [];
    int totalFromApi = targetCache[shapeId]?['total'] ?? 0;
    if (totalFromApi == 0 && allCachedStones.isNotEmpty) {
      totalFromApi = allCachedStones.length;
    }
    setState(() => _isFiltering = true);
    try {
      final filteredResults = await compute(_applyFilteringStatic, {
        'stones': allCachedStones,
        'params': {
          'selectedShape': selectedShape,
          'selectedShapeId': selectedShapeId,
          'selectedOrigin': selectedOrigin,
          'caratRangeStart': _caratRange.start,
          'caratRangeEnd': _caratRange.end,
          'priceRangeStart': _priceRange.start,
          'priceRangeEnd': _priceRange.end,
          'isFancySearch': isFancySearch,
          'selectedFancyColor': selectedFancyColor,
          'selectedFancyColorId': selectedFancyColorId,
          'colorRangeStart': _colorRange.start,
          'colorRangeEnd': _colorRange.end,
          'clarityRangeStart': _clarityRange.start,
          'clarityRangeEnd': _clarityRange.end,
          'cutRangeStart': _cutRange.start,
          'cutRangeEnd': _cutRange.end,
          'polishRangeStart': _polishRange.start,
          'polishRangeEnd': _polishRange.end,
          'symRangeStart': _symRange.start,
          'symRangeEnd': _symRange.end,
          'flRangeStart': _flRange.start,
          'flRangeEnd': _flRange.end,
          'depthRangeStart': _depthRange.start,
          'depthRangeEnd': _depthRange.end,
          'tableRangeStart': _tableRange.start,
          'tableRangeEnd': _tableRange.end,
          'shadeLabels': shadeLabels,
          'clarityLabels': clarityLabels,
          'cutLabels': cutLabels,
          'polishLabels': polishLabels,
          'symLabels': symLabels,
          'flLabels': flLabels,
        },
      });
      if (!mounted) return;
      setState(() {
        _allFilteredStones = filteredResults;
        _totalFilteredStonesCount = filteredResults.length;
        _totalStonesFromApi = totalFromApi;
        _filteredCompareCount = _savedStones.length;
        _displayedStones = _allFilteredStones.take(_localVisibleCount).toList();
        _hasMoreData = _localVisibleCount < _allFilteredStones.length;
        _isFiltering = false;
        _isMoreLoading = false;
      });
    } catch (e) {
      debugPrint("Error during filtering: $e");
      if (mounted) {
        setState(() {
          _isFiltering = false;
          _isMoreLoading = false;
        });
      }
    }
  }

  static List<GmssStone> _applyFilteringStatic(Map<String, dynamic> data) {
    final List<GmssStone> allStones = data['stones'];
    final Map<String, dynamic> p = data['params'];
    final String searchShapeUpper = p['selectedShape'].toString().toUpperCase();
    final double caratStart = p['caratRangeStart'];
    final double caratEnd = p['caratRangeEnd'];
    final double priceStart = p['priceRangeStart'];
    final double priceEnd = p['priceRangeEnd'];
    final int origin = p['selectedOrigin'];
    const cutMapping = {'ID': 0, 'EX': 1, 'VG': 2, 'GD': 3, 'FR': 4};
    const polishMapping = {'EX': 0, 'VG': 1, 'GD': 2, 'FR': 3};
    const symMapping = {
      'EX': 3,
      'VG': 2,
      'GD': 1,
      'FAIR': 0,
      'PR': 0,
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
      // 1. Origin
      if ((origin == 1) != stone.isLab) return false;
      // 2. Shape
      final String stoneShape = stone.shapeStr.toUpperCase().trim();
      if (searchShapeUpper == "ALL") {
        // Continue
      } else if (searchShapeUpper == "OTHER") {
        if (stoneShape.contains("ROUND") ||
            stoneShape == "R" ||
            stoneShape == "RB")
          return false;
      } else if (searchShapeUpper == "ROUND") {
        if (!(stoneShape.contains("ROUND") ||
            stoneShape == "R" ||
            stoneShape == "RB" ||
            stoneShape == "RBC"))
          return false;
      } else if (!stoneShape.contains(searchShapeUpper)) {
        return false;
      }
      // 3. Basic Ranges
      if (stone.weight < caratStart || stone.weight > caratEnd) return false;
      if (stone.total_price < priceStart || stone.total_price > priceEnd)
        return false;
      // 4. Color Range
      final List<String> shadeLabels = List<String>.from(p['shadeLabels']);
      int colorIdx = shadeLabels.indexOf(stone.colorStr.trim().toUpperCase());
      if (colorIdx != -1) {
        if (colorIdx < p['colorRangeStart'] || colorIdx > p['colorRangeEnd'])
          return false;
      }
      // 5. Clarity Range
      final List<String> clarityLabels = List<String>.from(p['clarityLabels']);
      int clarityIdx = clarityLabels.indexOf(
        stone.clarityStr.trim().toUpperCase(),
      );
      if (clarityIdx != -1) {
        if (clarityIdx < p['clarityRangeStart'] ||
            clarityIdx > p['clarityRangeEnd'])
          return false;
      }
      // 6. Cut/Polish/Sym/Fl
      String cutCode = stone.cut_code.trim().toUpperCase();
      int cutIdx =
          cutMapping[cutCode] ??
          List<String>.from(
            p['cutLabels'],
          ).indexOf(stone.cut.trim().toUpperCase());
      if (cutIdx != -1 &&
          (cutIdx < p['cutRangeStart'] || cutIdx > p['cutRangeEnd']))
        return false;
      String pCode = stone.polish.trim().toUpperCase();
      int polishIdx =
          polishMapping[pCode] ??
          List<String>.from(p['polishLabels']).indexOf(pCode);
      if (polishIdx != -1 &&
          (polishIdx < p['polishRangeStart'] ||
              polishIdx > p['polishRangeEnd']))
        return false;
      // 7. Fancy Color Logic
      final bool isFancySearch = p['isFancySearch'] ?? false;
      bool isStoneFancy =
          stone.colorStr.toLowerCase().contains("fancy") ||
          stone.fancy_color.isNotEmpty;
      if (isFancySearch) {
        if (!isStoneFancy) return false;
        final String? selectedFancyColor = p['selectedFancyColor']
            ?.toString()
            .toUpperCase();
        if (selectedFancyColor != null && selectedFancyColor.isNotEmpty) {
          bool colorMatch =
              stone.colorStr.toUpperCase().contains(selectedFancyColor) ||
              stone.fancy_color.toUpperCase().contains(selectedFancyColor);
          if (!colorMatch) return false;
        }
      } else {
        if (isStoneFancy) return false;
      }
      return true;
    }).toList();
  }

  void _handleLoadMore() {
    if (_hasMoreData) {
      setState(() {
        _localVisibleCount += 24; // Increase chunk size for smoother scrolling
        if (_localVisibleCount > _allFilteredStones.length) {
          _localVisibleCount = _allFilteredStones.length;
        }
        _displayedStones = _allFilteredStones.take(_localVisibleCount).toList();
        _hasMoreData = _localVisibleCount < _allFilteredStones.length;
      });
    }
  }

  StreamSubscription? _storageSubscription;
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 1000) {
      if (_hasMoreData && _currentTab == 0) {
        _handleLoadMore();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _future = _getSmartData();
    // Delay prefetch to prioritize initial round data loading
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) _startGentlePrefetch();
    });
    _loadHistoryFromStorage();
    _loadSavedFromStorage();
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
    _scrollController.removeListener(_scrollListener);
    _storageSubscription?.cancel();
    _shimmerController.stop();
    _shimmerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startGentlePrefetch() async {
    final List<String> allShapesToPrefetch = [];
    for (var s in shapeCategories) {
      if (s['name'] != 'Round' && s['name'] != 'Other') {
        allShapesToPrefetch.add(s['name']);
      }
    }
    for (var s in otherShapes) {
      allShapesToPrefetch.add(s['name']);
    }

    for (String shapeName in allShapesToPrefetch) {
      if (!mounted) break;
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) break;
      try {
        Map<String, dynamic>? shapeInfo;
        try {
          shapeInfo = shapeCategories.firstWhere((s) => s['name'] == shapeName);
        } catch (e) {
          shapeInfo = otherShapes.firstWhere((s) => s['name'] == shapeName);
        }
        int shapeId = shapeInfo['id'];
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
        if (!_cachedNaturalMap.containsKey(shapeId)) {
          final resNatural = await GmssApiService.fetchNaturalData(
            shapeName: shapeName,
          );
          if (mounted && resNatural['stones'] != null) {
            _cachedNaturalMap[shapeId] = {
              'stones': resNatural['stones'],
              'total': resNatural['total'],
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
        _filteredCompareCount = saved.length;
      });
    }
  }

  void _handleCardTap(GmssStone stone) {
    html.window.localStorage['selected_stone_data'] = jsonEncode(
      stone.toJson(),
    );
    GmssStone.addToHistory(stone);
    _loadHistoryFromStorage();
    Navigator.pushNamed(
      context,
      '/details?id=${stone.stockNo}&shape=${stone.shapeStr}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 1200;

    final Color themeColor = (selectedOrigin == 1)
        ? Colors.teal
        : Colors.blue.shade700;

    final Widget filtersWidget = SidebarFilters(
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
        if (selectedOrigin == val) return;
        setState(() {
          selectedOrigin = val;
          _currentPage = 1;
          bool isCached = (val == 1)
              ? _cachedLabGrownMap.containsKey(selectedShapeId)
              : _cachedNaturalMap.containsKey(selectedShapeId);
          if (!isCached) {
            _displayedStones = [];
          }
          _totalStonesFromApi = 0;
          _hasMoreData = true;
          _future = _getSmartData();
        });
      },
      onCaratChanged: (v) {
        setState(() => _caratRange = v);
        _refreshDisplayedStones();
      },
      onPriceChanged: (v) {
        setState(() => _priceRange = v);
        _refreshDisplayedStones();
      },
      onColorChanged: (v) {
        setState(() => _colorRange = v);
        _refreshDisplayedStones();
      },
      onClarityChanged: (v) {
        setState(() => _clarityRange = v);
        _refreshDisplayedStones();
      },
      onImageToggle: (v) {
        setState(() => showOnlyWithImages = v);
        _refreshDisplayedStones();
      },
      onShippingToggle: (v) {
        setState(() => quickShipping = v);
        _refreshDisplayedStones();
      },
      onReset: () {
        setState(() {
          selectedShape = 'Round';
          selectedShapeId = 1;
          _caratRange = const RangeValues(0, 15);
          _priceRange = const RangeValues(0, 100000);
          _colorRange = const RangeValues(0, 8);
          _clarityRange = const RangeValues(0, 8);
          _cutRange = const RangeValues(0, 4);
          _polishRange = const RangeValues(0, 3);
          _flRange = const RangeValues(0, 3);
          _certRange = const RangeValues(0, 2);
          _symRange = const RangeValues(0, 3);
          _depthRange = const RangeValues(0, 90);
          _tableRange = const RangeValues(0, 90);
          selectedFancyColor = null;
          selectedFancyColorId = null;
          isFancySearch = false;
        });
        _refreshDisplayedStones();
      },
      onAdvancedToggle: () =>
          setState(() => showAdvancedFilters = !showAdvancedFilters),
      onCutChanged: (v) {
        setState(() => _cutRange = v);
        _refreshDisplayedStones();
      },
      onPolishChanged: (v) {
        setState(() => _polishRange = v);
        _refreshDisplayedStones();
      },
      onFlChanged: (v) {
        setState(() => _flRange = v);
        _refreshDisplayedStones();
      },
      onCertChanged: (v) {
        setState(() => _certRange = v);
        _refreshDisplayedStones();
      },
      onSymChanged: (v) {
        setState(() => _symRange = v);
        _refreshDisplayedStones();
      },
      onDepthChanged: (v) {
        setState(() => _depthRange = v);
        _refreshDisplayedStones();
      },
      onTableChanged: (v) {
        setState(() => _tableRange = v);
        _refreshDisplayedStones();
      },
      onFancyColorTap: (id, name) {
        setState(() {
          selectedFancyColorId = id;
          selectedFancyColor = name;
        });
        _refreshDisplayedStones();
      },
      onFancyExpandToggle: () =>
          setState(() => isFancyExpanded = !isFancyExpanded),
      onSaturationChanged: (v) {
        setState(() => _saturationRange = v);
        _refreshDisplayedStones();
      },
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFB),
      drawer: isDesktop
          ? null
          : Drawer(
              width: 340,
              child: SingleChildScrollView(child: filtersWidget),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Container(
              width: 340,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey.shade100)),
              ),
              child: SingleChildScrollView(child: filtersWidget),
            ),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              cacheExtent: 1000,
              slivers: [
                SliverToBoxAdapter(
                  child: MainHeader(
                    themeColor: themeColor,
                    shapeCategories: shapeCategories,
                    onNaturalDiamondsTap: () {
                      if (selectedOrigin == 2 && !isFancySearch) return;
                      setState(() {
                        isFancySearch = false;
                        selectedOrigin = 2;
                        _currentPage = 1;
                        bool isCached = _cachedNaturalMap.containsKey(
                          selectedShapeId,
                        );
                        if (!isCached) {
                          _displayedStones = [];
                        }
                        _totalStonesFromApi = 0;
                        _future = _getSmartData(isLoadMore: false);
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
                        _totalStonesFromApi = 0;
                        _hasMoreData = true;
                        _future = _getSmartData(isLoadMore: false);
                      });
                      if (_scrollController.hasClients) {
                        _scrollController.jumpTo(0);
                      }
                    },
                  ),
                ),
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildShapeSelector(shapeCategories)),
                if (_isFiltering)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          backgroundColor: themeColor.withOpacity(0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            themeColor.withOpacity(0.6),
                          ),
                          minHeight: 2,
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _buildUnifiedInventoryToolbar(
                    mainCount: _totalFilteredStonesCount,
                    historyCount: _recentlyViewed.length,
                    compareCount: _filteredCompareCount,
                    themeColor: themeColor,
                    isDesktop: isDesktop,
                    onFilterTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),
                if ((_isFiltering && _displayedStones.isEmpty) ||
                    (_displayedStones.isEmpty && _currentPage == 1))
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
                if (!_isFiltering &&
                    (_displayedStones.isNotEmpty || _currentPage > 1))
                  SliverPadding(
                    key: ValueKey("page-$selectedShapeId-$_currentTab"),
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      bottom: 20,
                    ),
                    sliver: isGridView
                        ? SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 350,
                                  childAspectRatio: 0.92,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final List<GmssStone> stones = _currentTab == 0
                                    ? _displayedStones
                                    : (_currentTab == 1
                                          ? _recentlyViewed
                                          : _savedStones);
                                if (index >= stones.length) return null;
                                final stone = stones[index];
                                return RepaintBoundary(
                                  child: DiamondCard(
                                    key: ValueKey("diamond-${stone.stockNo}"),
                                    stone: stone,
                                    isFavorite: _savedStones.any(
                                      (s) => s.stockNo == stone.stockNo,
                                    ),
                                    onFavoriteTap: () => _toggleSave(stone),
                                    onCardTap: () => _handleCardTap(stone),
                                    themeColor: themeColor,
                                  ),
                                );
                              },
                              childCount:
                                  (_currentTab == 0
                                          ? _displayedStones
                                          : (_currentTab == 1
                                                ? _recentlyViewed
                                                : _savedStones))
                                      .length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final List<GmssStone> stones = _currentTab == 0
                                    ? _displayedStones
                                    : (_currentTab == 1
                                          ? _recentlyViewed
                                          : _savedStones);
                                if (index >= stones.length) return null;
                                return RepaintBoundary(
                                  child: _buildDiamondRow(
                                    stones[index],
                                    themeColor,
                                  ),
                                );
                              },
                              childCount:
                                  (_currentTab == 0
                                          ? _displayedStones
                                          : (_currentTab == 1
                                                ? _recentlyViewed
                                                : _savedStones))
                                      .length,
                            ),
                          ),
                  ),
                SliverToBoxAdapter(child: const SizedBox.shrink()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
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
          height: 350,
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
                  height: 200,
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
        shrinkWrap: false,
        physics: const BouncingScrollPhysics(),
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
                  int newShapeId = s['id'];
                  bool isCached = (selectedOrigin == 1)
                      ? _cachedLabGrownMap.containsKey(newShapeId)
                      : _cachedNaturalMap.containsKey(newShapeId);

                  selectedShapeId = newShapeId;
                  selectedShape = s['name'];
                  _currentPage = 1;
                  if (!isCached) {
                    _displayedStones = [];
                  }
                  _totalStonesFromApi = 0;
                  _hasMoreData = true;
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
          int newShapeId = shape['id'];
          bool isCached = (selectedOrigin == 1)
              ? _cachedLabGrownMap.containsKey(newShapeId)
              : _cachedNaturalMap.containsKey(newShapeId);

          selectedShapeId = newShapeId;
          selectedShape = shape['name'];
          _currentPage = 1;
          if (!isCached) {
            _displayedStones = [];
          }
          _totalStonesFromApi = 0;
          _hasMoreData = true;
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
    required bool isDesktop,
    required VoidCallback onFilterTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Row(
        children: [
          if (isDesktop)
            const SizedBox(width: 96)
          else
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: onFilterTap,
              tooltip: "Filters",
            ),
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
    String displayCount = "";
    if (index == 0) {
      final filteredCount = _totalFilteredStonesCount;
      displayCount = "$filteredCount";
    } else {
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
            "$label ($displayCount)",
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
