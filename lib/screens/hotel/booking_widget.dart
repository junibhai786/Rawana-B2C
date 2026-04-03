import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingWidget extends StatefulWidget {
  const BookingWidget({Key? key}) : super(key: key);

  @override
  State<BookingWidget> createState() => _BookingWidgetState();
}

class _BookingWidgetState extends State<BookingWidget> {
  late DateTime checkInDate;
  late DateTime checkOutDate;
  int adults = 1;
  int children = 0;
  int units = 1;

  @override
  void initState() {
    super.initState();
    checkInDate = DateTime(2026, 3, 30);
    checkOutDate = DateTime(2026, 4, 3);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  String _getGuestSummary() {
    return '$units Unit${units != 1 ? 's' : ''} - $adults Adult${adults != 1 ? 's' : ''} - $children Child${children != 1 ? 'ren' : ''}';
  }

  void _incrementAdults() {
    setState(() => adults++);
  }

  void _decrementAdults() {
    if (adults > 0) setState(() => adults--);
  }

  void _incrementChildren() {
    setState(() => children++);
  }

  void _decrementChildren() {
    if (children > 0) setState(() => children--);
  }

  void _incrementUnits() {
    setState(() => units++);
  }

  void _decrementUnits() {
    if (units > 0) setState(() => units--);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF5F5F5),
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Book Your Stay',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 12),

          // Icon Section
          Center(
            child: Icon(
              Icons.send_rounded,
              size: 20,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 12),

          // Helper Text
          Text(
            'Select a room below to see pricing',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),

          // Main Booking Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date Row
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Check-in Field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-in'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff1D2025),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xffE5E7EB)),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/calendar.svg',
                                    width: 16,
                                    height: 16,
                                    color: const Color(0xff6B7280),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formatDate(checkInDate),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xff1D2025),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Check-out Field
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-out'.tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff1D2025),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xffE5E7EB)),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/calendar.svg',
                                    width: 16,
                                    height: 16,
                                    color: const Color(0xff6B7280),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _formatDate(checkOutDate),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xff1D2025),
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
                  ),
                ),

                // Divider
                Divider(
                  height: 1,
                  color: Colors.grey[200],
                  indent: 16,
                  endIndent: 16,
                ),

                // Guests Selector
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guests'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xff1D2025),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffE5E7EB)),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/user.svg',
                              width: 20,
                              height: 20,
                              color: const Color(0xff6B7280),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getGuestSummary(),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff1D2025),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xff6B7280),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Guest Dropdown Panel
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Adults Row
                _buildGuestRow(
                  label: 'Adults',
                  subtitle: 'Above 12 years',
                  count: adults,
                  onIncrement: _incrementAdults,
                  onDecrement: _decrementAdults,
                  divider: true,
                ),

                // Children Row
                _buildGuestRow(
                  label: 'Children',
                  subtitle: 'Below 12 years',
                  count: children,
                  onIncrement: _incrementChildren,
                  onDecrement: _decrementChildren,
                  divider: true,
                ),

                // Units Row
                _buildGuestRow(
                  label: 'Unit',
                  subtitle: 'Rooms',
                  count: units,
                  onIncrement: _incrementUnits,
                  onDecrement: _decrementUnits,
                  divider: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestRow({
    required String label,
    required String subtitle,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required bool divider,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Label Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Controls
              Row(
                children: [
                  // Minus Button
                  _buildControlButton(
                    icon: Icons.remove,
                    onTap: onDecrement,
                  ),
                  SizedBox(width: 12),

                  // Count Display
                  SizedBox(
                    width: 30,
                    child: Text(
                      count.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),

                  // Plus Button
                  _buildControlButton(
                    icon: Icons.add,
                    onTap: onIncrement,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (divider)
          Divider(
            height: 1,
            color: Colors.grey[200],
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
