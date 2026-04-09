import 'package:brilliance_diamond/utils/diamond_painter_utils.dart';
import 'package:flutter/material.dart';

class MainHeader extends StatefulWidget {
  final Color themeColor;
  final VoidCallback onNaturalDiamondsTap;
  final Function(String?) onFancyDiamondsTap;
  final Function(String, int) onShapeTap;
  final List<Map<String, dynamic>> shapeCategories;
  const MainHeader({
    super.key,
    required this.themeColor,
    required this.onNaturalDiamondsTap,
    required this.onFancyDiamondsTap,
    required this.onShapeTap,
    required this.shapeCategories,
  });
  @override
  State<MainHeader> createState() => _MainHeaderState();
}

class _MainHeaderState extends State<MainHeader> {
  Color _getDiamondColor(String name) {
    switch (name.toLowerCase()) {
      case 'yellow':
        return const Color(0xFFFFD700);
      case 'pink':
        return const Color(0xFFFFB6C1);
      case 'blue':
        return const Color(0xFF87CEEB);
      case 'green':
        return const Color(0xFF90EE90);
      case 'orange':
        return const Color(0xFFFFA500);
      case 'purple':
        return const Color(0xFFDDA0DD);
      case 'brown':
        return const Color(0xFF8B4513);
      case 'grey':
        return const Color(0xFF808080);
      default:
        return Colors.grey.shade300;
    }
  }

