import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui;

import 'package:brilliance_diamond_data/model/gmss_stone_model.dart';
import 'package:brilliance_diamond_data/service/gmss_api_service.dart';
import 'package:brilliance_diamond_data/widgets/main_header.dart';
import 'package:brilliance_diamond_data/widgets/safe_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'DiamondDesign.dart';

class DiamondDetailScreen extends StatefulWidget {
  final String? stoneId;
  final String? shape;
  final GmssStone? stone;
  final bool isFavorite;
  final Function(bool) onFavoriteToggle;

  const DiamondDetailScreen({
    super.key,
    this.stoneId,
    this.shape,
    this.stone,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });
  @override
  State<DiamondDetailScreen> createState() => _DiamondDetailScreenState();
}

class _DiamondDetailScreenState extends State<DiamondDetailScreen> {
  GmssStone? _currentStone;
  bool _isLoading = true;
  final ValueNotifier<bool> _isPopupVideoLoading = ValueNotifier<bool>(true);
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
  ];
  double _getRotationAngle(String shape) {
    final s = shape.toUpperCase();
    if (s.contains('MARQUISE')) return 2.48;
    if (s.contains('RADIANT')) return 2.39;
    if (s.contains('CUSHION')) return 2.45;
    if (s.contains('EMERALD')) return 2.40;
    if (s.contains('PEAR')) return 11.80;
    if (s.contains('OVAL')) return 2.38;
    if (s.contains('HEART')) return 5.60;
    return 0.0;
  }

  Future<void> _launchCertificate(String? url) async {
    if (url == null || url.isEmpty || url == "null ") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Certificate not available for this stone"),
        ),
      );
      return;
    }
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Error launching URL: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open certificate link")),
      );
    }
  }

  final ValueNotifier<double> _caratNotifier = ValueNotifier<double>(0.50);
  @override
  void initState() {
    super.initState();
    if (widget.stone != null) {
      _currentStone = widget.stone;
      _caratNotifier.value = _currentStone!.weight;
      _isLoading = false;
      _registerVideoFactory();
      _registerPopupVideoFactory(_currentStone!);
    } else {
      _loadStoneData();
    }
  }

  Future<void> _loadStoneData() async {
    final String? savedJson = html.window.localStorage['selected_stone_data'];
    if (savedJson != null) {
      try {
        final Map<String, dynamic> stoneMap = jsonDecode(savedJson);
        final stone = GmssStone.fromJson(
          stoneMap,
          isLab: stoneMap['isLab'] ?? false,
        );
        _updateUI(stone);
        return;
      } catch (e) {
        debugPrint("Error parsing local stone data: $e");
      }
    }
    if (widget.stoneId != null) {
      try {
        final labStones = await GmssApiService.fetchLabGrownData(
          shapeName: widget.shape,
        );
        final naturalStones = await GmssApiService.fetchNaturalData(
          shapeName: widget.shape,
        );
        GmssStone foundStone = [
          ...labStones['stones'],
          ...naturalStones['stones'],
        ].firstWhere((s) => s.stockNo == widget.stoneId);
        _updateUI(foundStone);
      } catch (e) {
        debugPrint("Stone not found in APIL $e");
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _updateUI(GmssStone stone) {
    if (!mounted) return;
    setState(() {
      _currentStone = stone;
      _caratNotifier.value = stone.weight;
      _isLoading = false;
    });
    GmssStone.addToHistory(stone);
    _registerVideoFactory();
    _registerPopupVideoFactory(stone);
  }

  void _registerPopupVideoFactory(GmssStone stone) {
    if (stone.video_link.isNotEmpty && stone.video_link != "null") {
      final String popupViewId = 'diamond-360-viewer-${stone.id}';
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(popupViewId, (int viewId) {
        final iframe = html.IFrameElement()
          ..src = stone.video_link
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..setAttribute('allowfullscreen', 'true');

        iframe.onLoad.listen((_) {
          _isPopupVideoLoading.value = false;
        });

        return iframe;
      });
    }
  }

  void _registerVideoFactory() {
    if (_currentStone == null) return;
    final String viewId = 'embedded-diamond-video-${_currentStone!.id}';
    String videoUrl = _currentStone!.video_link;
    if (videoUrl.isNotEmpty || videoUrl == "null") {
      videoUrl = "assets/images/video.webm";
    }
    ui.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final videoElement = html.VideoElement()
        ..src = videoUrl
        ..autoplay = true
        ..loop = true
        ..muted = true
        ..setAttribute('playsinline', 'true')
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';
      videoElement.load();
      return videoElement;
    });
  }

  void _showVideoPopup(String videoUrl) {
    if (_currentStone == null || videoUrl.isEmpty || videoUrl == "null") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("360 Video is not available.")),
      );
      return;
    }

    _isPopupVideoLoading.value = true;
    final String popupViewId = 'diamond-360-viewer-${_currentStone!.id}';

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "360View",
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Loader
                    ValueListenableBuilder<bool>(
                      valueListenable: _isPopupVideoLoading,
                      builder: (context, isLoading, child) {
                        return AnimatedOpacity(
                          opacity: isLoading ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF005AAB),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Loading 360° View...",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Video
                    HtmlElementView(
                      key: ValueKey(popupViewId),
                      viewType: popupViewId,
                    ),

                    // Header
                    Positioned(
                      top: 25,
                      left: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "360° HIGH-DEFINITION VIEW",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF005AAB).withOpacity(0.8),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF005AAB),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Close Button
                    Positioned(
                      top: 20,
                      right: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black87,
                            size: 24,
                          ),
                          splashRadius: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildTechRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value.isEmpty || value == "null" ? "None" : value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D3142),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentStone == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: _buildSkeletonLoader(),
      );
    }
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 900;
    const Color headerTheme = Color(0xFF005AAB);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black87,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Image.network(
                "https://www.brilliance.com/sites/default/files/logo_0.png",
                height: 25,
                errorBuilder: (context, error, stackTrace) => const Text(
                  "Brilliance",
                  style: TextStyle(
                    color: headerTheme,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Colors.black87,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          if (!isMobile)
            MainHeader(
              themeColor: headerTheme,
              shapeCategories: shapeCategories,
              onNaturalDiamondsTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              onFancyDiamondsTap: (name) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              onShapeTap: (shapeName, shapeId) {
                debugPrint("Selected Shape from Detail: $shapeName");
                Navigator.of(
                  context,
                ).pop({'selectedShape': shapeName, 'selectedShapeId': shapeId});
              },
            ),
          Expanded(
            child: isMobile
                ? SingleChildScrollView(child: _buildMobileLayout())
                : _buildDesktopLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildMainImageCard()),
                      const SizedBox(width: 15),
                      Expanded(child: _buildHandComparisonCard()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildProportionDiagrams(_currentStone!),
                  const SizedBox(height: 20),
                  _buildEmbeddedVideoPlayer(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 50),
              child: _buildProductInfoPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProportionDiagrams(GmssStone stone) {
    String shape = stone.shapeStr.toUpperCase();
    bool isRound = shape.contains('ROUND');
    bool isPrincess = shape.contains('PRINCESS');
    bool isEmerald = shape.contains('EMERALD');
    bool isCushion = shape.contains('CUSHION');
    bool isRadiant = shape.contains('RADIANT');
    bool isMarquise = shape.contains('MARQUISE');
    bool isPear = shape.contains('PEAR');
    bool isOval = shape.contains('OVAL');
    bool isHeart = shape.contains('HEART');
    bool isBaguette = shape.contains('BAGUETTE');
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(30),
                color: const Color(0xFFF9F9F9),
                child: isRound
                    ? CustomPaint(painter: RoundTopViewPainter(stone: stone))
                    : isPrincess
                    ? CustomPaint(painter: PrincessTopViewPainter(stone: stone))
                    : isEmerald
                    ? CustomPaint(painter: EmeraldTopViewPainter(stone: stone))
                    : isCushion
                    ? CustomPaint(painter: CushionTopViewPainter(stone: stone))
                    : isRadiant
                    ? CustomPaint(painter: RadiantTopViewPainter(stone: stone))
                    : isMarquise
                    ? CustomPaint(painter: MarquiseTopViewPainter(stone: stone))
                    : isPear
                    ? CustomPaint(painter: PearTopViewPainter(stone: stone))
                    : isOval
                    ? CustomPaint(painter: OvalTopViewPainter(stone: stone))
                    : isHeart
                    ? CustomPaint(painter: HeartTopViewPainter(stone: stone))
                    : isBaguette
                    ? CustomPaint(painter: BaguetteTopViewPainter(stone: stone))
                    : Center(
                        child: Text(
                          "${stone.shapeStr} diagram coming soon",
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(30),
                color: const Color(0xFFF9F9F9),
                child: CustomPaint(
                  painter: DiamondProfilePainter(stone: stone),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmbeddedVideoPlayer() {
    final String viewId = 'embedded-diamond-video-${_currentStone!.id}';
    return Container(
      width: double.infinity,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: HtmlElementView(viewType: viewId),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildMainImageCard(),
          const SizedBox(height: 20),
          _buildProductInfoPanel(),
          const SizedBox(height: 20),
          _buildHandComparisonCard(),
        ],
      ),
    );
  }

  Widget _buildMainImageCard() {
    bool isFavorite = GmssStone.loadSavedStones().any(
      (s) => s.stockNo == _currentStone!.stockNo,
    );
    final Color originThemeColor = _currentStone!.isLab
        ? Colors.teal
        : Colors.blue.shade700;

    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 900;

    double cardHeight = isMobile ? 600 : 500;
    double imageSize = isMobile ? 550 : 450;

    return Container(
      height: cardHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Center(
            child: SafeImage(
              url: _currentStone!.image_link,
              size: imageSize,
              stone: _currentStone!,
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 2),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey<bool>(isFavorite),
                  color: isFavorite ? originThemeColor : Colors.grey.shade400,
                  size: 30,
                ),
              ),
              onPressed: () {
                GmssStone.toggleSaveStone(_currentStone!);
                setState(() {});
                widget.onFavoriteToggle(!isFavorite);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFavorite ? "Removed from Compare" : "Added to Compare",
                    ),
                    backgroundColor: !isFavorite
                        ? originThemeColor
                        : Colors.grey.shade700,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Row(
              children: [
                if (_currentStone!.certi_file != null &&
                    _currentStone!.certi_file!.isNotEmpty &&
                    _currentStone!.certi_file != "null")
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () =>
                          _launchCertificate(_currentStone!.certi_file),
                      borderRadius: BorderRadius.circular(20),
                      child: _buildBadge(
                        "${_currentStone!.lab} Certificate",
                        imageUrl:
                            "https://www.brilliance.com/images.brilliance.com/images/product/diamonds/GIA_logo.jpg",
                        icon: Icons.verified_user_outlined,
                      ),
                    ),
                  ),
                InkWell(
                  onTap: () => _showVideoPopup(_currentStone!.video_link),
                  borderRadius: BorderRadius.circular(20),
                  child: _buildBadge(
                    "360 Video",
                    icon: Icons.play_circle_outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandComparisonCard() {
    final String handImageUrl = "assets/images/img.png";
    return ValueListenableBuilder<double>(
      valueListenable: _caratNotifier,
      builder: (context, caratValue, child) {
        double scaleFactor = (caratValue <= 1.50)
            ? (caratValue / 0.50).clamp(0.6, 1.2)
            : (1.2 + (caratValue - 1.50) * 0.2).clamp(1.2, 2.5);
        return Container(
          height: 500,
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      handImageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Text("Hand image not found in assets"),
                          ),
                    ),
                  ),
                  Positioned(
                    top: constraints.maxHeight * 0.26,
                    left: constraints.maxWidth * 0.46,
                    child: Transform.rotate(
                      angle: _getRotationAngle(_currentStone!.shapeStr),
                      child: Transform.scale(
                        scale: scaleFactor,
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 45,
                          height: 45,
                          child: Image.asset(
                            _getShapeAssetPath(_currentStone!.shapeStr),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.diamond,
                              color: Colors.grey.withValues(alpha: 0.5),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 25,
                    left: 25,
                    right: 25,
                    child: _buildSliderOverlay(caratValue),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _getShapeAssetPath(String shapeName) {
    final String s = shapeName.toLowerCase().trim();
    String fileName = "Round.png";
    if (s.contains('round')) {
      fileName = "Round.png";
    } else if (s.contains('pear')) {
      fileName = "Pear.png";
    } else if (s.contains('oval')) {
      fileName = "Oval.png";
    } else if (s.contains('marquise')) {
      fileName = "Marquise.png";
    } else if (s.contains('emerald')) {
      fileName = "Emerald.png";
    } else if (s.contains('princess')) {
      fileName = "Princess.png";
    } else if (s.contains('heart')) {
      fileName = "Heart.png";
    } else if (s.contains('cushion')) {
      fileName = "Cushion.png";
    } else if (s.contains('radiant')) {
      fileName = "Radiant.png";
    } else if (s.contains('asscher')) {
      fileName = "Asscher.png";
    }
    return "assets/images/shapes/$fileName";
  }

  Widget _buildSliderOverlay(double caratValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
      ),
      child: Row(
        children: [
          Text(
            "Your diamond: ${caratValue.toStringAsFixed(2)} ct.",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Slider(
              value: caratValue.clamp(0.1, 5.0),
              min: 0.10,
              max: 5.00,
              activeColor: const Color(0xFF005AAB),
              onChanged: (val) => _caratNotifier.value = val,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "5.00 ct.",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoPanel() {
    final String originText = _currentStone!.isLab ? "Lab Grown" : "Natural";
    final Color themeColor = const Color(0xFF005AAB);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_currentStone!.weight} Carat ${_currentStone!.shapeStr} $originText Diamond",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "\$${_currentStone!.total_price.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                "Starting at \$30.08/mo. See options",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),
        const Text(
          "DIAMOND DETAILS",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 15),

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildTechRow("Stock Number", _currentStone!.stockNo),
              _buildTechRow("Carat Weight", "${_currentStone!.weight} ct."),
              _buildTechRow("Color", _currentStone!.colorStr),
              _buildTechRow("Clarity", _currentStone!.clarityStr),
              _buildTechRow("Cut", _currentStone!.cut_code),
              _buildTechRow("Certification", _currentStone!.lab),
              _buildTechRow(
                "Measurements",
                "${_currentStone!.length}*${_currentStone!.width}*${_currentStone!.depth} mm",
              ),
              _buildTechRow("Depth%", "${_currentStone!.depth}%"),
              _buildTechRow("Table%", "${_currentStone!.table}%"),
              _buildTechRow("Polish", _currentStone!.polish),
              _buildTechRow("Symmetry", _currentStone!.symmetry),
              _buildTechRow("Gridle", _currentStone!.gridle_condition),
            ],
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
              ),
            ),
            child: const Text(
              "CHOOSE THIS DIAMOND",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 58,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: themeColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
              ),
            ),
            child: const Text(
              "ADD TO CART",
              style: TextStyle(
                color: Color(0xFF005AAB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Divider(height: 40),
        _buildTrustRow(),
      ],
    );
  }

  Widget _buildBadge(String label, {IconData? icon, String? imageUrl}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl,
              width: 18,
              height: 18,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.description, size: 14),
            )
          else if (icon != null)
            Icon(icon, size: 16, color: const Color(0xFF005AAB)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _trustItem(Icons.verified_outlined, "Honest Pricing"),
        _trustItem(Icons.security_outlined, "Lifetime Warranty"),
        _trustItem(Icons.assignment_return_outlined, "30-Day Returns"),
      ],
    );
  }

  Widget _trustItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: const Color(0xFF005AAB)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _skeletonBox(height: 500)),
                    const SizedBox(width: 15),
                    Expanded(child: _skeletonBox(height: 500)),
                  ],
                ),
                const SizedBox(height: 20),
                _skeletonBox(height: 400, width: double.infinity),
              ],
            ),
          ),
          const SizedBox(width: 30),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _skeletonBox(height: 40, width: double.infinity),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox({double? height, double? width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
