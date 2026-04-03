import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton row matching the country/city list item layout:
/// [circle icon 36x36] [name line flex] [code badge 38x26]
class LocationShimmerItem extends StatelessWidget {
  const LocationShimmerItem({Key? key}) : super(key: key);

  Widget _box(double w, double h, {double radius = 8}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1800),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Globe / location icon placeholder
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            // Country / city name
            Expanded(child: _box(double.infinity, 15, radius: 6)),
            const SizedBox(width: 12),
            // Code badge
            _box(38, 26, radius: 8),
          ],
        ),
      ),
    );
  }
}
