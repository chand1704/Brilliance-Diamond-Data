import 'package:flutter/material.dart';

class SidebarFilters extends StatelessWidget {
  final Color themeColor;
  final int selectedOrigin;
  final bool isFancySearch;
  final RangeValues caratRange;
  final RangeValues priceRange;
  final RangeValues colorRange;
  final RangeValues clarityRange;
  final bool showOnlyWithImages;
  final bool quickShipping;
  final bool showAdvancedFilters;
  final RangeValues cutRange;
  final RangeValues polishRange;
  final RangeValues flRange;
  final RangeValues certRange;
  final RangeValues symRange;
  final RangeValues depthRange;
  final RangeValues tableRange;
  final int? selectedFancyColorId;
  final bool isFancyExpanded;
  final RangeValues saturationRange;
  final List<Map<String, dynamic>> fancyColors;
  final List<String> saturationLabels;
  final String selectedShape;
  final List<String> shadeLabels;
  final List<String> clarityLabels;
  final List<String> cutLabels;
  final List<String> polishLabels;
  final List<String> flLabels;
  final List<String> certLabels;
  final List<String> symLabels;
  final Function(int) onOriginChanged;
  final Function(RangeValues) onCaratChanged;
  final Function(RangeValues) onPriceChanged;
  final Function(RangeValues) onColorChanged;
  final Function(RangeValues) onClarityChanged;
  final Function(bool) onImageToggle;
  final Function(bool) onShippingToggle;
  final VoidCallback onReset;
  final VoidCallback onAdvancedToggle;
  final Function(RangeValues) onCutChanged;
  final Function(RangeValues) onPolishChanged;
  final Function(RangeValues) onFlChanged;
  final Function(RangeValues) onCertChanged;
  final Function(RangeValues) onSymChanged;
  final Function(RangeValues) onDepthChanged;
  final Function(RangeValues) onTableChanged;
  final Function(int?, String?) onFancyColorTap;
  final VoidCallback onFancyExpandToggle;
  final Function(RangeValues) onSaturationChanged;
  const SidebarFilters({
    super.key,
    required this.themeColor,
    required this.selectedOrigin,
    required this.isFancySearch,
    required this.caratRange,
    required this.priceRange,
    required this.colorRange,
    required this.clarityRange,
    required this.showOnlyWithImages,
    required this.quickShipping,
    required this.showAdvancedFilters,
    required this.cutRange,
    required this.polishRange,
    required this.flRange,
    required this.certRange,
    required this.symRange,
    required this.depthRange,
    required this.tableRange,
    required this.shadeLabels,
    required this.clarityLabels,
    required this.cutLabels,
    required this.polishLabels,
    required this.flLabels,
    required this.certLabels,
    required this.symLabels,
    required this.onOriginChanged,
    required this.onCaratChanged,
    required this.onPriceChanged,
    required this.onColorChanged,
    required this.onClarityChanged,
    required this.onImageToggle,
    required this.onShippingToggle,
    required this.onReset,
    required this.onAdvancedToggle,
    required this.onCutChanged,
    required this.onPolishChanged,
    required this.onFlChanged,
    required this.onCertChanged,
    required this.onSymChanged,
    required this.onDepthChanged,
    required this.onTableChanged,
    required this.selectedFancyColorId,
    required this.isFancyExpanded,
    required this.saturationRange,
    required this.fancyColors,
    required this.saturationLabels,
    required this.selectedShape,
    required this.onFancyColorTap,
    required this.onFancyExpandToggle,
    required this.onSaturationChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Filters",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 30),
          _sectionHeader("Diamond Origin"),
          const SizedBox(height: 15),
          _buildOriginSegmentedControl(),
          const SizedBox(height: 40),
          if (isFancySearch) ...[
            _buildFancyColorFilter(),
            const SizedBox(height: 30),
            _buildSaturationSlider(context),
            const SizedBox(height: 30),
            const Divider(),
          ] else ...[
            _buildColorSlider(context),
          ],
          const SizedBox(height: 15),
          _sectionHeader("Carat"),
          StatefulRangeGroup(
            initialValues: caratRange,
            min: 0,
            max: 15,
            themeColor: themeColor,
            onChanged: onCaratChanged,
            bottomBuilder: (v) => _buildValueDisplay(
              v.start.toStringAsFixed(2),
              "${v.end.toStringAsFixed(2)} ct",
            ),
          ),
          const SizedBox(height: 40),
          _sectionHeader("Price Range"),
          StatefulRangeGroup(
            initialValues: priceRange,
            min: 0,
            max: 100000,
            themeColor: themeColor,
            onChanged: onPriceChanged,
            bottomBuilder: (v) => _buildValueDisplay(
              "\$${v.start.toInt()}",
              "\$${v.end.toInt()}",
            ),
          ),
          const SizedBox(height: 40),
          _buildStaticFilters(),
          _buildClaritySlider(context),
          const SizedBox(height: 20),
          _buildAdvancedSection(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFancyColorFilter() {
    String shapName = "RD";
    String currentShape = selectedShape.toUpperCase();
    if (currentShape == "PEAR") shapName = "PE";
    if (currentShape == "EMERALD") shapName = "EM";
    if (currentShape == "MARQUISE") shapName = "MQ";
    if (currentShape == "CUSHION") shapName = "CU";
    if (currentShape == "RADIANT") shapName = "RA";
    if (currentShape == "OVAL") shapName = "OV";
    if (currentShape == "HEART") shapName = "HT";
    if (currentShape == "PRINCESS") shapName = "PR";
    if (currentShape == "ASSCHER") shapName = "AS";
    final visibleColors = isFancyExpanded
        ? fancyColors
        : fancyColors.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader("Fancy Color"),
        const SizedBox(height: 15),
        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: visibleColors.map((item) {
            bool isSelected = selectedFancyColorId == item['id'];
            String colorFileName = item['name'] == "White"
                ? "NZ"
                : item['name'];
            String imageUrl =
                "https://www.brilliance.com/sites/default/files/vue/fancy-search/${shapName}_$colorFileName.png";
            return GestureDetector(
              onTap: () => onFancyColorTap(
                isSelected ? null : item['id'],
                isSelected ? null : item['name'],
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.network(
                      "https://corsproxy.io/?${Uri.encodeComponent(imageUrl)}",
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 1),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: _getDiamondColor(item['name']),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['name'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        TextButton(
          onPressed: onFancyExpandToggle,
          child: Text(
            isFancyExpanded ? "Show less" : "Show more",
            style: const TextStyle(
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _buildSaturationSlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Saturation",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 5),
        StatefulRangeGroup(
          initialValues: saturationRange,
          min: 0,
          max: (saturationLabels.length - 1).toDouble(),
          divisions: saturationLabels.length - 1,
          themeColor: themeColor,
          onChanged: onSaturationChanged,
          bottomBuilder: (v) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: saturationLabels.map((label) {
                int index = saturationLabels.indexOf(label);
                bool isActive = index >= v.start && index <= v.end;

                return Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: isActive ? Colors.black : Colors.grey,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSection(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text(
            "Advanced Filters",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: Icon(showAdvancedFilters ? Icons.remove : Icons.add),
          onTap: onAdvancedToggle,
        ),
        if (showAdvancedFilters) ...[
          _buildRangeGroup("Cut", cutLabels, cutRange, onCutChanged),
          const SizedBox(height: 20),
          _buildRangeGroup(
            "Polish",
            polishLabels,
            polishRange,
            onPolishChanged,
          ),
          const SizedBox(height: 20),
          _buildRangeGroup("Fluorescence", flLabels, flRange, onFlChanged),
          const SizedBox(height: 20),
          _buildRangeGroup(
            "Certification",
            certLabels,
            certRange,
            onCertChanged,
          ),
          const SizedBox(height: 20),
          _buildRangeGroup("Symmetry", symLabels, symRange, onSymChanged),
          const SizedBox(height: 20),
          _sectionHeader("Depth"),
          StatefulRangeGroup(
            initialValues: depthRange,
            min: 0,
            max: 90,
            themeColor: themeColor,
            onChanged: onDepthChanged,
            bottomBuilder: (v) =>
                _buildValueDisplay("${v.start.toInt()}%", "${v.end.toInt()}%"),
          ),
          const SizedBox(height: 20),
          _sectionHeader("Table"),
          StatefulRangeGroup(
            initialValues: tableRange,
            min: 0,
            max: 90,
            themeColor: themeColor,
            onChanged: onTableChanged,
            bottomBuilder: (v) =>
                _buildValueDisplay("${v.start.toInt()}%", "${v.end.toInt()}%"),
          ),
        ],
      ],
    );
  }

  Widget _buildRangeGroup(
    String title,
    List<String> labels,
    RangeValues values,
    Function(RangeValues) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        StatefulRangeGroup(
          initialValues: values,
          min: 0,
          max: (labels.length - 1).toDouble(),
          divisions: labels.length - 1,
          themeColor: themeColor,
          onChanged: onChanged,
          bottomBuilder: (v) => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: labels
                    .map(
                      (l) => Text(
                        l,
                        style: const TextStyle(fontSize: 8, color: Colors.grey),
                      ),
                    )
                    .toList(),
              ),
              const Divider(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOriginSegmentedControl() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [_originOption("Lab Grown", 1), _originOption("Natural", 2)],
      ),
    );
  }

  Widget _originOption(String label, int value) {
    bool isSelected = selectedOrigin == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onOriginChanged(value),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? (value == 1 ? Colors.teal : Colors.blue.shade700)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        const SizedBox(width: 5),
        Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
      ],
    );
  }

  Widget _buildValueDisplay(String min, String max) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _valuePod(min),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text("-"),
        ),
        _valuePod(max),
      ],
    );
  }

  Widget _valuePod(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildStaticFilters() {
    return Column(
      children: [
        _filterCheck("With Image Only", showOnlyWithImages, onImageToggle),
        _filterCheck("Quick Shipping", quickShipping, onShippingToggle),
        TextButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.refresh),
          label: const Text("Reset Filters"),
        ),
      ],
    );
  }

  Widget _filterCheck(String label, bool val, Function(bool) onChanged) {
    return Row(
      children: [
        Checkbox(
          value: val,
          onChanged: (v) => onChanged(v!),
          activeColor: themeColor,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildColorSlider(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        "Color",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      initiallyExpanded: true,
      children: [
        StatefulRangeGroup(
          initialValues: colorRange,
          min: 0,
          max: (shadeLabels.length - 1).toDouble(),
          divisions: shadeLabels.length - 1,
          themeColor: themeColor,
          onChanged: onColorChanged,
          bottomBuilder: (v) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: shadeLabels
                  .map(
                    (s) => Text(
                      s,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildClaritySlider(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        "Clarity",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      initiallyExpanded: true,
      children: [
        StatefulRangeGroup(
          initialValues: clarityRange,
          min: 0,
          max: (clarityLabels.length - 1).toDouble(),
          divisions: clarityLabels.length - 1,
          themeColor: themeColor,
          onChanged: onClarityChanged,
          bottomBuilder: (v) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: clarityLabels
                  .map(
                    (c) => Text(
                      c,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class StatefulRangeGroup extends StatefulWidget {
  final RangeValues initialValues;
  final double min;
  final double max;
  final int? divisions;
  final Color themeColor;
  final Function(RangeValues) onChanged;
  final Widget Function(RangeValues) bottomBuilder;

  const StatefulRangeGroup({
    Key? key,
    required this.initialValues,
    required this.min,
    required this.max,
    this.divisions,
    required this.themeColor,
    required this.onChanged,
    required this.bottomBuilder,
  }) : super(key: key);

  @override
  _StatefulRangeGroupState createState() => _StatefulRangeGroupState();
}

class _StatefulRangeGroupState extends State<StatefulRangeGroup> {
  late RangeValues _values;

  @override
  void initState() {
    super.initState();
    _values = widget.initialValues;
  }

  @override
  void didUpdateWidget(StatefulRangeGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValues != widget.initialValues) {
      _values = widget.initialValues;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: widget.themeColor,
            trackHeight: 3,
            thumbColor: widget.themeColor,
            overlayColor: widget.themeColor.withOpacity(0.1),
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: RangeSlider(
            values: _values,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: (v) {
              setState(() {
                _values = v;
              });
              widget.onChanged(v);
            },
          ),
        ),
        widget.bottomBuilder(_values),
      ],
    );
  }
}
