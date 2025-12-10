import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/reservation/reservation_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Model for booking data
class BookingModel {
  final String id;
  final String propertyName;
  final String checkIn;
  final String checkOut;
  final String bookingDate;
  final int nights;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String propertyType;

  BookingModel({
    required this.id,
    required this.propertyName,
    required this.checkIn,
    required this.checkOut,
    required this.bookingDate,
    required this.nights,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.propertyType,
  });

  // Factory constructor to create BookingModel from API JSON
  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      propertyName: json['property_name']?.toString() ?? '',
      checkIn: json['check_in']?.toString() ?? '',
      checkOut: json['check_out']?.toString() ?? '',
      bookingDate: json['booking_date']?.toString() ?? '',
      nights: int.tryParse(json['nights']?.toString() ?? '0') ?? 0,
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      paidAmount:
          double.tryParse(json['paid_amount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? '',
      propertyType: json['property_type']?.toString() ?? '',
    );
  }
}

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String selectedFilter = 'All Bookings'.tr;
  List<String> filterOptions = [
    'All Bookings'.tr,
    'Completed'.tr,
    // 'Active'.tr,
    'Processing'.tr,
    'Confirmed'.tr,
    // 'Cancelled'.tr,
    // 'Paid'.tr,
    // 'Unpaid'.tr
  ];

  int calculateDuration(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 0;
    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);
    return end.difference(start).inDays;
  }

  String formatDate(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString); // Parse input
      return DateFormat('dd/MM/yyyy').format(parsedDate); // Format date
    } catch (e) {
      print('Date parsing error: $e');
      return ''; // Return empty string if parsing fails
    }
  }

  @override
  void initState() {
    super.initState();

    Provider.of<HomeProvider>(context, listen: false).fetchBookingHistory();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<HomeProvider>(context);

    // Add this filtered data logic
    var filteredBookings =
        bookingProvider.bookingHistoryResponse?.data?.where((booking) {
      if (selectedFilter == 'All Bookings') return true;

      // Convert status to match filter options
      String bookingStatus = (booking.status ?? '').toLowerCase();
      String filter = selectedFilter.toLowerCase();

      switch (filter) {
        case 'completed':
          return bookingStatus == 'completed'.tr;
        // case 'active':
        //   return bookingStatus == 'active';
        case 'processing':
          return bookingStatus == 'processing';
        case 'confirmed':
          return bookingStatus == 'confirmed';
        // case 'cancelled':
        //   return bookingStatus == 'cancelled';
        // case 'paid':
        //   return booking.paid == booking.paid;
        // case 'unpaid':
        //   return booking.paid != booking.total;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Booking History'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Filter dropdown
              Container(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFilter,
                      items: filterOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedFilter = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Booking list

              if (filteredBookings != null)
                ...(filteredBookings)
                    .map((element) {
                      return BookingCard(
                        bookingCode: element.code ?? '',
                        type: element.objectModel ?? "",
                        vehicle: element.service?.title ?? "",
                        orderDate: formatDate(element.createdAt ?? ""),
                        startDate: formatDate(element.startDate ?? ''),
                        endDate: formatDate(element.endDate ?? ''),
                        duration:
                            '${calculateDuration(element.startDate, element.endDate)} ${calculateDuration(element.startDate, element.endDate) > 1 ? 'nights' : 'night'}',
                        total: double.parse(element.total ?? '0'),
                        paid: double.parse(element.paid ?? '0'),
                        status: element.status ?? '',
                      );
                    })
                    .toList()
                    .reversed
            ],
          ),
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final String type;
  final String vehicle;
  final String orderDate;
  final String startDate;
  final String endDate;
  final String duration;
  final double total;
  final double paid;
  final String status;
  final String bookingCode;

  const BookingCard({
    Key? key,
    required this.type,
    required this.vehicle,
    required this.orderDate,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.total,
    required this.paid,
    required this.status,
    required this.bookingCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: Colors.blue[400],
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Vehicle name
            Text(
              vehicle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            //details
            BookingDetailRow(label: 'Order Date'.tr, value: orderDate),
            // BookingDetailRow(label: 'Execution Time', value: ''),
            // const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: BookingDateSection(
                startDate: startDate,
                endDate: endDate,
                duration: duration,
              ),
            ),
            const SizedBox(height: 16),
            // Payment details
            BookingDetailRow(label: 'Total'.tr, value: '\$${total}'),
            BookingDetailRow(label: 'Paid'.tr, value: '\$${paid}'),
            BookingDetailRow(
              label: 'Remain'.tr,
              value: '\$${total - paid}',
            ),
            BookingDetailRow(label: 'Status'.tr, value: status),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationDetailsScreen(
                              bookingCode: bookingCode),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text('Details'.tr, style: TextStyle(color: grey1)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<HomeProvider>(context, listen: false)
                          .downloadInvoice(bookingCode);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: kSecondaryColor,
                    ),
                    child: Text('Invoice'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BookingDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const BookingDetailRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 14, color: kPrimaryColor, fontFamily: 'Inter'),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: grey1,
            ),
          ),
        ],
      ),
    );
  }
}

class BookingDateSection extends StatelessWidget {
  final String startDate;
  final String endDate;
  final String duration;

  const BookingDateSection({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Start Date'.tr,
          style: TextStyle(
              fontSize: 14,
              color: kPrimaryColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500),
        ),
        Text(
          startDate,
          style: const TextStyle(
              fontSize: 14,
              color: grey1,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 8),
        Text(
          'End Date'.tr,
          style: TextStyle(
              fontSize: 14,
              color: kPrimaryColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500),
        ),
        Text(
          endDate,
          style: const TextStyle(
              fontSize: 14,
              color: grey1,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400),
        ),
        SizedBox(height: 8),
        Text(
          'Duration'.tr,
          style: TextStyle(
              fontSize: 14,
              color: kPrimaryColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500),
        ),
        Text(
          duration,
          style: const TextStyle(
              fontSize: 14,
              color: grey1,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
