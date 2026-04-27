import 'package:brilliance_diamond_data/model/gmss_stone_model.dart';
import 'package:brilliance_diamond_data/widgets/safe_image.dart';
import 'package:flutter/material.dart';

class DiamondCard extends StatefulWidget {
  final GmssStone stone;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onCardTap;
  final Color themeColor;
  const DiamondCard({
    super.key,
    required this.stone,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onCardTap,
    required this.themeColor,
  });
  @override
  State<DiamondCard> createState() => DiamondCardState();
}

class DiamondCardState extends State<DiamondCard> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onCardTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (_isHovered || widget.isFavorite)
                  ? widget.themeColor
                  : Colors.grey.shade100,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.08 : 0.03),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // child: AnimatedScale(
          //   scale: _isHovered ? 1.02 : 1.0,
          //   duration: const Duration(milliseconds: 10),
          //   curve: Curves.easeOut,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       SizedBox(
          //         height: 200,
          //         width: double.infinity,
          //         child: Stack(
          //           children: [
          //             Align(
          //               alignment: Alignment.topCenter,
          //               child: Padding(
          //                 padding: const EdgeInsets.only(
          //                   top: 12.0,
          //                   left: 12,
          //                   right: 12,
          //                 ),
          //                 child: SafeImage(
          //                   url: widget.stone.image_link,
          //                   size: 200,
          //                   stone: widget.stone,
          //                 ),
          //               ),
          //             ),
          //             Positioned(
          //               top: 8,
          //               right: 8,
          //               child: IconButton(
          //                 icon: Icon(
          //                   widget.isFavorite
          //                       ? Icons.favorite
          //                       : Icons.favorite_border,
          //                   color: widget.isFavorite
          //                       ? widget.themeColor
          //                       : Colors.grey.shade300,
          //                 ),
          //                 onPressed: widget.onFavoriteTap,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //       Flexible(
          //         child: Padding(
          //           padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               Text(
          //                 "${widget.stone.weight} CARAT ${widget.stone.shapeStr.toUpperCase()}",
          //                 maxLines: 1,
          //                 overflow: TextOverflow.ellipsis,
          //                 style: const TextStyle(
          //                   fontWeight: FontWeight.w900,
          //                   fontSize: 15,
          //                 ),
          //               ),
          //               const SizedBox(height: 4),
          //               Text(
          //                 "${widget.stone.colorStr} • ${widget.stone.clarityStr} • ${widget.stone.lab}",
          //                 style: TextStyle(
          //                   color: Colors.grey.shade600,
          //                   fontSize: 11,
          //                 ),
          //               ),
          //               const SizedBox(height: 4),
          //               Text(
          //                 "\$${widget.stone.total_price.toStringAsFixed(2)}",
          //                 style: const TextStyle(
          //                   fontWeight: FontWeight.w900,
          //                   fontSize: 14,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, opacity, child) {
              return Opacity(
                opacity: opacity,
                child: child,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGE SECTION - Using Expanded to be flexible
                Expanded(
                  flex: 3, // Takes 3 parts of the height
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SafeImage(
                            url: widget.stone.image_link,
                            size: 160,
                            stone: widget.stone,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: IconButton(
                          icon: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.isFavorite
                                ? widget.themeColor
                                : Colors.grey.shade300,
                            size: 20,
                          ),
                          onPressed: widget.onFavoriteTap,
                        ),
                      ),
                    ],
                  ),
                ),

                // DATA SECTION - Using Flexible to wrap text
                Flexible(
                  flex: 1, // Takes 1 part of the height
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "${widget.stone.weight} CARAT ${widget.stone.shapeStr.toUpperCase()}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${widget.stone.displayColor} • ${widget.stone.clarityStr} • ${widget.stone.lab}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "\$${widget.stone.total_price.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //       ),
  //     ),
  //   );
  // }
}
