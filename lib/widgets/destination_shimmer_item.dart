import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton for destination search results.
/// Matches the layout of actual destination list items.
class DestinationShimmerItem extends StatelessWidget {
  const DestinationShimmerItem({Key? key}) : super(key: key);

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Location icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            // Destination info (name and region)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(160, 14, radius: 6),
                  const SizedBox(height: 6),
                  _box(120, 12, radius: 6),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right side badges (same line)
            Row(
              children: [
                _box(50, 16, radius: 4),
                const SizedBox(width: 8),
                _box(35, 12, radius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
