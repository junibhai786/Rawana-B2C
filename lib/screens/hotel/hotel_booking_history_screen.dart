import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/reservation/reservation_detail_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String selectedFilter = 'All Bookings'.tr;

  final List<String> filterOptions = [
    'All Bookings'.tr,
    'Completed'.tr,
    'Processing'.tr,
    'Confirmed'.tr,
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<HomeProvider>(context, listen: false).fetchBookingHistory();
  }

  int calculateDuration(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 0;
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return end.difference(start).inDays;
  }

  String formatDate(String date) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HomeProvider>(context);

    final bookings = provider.bookingHistoryResponse?.data?.where((booking) {
      if (selectedFilter == 'All Bookings'.tr) return true;
      return (booking.status ?? '').toLowerCase() ==
          selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'Booking History'.tr,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Filter
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 14, color: Colors.black),
                    items: filterOptions
                        .map(
                          (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ),
                    )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedFilter = val);
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// List
            Expanded(
              child: bookings == null || bookings.isEmpty
                  ? Center(
                child: Text(
                  'No bookings found'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final b = bookings.reversed.toList()[index];
                  final nights =
                  calculateDuration(b.startDate, b.endDate);

                  return BookingCard(
                    bookingCode: b.code ?? '',
                    type: b.objectModel ?? '',
                    title: b.service?.title ?? '',
                    orderDate: formatDate(b.createdAt ?? ''),
                    startDate: formatDate(b.startDate ?? ''),
                    endDate: formatDate(b.endDate ?? ''),
                    duration:
                    '$nights ${nights > 1 ? 'nights' : 'night'}',
                    total: double.tryParse(b.total ?? '0') ?? 0,
                    paid: double.tryParse(b.paid ?? '0') ?? 0,
                    status: b.status ?? '',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final String bookingCode;
  final String type;
  final String title;
  final String orderDate;
  final String startDate;
  final String endDate;
  final String duration;
  final double total;
  final double paid;
  final String status;

  const BookingCard({
    super.key,
    required this.bookingCode,
    required this.type,
    required this.title,
    required this.orderDate,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.total,
    required this.paid,
    required this.status,
  });

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.secondary;
      case 'confirmed':
        return AppColors.primary;
      case 'processing':
        return AppColors.accent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  orderDate,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Title
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            /// Dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dateColumn('Check-in'.tr, startDate),
                _dateColumn('Check-out'.tr, endDate),
                _dateColumn('Duration'.tr, duration),
              ],
            ),

            const Divider(height: 32),

            /// Payment
            _row('Total'.tr, '\$${total.toStringAsFixed(2)}'),
            _row('Paid'.tr, '\$${paid.toStringAsFixed(2)}'),
            _row('Remaining'.tr,
                '\$${(total - paid).toStringAsFixed(2)}'),

            const SizedBox(height: 16),

            /// Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReservationDetailsScreen(
                              bookingCode: bookingCode),
                        ),
                      );
                    },
                    child: Text('Details'.tr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<HomeProvider>(context, listen: false)
                          .downloadInvoice(bookingCode);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                    ),
                    child: Text('Invoice'.tr),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, color: kPrimaryColor,fontWeight: FontWeight.w500)),
          Text(value,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14, fontWeight: FontWeight.w400,color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _dateColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
