import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AirportShimmerItem extends StatelessWidget {
  const AirportShimmerItem({Key? key}) : super(key: key);

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Icon box (matches 36x36 real icon container)
            _box(36, 36, radius: 8),
            const SizedBox(width: 12),

            // City name + airport/state lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(180, 14, radius: 6),
                  const SizedBox(height: 6),
                  _box(120, 11, radius: 4),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // IATA badge
            _box(40, 22, radius: 6),
          ],
        ),
      ),
    );
  }
}
