import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/manage_coupon_model.dart';
import 'package:moonbnd/screens/manage%20coupon/manage_add_coupon_screen.dart';
import 'package:moonbnd/screens/manage%20coupon/manage_edit_coupon_screen%20copy.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AllManageCouponScreen extends StatefulWidget {
  const AllManageCouponScreen({super.key});

  @override
  State<AllManageCouponScreen> createState() => _AllManageCouponScreenState();
}

class _AllManageCouponScreenState extends State<AllManageCouponScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    setState(() {
      loading = true;
    });
    Provider.of<HomeProvider>(context, listen: false)
        .fetchVendorCoupons()
        .then((value) {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    final item = Provider.of<HomeProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Coupons'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Filter dropdown

                  const SizedBox(height: 16),
                  // Booking list
                  Expanded(
                    child: ListView.builder(
                      itemCount: item.couponResponseList?.data.length ?? 0,
                      itemBuilder: (context, index) {
                        final booking = item.couponResponseList?.data[index];

                        return BookingCard(
                          booking: item.couponResponseList?.data[index],
                          id: booking?.id ?? 0,
                          endDate: formatDate(booking?.endDate ?? ""),
                          amount: booking?.amount ?? 0,
                          discountType: booking?.discountType ?? "",
                          status: booking?.status ?? "",
                          name: booking?.name ?? "",
                          newYear: booking?.code ?? "",
                          context: context,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return ManageAddCouponScreen();
                          },
                        ));
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.black),
                      ),
                      child: Text('+ Add New Coupon'.tr,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final int id;
  final String name;
  final String newYear;
  final CouponManage? booking;
  final int amount;
  final String discountType;
  final String endDate;
  final String status;
  final BuildContext context;

  const BookingCard({
    Key? key,
    required this.id,
    required this.booking,
    required this.name,
    required this.newYear,
    required this.amount,
    required this.discountType,
    required this.endDate,
    required this.status,
    required this.context,
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
              // decoration: BoxDecoration(
              //   color: AppColors.primary.withOpacity(0.50),
              //   borderRadius: BorderRadius.circular(16),
              // ),
              child: Text(
                newYear,
                style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            // Vehicle name

            //details

            // const SizedBox(height: 8),

            // Payment details
            BookingDetailRow(label: name, value: ''),
            BookingDetailRow(label: 'Amount'.tr, value: '\$$amount'),
            BookingDetailRow(label: 'Discount Type'.tr, value: discountType),
            BookingDetailRow(label: 'End Date'.tr, value: endDate),
            BookingDetailRow(label: 'Status'.tr, value: status),

            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await Provider.of<HomeProvider>(context, listen: false)
                          .deleteVendorCoupon(id.toString())
                          .then((value) {
                        if (value) {
                          // ignore: use_build_context_synchronously
                          Provider.of<HomeProvider>(context, listen: false)
                              .fetchVendorCoupons();
                        } else {}
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.red),
                    ),
                    child:
                        Text('Delete'.tr, style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return ManageEditCouponScreen(booking);
                        },
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: kSecondaryColor,
                    ),
                    child: Text('Edit'.tr),
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