  final List<Map<String, dynamic>> fancyColors = [
    {'id': 7, 'name': 'Green'},
    {'id': 8, 'name': 'Orange'},
    {'id': 9, 'name': 'Pink'},
    {'id': 11, 'name': 'Purple'},
    {'id': 14, 'name': 'Yellow'},
    {'id': 2, 'name': 'Blue'},
    {'id': 6, 'name': 'Grey'},
    {'id': 3, 'name': 'Brown'},
    {'id': 10, 'name': 'NZ'},
  ];
  bool isFancyExpanded = false;
  final OverlayPortalController _diamondHoverController =
      OverlayPortalController();
  final OverlayPortalController _engagementHoverController =
      OverlayPortalController();
  final OverlayPortalController _weddingHoverController =
      OverlayPortalController();
  final OverlayPortalController _jewelryHoverController =
      OverlayPortalController();
  final OverlayPortalController _aboutHoverController =
      OverlayPortalController();
  void _hideAllMenus() {
    _diamondHoverController.hide();
    _engagementHoverController.hide();
    _weddingHoverController.hide();
    _jewelryHoverController.hide();
    _aboutHoverController.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Spacer(),
          Row(
            children: [
              _hoverNavLink(
                "Diamonds",
                _diamondHoverController,
                _buildMegaMenu(),
              ),
              _hoverNavLink(
                "Engagement",
                _engagementHoverController,
                _buildEngagementMenu(),
              ),
              _hoverNavLink(
                "Wedding",
                _weddingHoverController,
                _buildWeddingMenu(),
              ),
              _hoverNavLink(
                "Jewelry",
                _jewelryHoverController,
                _buildJewelryMenu(),
              ),
              _hoverNavLink("About", _aboutHoverController, _buildAboutMenu()),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _hoverNavLink(
    String label,
    OverlayPortalController controller,
    Widget menu,
  ) {
    return MouseRegion(
      onEnter: (_) {
        _hideAllMenus();
        controller.show();
      },
      child: OverlayPortal(
        controller: controller,
        overlayChildBuilder: (context) => Positioned(
          top: 70,
          left: 0,
          right: 0,
          child: MouseRegion(
            onExit: (_) => controller.hide(),
            child: _MenuAnimationWrapper(child: menu),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMegaMenu() {
    return Material(
      elevation: 20,
      shadowColor: Colors.black12,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SHOP BY SHAPE",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  const SizedBox(height: 25),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: widget.shapeCategories
                        .map((shape) => _shapeItem(shape))
                        .toList(),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "SHOP BY COLOR",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 15,
                    children: [
                      _headerColorItem("Yellow"),
                      _headerColorItem("Pink"),
                      _headerColorItem("Blue"),
                      _headerColorItem("Green"),
                      _headerColorItem("Orange"),
                      _headerColorItem("Purple"),
                      _headerColorItem("Brown"),
                      _headerColorItem("Grey"),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: _menuColumn("NATURAL DIAMONDS", [
                _menuAction(
                  "All Natural Diamonds",
                  widget.onNaturalDiamondsTap,
                ),
                _menuAction("Fancy Color Diamonds", () {
                  widget.onFancyDiamondsTap(null);
                  _hideAllMenus();
                }),
              ]),
            ),
            _buildPromoCard(
              "assets/images/diamonds_promo.png",
              "NEW ARRIVALS",
              "Exquisite Lab Brilliance",
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerColorItem(String name) {
    return InkWell(
      onTap: () {
        widget.onFancyDiamondsTap(name);
        _hideAllMenus();
      },
      child: SizedBox(
        width: 45,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, color: _getDiamondColor(name), size: 22),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementMenu() {
    return Material(
      elevation: 10,
      shadowColor: Colors.black26,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SHOP BY STYLE",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  _engagementStyleItem("Solitaire", ""),
                  _engagementStyleItem("Side Stone", ""),
                  _engagementStyleItem("Halo", ""),
                  _engagementStyleItem("Three Stones", ""),
                  _engagementStyleItem("Vintage", ""),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: _menuColumn("CREATE YOUR OWN RING", [
                const Text(
                  "Start with a Setting",
                  style: TextStyle(fontSize: 14),
                ),
                const Text(
                  "Start with a Diamond",
                  style: TextStyle(fontSize: 14),
                ),
                const Text("3D Ring Creator", style: TextStyle(fontSize: 14)),
              ]),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _menuColumn("SHOP BY METAL", [
                    const Text("White Gold", style: TextStyle(fontSize: 14)),
                    const Text("Yellow Gold", style: TextStyle(fontSize: 14)),
                    const Text("Rose Gold", style: TextStyle(fontSize: 14)),
                    const Text("Platinum", style: TextStyle(fontSize: 14)),
                  ]),
                  const SizedBox(height: 30),
                  _menuColumn("ENGAGEMENT RING TIPS", [
                    const Text("Ring Guide", style: TextStyle(fontSize: 14)),
                    const Text(
                      "Find Your Ring Size",
                      style: TextStyle(fontSize: 14),
                    ),
                  ]),
                ],
              ),
            ),
            _buildPromoCard(
              "assets/images/engagement_promo.png",
              "CREATE YOUR OWN RING",
              "Explore Our 3D Creator",
            ),
          ],
        ),
      ),
    );
  }

  Widget _engagementStyleItem(String label, String iconPath) {
    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.diamond_outlined, size: 20, color: Colors.black54),
          const SizedBox(width: 15),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeddingMenu() {
    return Material(
      elevation: 10,
      shadowColor: Colors.black26,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _menuColumn("Women's Rings", [
                const Text(
                  "Diamond Wedding Bands",
                  style: TextStyle(fontSize: 14),
                ),
                const Text(
                  "Diamond Eternity Bands",
                  style: TextStyle(fontSize: 14),
                ),
                const Text(
                  "Gemstone Wedding Bands",
                  style: TextStyle(fontSize: 14),
                ),
                const Text("Bestsellers", style: TextStyle(fontSize: 14)),
              ]),
            ),
            Expanded(
              flex: 2,
              child: _menuColumn("Men's Rings", [
                const Text(
                  "Men's Wedding Bands",
                  style: TextStyle(fontSize: 14),
                ),
                const Text(
                  "Men's Diamond Rings",
                  style: TextStyle(fontSize: 14),
                ),
                const Text(
                  "Top 10 Men's Rings",
                  style: TextStyle(fontSize: 14),
                ),
                const Text(
                  "Timeless Inspired Rings",
                  style: TextStyle(fontSize: 14),
                ),
                const Text(
                  "Bold & Unique Rings",
                  style: TextStyle(fontSize: 14),
                ),
              ]),
            ),
            Expanded(
              flex: 2,
              child: _menuColumn("Weddings Ring Tips", [
                const Text("Ring Size Chart", style: TextStyle(fontSize: 14)),
                const Text("Metal Education", style: TextStyle(fontSize: 14)),
                const Text(
                  "Women's Ring Guide",
                  style: TextStyle(fontSize: 14),
                ),
                const Text("Men's Ring Guide", style: TextStyle(fontSize: 14)),
              ]),
            ),
            _buildPromoCard(
              "assets/images/wedding_promo.png",
              "WEDDING RINGS",
              "Explore Our Best Sellers",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJewelryMenu() {
    return Material(
      elevation: 10,
      shadowColor: Colors.black26,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _menuColumn("Bracelets", [
                    const Text(
                      "Lab Diamond Bracelets",
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      "Diamond Bracelets",
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      "Gemstone Bracelets",
                      style: TextStyle(fontSize: 14),
                    ),
                  ]),
                  const SizedBox(height: 30),
                  _menuColumn("Rings", [
                    const Text("Fashion Rings", style: TextStyle(fontSize: 14)),
                    const Text(
                      "Eternity Rings",
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      "Gemstone Rings",
                      style: TextStyle(fontSize: 14),
                    ),
                  ]),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _menuColumn("Gifts & Collections", [
                    const Text("Gifts For Her", style: TextStyle(fontSize: 14)),
                    const Text(
                      "Tennis Bracelets",
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text("Hoop Earrings", style: TextStyle(fontSize: 14)),
                  ]),
                  const SizedBox(height: 30),
                  _menuColumn("Featured", [
                    const Text(
                      "Custom Designed Jewelry",
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text("Jewelry Guids", style: TextStyle(fontSize: 14)),
                    const Text(
                      "Best Seller Bracelets",
                      style: TextStyle(fontSize: 14),
                    ),
                  ]),
                ],
              ),
            ),
            _buildPromoCard(
              "assets/images/jewelry_promo.png",
              "Shop Vault Sale",
              "Get 50% Off with code VAULT",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutMenu() {
    return Material(
      elevation: 25,
      shadowColor: Colors.black12,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextColumn("Brilliance", [
                "About",
                "Contact Us",
                "Diamond Experts",
                "Brilliance Reviews",
                "Flexible Financing",
              ]),
              _buildTextColumn("Customer Care", [
                "30 Day Return",
                "Low Price Returns",
                "Lifetime Warranty",
                "FAQs",
                "Resize Your Ring",
                "care & Maintenance",
              ]),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _menuColumn("Education", [
                      const Text(
                        "Diamond Education",
                        style: TextStyle(fontSize: 14),
                      ),
                      const Text(
                        "Jewelry Education",
                        style: TextStyle(fontSize: 14),
                      ),
                      const Text(
                        "Engagement Ring Guide",
                        style: TextStyle(fontSize: 14),
                      ),
                    ]),
                    const SizedBox(height: 30),
                    _menuColumn("Articles", [
                      const Text(
                        "Jewelry Cleaning Guide",
                        style: TextStyle(fontSize: 14),
                      ),
                      const Text(
                        "Jewelry Cleaning Guide",
                        style: TextStyle(fontSize: 14),
                      ),
                      const Text(
                        "What Is Rhodium Plating?",
                        style: TextStyle(fontSize: 14),
                      ),
                    ]),
                  ],
                ),
              ),
              _buildPromoCard(
                "assets/images/workshop.png",
                "Handmade with Love",
                "Learn About Our Process",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shapeItem(Map<String, dynamic> shape) {
    return InkWell(
      onTap: () {
        widget.onShapeTap(shape['name'], shape['id']);
        _hideAllMenus();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 35,
            width: 35,
            child: CustomPaint(
              painter: DiamondPainterUtils.getPainterForShapeName(
                shape['name'],
                false,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            shape['name'].toString().toUpperCase(),
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _menuColumn(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        const SizedBox(height: 20),
        ...items.map(
          (item) =>
              Padding(padding: const EdgeInsets.only(bottom: 12), child: item),
        ),
      ],
    );
  }

  Widget _menuAction(String label, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        onTap();
        _hideAllMenus();
      },
      child: Text(
        label,
        style: const TextStyle(color: Colors.black87, fontSize: 14),
      ),
    );
  }

  Widget _buildPromoCard(String assetPath, String title, String subtitle) {
    return Container(
      width: 260,
      height: 280,
      margin: const EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF001F3F),
                child: const Icon(
                  Icons.diamond_outlined,
                  color: Colors.white24,
                  size: 40,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextColumn(String title, List<String> items) {
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 25),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                item,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuAnimationWrapper extends StatefulWidget {
  final Widget child;
  const _MenuAnimationWrapper({required this.child});
  @override
  State<_MenuAnimationWrapper> createState() => _MenuAnimationWrapperState();
}

class _MenuAnimationWrapperState extends State<_MenuAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
