import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FlightShimmerCard extends StatelessWidget {
  final bool isRoundTrip;

  const FlightShimmerCard({Key? key, this.isRoundTrip = false})
      : super(key: key);

  Widget _box(double w, double h, {double radius = 8}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  Widget _timeColumn(CrossAxisAlignment align) => Column(
        crossAxisAlignment: align,
        mainAxisSize: MainAxisSize.min,
        children: [
          _box(52, 22),
          const SizedBox(height: 4),
          _box(72, 12),
          const SizedBox(height: 4),
          _box(36, 12),
        ],
      );

  Widget _timeRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _timeColumn(CrossAxisAlignment.start),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _box(55, 14),
              const SizedBox(height: 4),
              _box(45, 12),
            ],
          ),
          _timeColumn(CrossAxisAlignment.end),
        ],
      );

  @override
  Widget build(BuildContext context) {
    // Card container is OUTSIDE Shimmer — gives the white card + shadow.
    // Shimmer wraps ONLY the skeleton boxes inside. This way shimmer
    // animates the white boxes against a transparent column background,
    // making the skeleton structure visible.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        period: const Duration(milliseconds: 1800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: logo + airline name + flight number + badge ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _box(72, 72, radius: 12),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _box(140, 16),
                    const SizedBox(height: 8),
                    _box(90, 12),
                    const SizedBox(height: 6),
                    _box(55, 18, radius: 4),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Outbound label (round-trip only) ─────────────────────
            if (isRoundTrip) ...[
              _box(70, 12),
              const SizedBox(height: 10),
            ],

            // ── Outbound / one-way time row ──────────────────────────
            _timeRow(),

            // ── Return section (round-trip only) ─────────────────────
            if (isRoundTrip) ...[
              const SizedBox(height: 16),
              _box(50, 12),
              const SizedBox(height: 10),
              _timeRow(),
            ],

            const SizedBox(height: 16),
            _box(double.infinity, 1),
            const SizedBox(height: 12),

            // ── Price + Select button ────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _box(35, 12),
                    const SizedBox(height: 4),
                    _box(65, 22),
                  ],
                ),
                _box(100, 42, radius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
