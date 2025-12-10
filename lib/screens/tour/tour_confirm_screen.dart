// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, unnecessary_to_list_in_spreads

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/hotel/hotel_booking_history_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class TourConfirmScreen extends StatefulWidget {
  final String bookingCode;
  const TourConfirmScreen({super.key, required this.bookingCode});

  @override
  State<TourConfirmScreen> createState() => _TourConfirmScreenState();
}

class _TourConfirmScreenState extends State<TourConfirmScreen> {
  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.fetchBookingDetails(widget.bookingCode);
    // Trigger a rebuild after fetching data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hotelbookingdata = Provider.of<HomeProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/arrowleft.svg'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/icons/shareicon.svg'),
            onPressed: () {
              Share.share(
                  'Check out my booking details: ${hotelbookingdata.bookingResponse?.data?.booking?.shareUrl}');
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Booking Confirmed'.tr,
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.green,
                          fontFamily: 'Inter'.tr,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    Container(
                        padding: EdgeInsets.all(10),
                        child: SvgPicture.asset('assets/icons/greentick.svg')),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Booking details has been sent to'.tr,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter'.tr,
                    color: kPrimaryColor),
              ),
              Text(
                hotelbookingdata.bookingResponse?.data?.booking?.email ?? '',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter'.tr,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w400,
                    color: kPrimaryColor),
              ),
              _buildInfoRow(
                  'Booking Number'.tr,
                  (hotelbookingdata.bookingResponse?.data?.booking?.id ?? 0)
                      .toString()),
              _buildInfoRow(
                  'Booking Date'.tr,
                  DateFormat('d MMM yyyy').format(DateTime.parse(
                      hotelbookingdata.bookingResponse?.data?.booking?.createdAt
                              .toString() ??
                          DateTime.now().toString()))),
              _buildInfoRow(
                  'Payment Method'.tr,
                  (hotelbookingdata.bookingResponse?.data?.booking?.gateway ??
                      '')),
              SizedBox(height: 10),
              _buildStatusRow(
                  'Booking Status'.tr,
                  (hotelbookingdata.bookingResponse?.data?.booking?.status ??
                      "")),
              SizedBox(height: 20),
              Divider(
                thickness: 1,
              ),
              SizedBox(height: 20),
              Text('Your Booking'.tr,
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inter'.tr,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor)),
              SizedBox(height: 10),
              _buildBookingDetails(),
              SizedBox(height: 20),
              Text('Your Information'.tr,
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inter'.tr,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor)),
              SizedBox(height: 10),
              _buildUserInfo(),
              SizedBox(height: 20),
              ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Booking History'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Inter'.tr,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: kSecondaryColor,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookingHistoryScreen(),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(width: 1, color: Colors.black12)),
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) {
                        return BottomNav();
                      },
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  "Back to Home".tr,
                  style: TextStyle(
                    fontFamily: 'Inter'.tr,
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter'.tr,
                  color: kPrimaryColor)),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Inter'.tr,
                  color: grey)),
        ],
      ),
    );
  }

  Widget _buildTotal(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter'.tr,
                  color: kPrimaryColor)),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter'.tr,
                  color: kPrimaryColor)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String status) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 16,
                  color: kPrimaryColor,
                  fontFamily: 'Inter'.tr,
                  fontWeight: FontWeight.w500)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: kSecondaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(status,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter'.tr,
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    final hotelbookingdata = Provider.of<HomeProvider>(context, listen: true);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                hotelbookingdata
                        .bookingResponse?.data?.booking?.service!.gallery?[0] ??
                    'assets/haven/house.png',
                width: 96,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: Text(
                    hotelbookingdata
                            .bookingResponse?.data?.booking?.service?.title ??
                        '',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Inter'.tr,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                    hotelbookingdata
                            .bookingResponse?.data?.booking?.service?.address ??
                        '',
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Inter'.tr,
                    )),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        _buildInfoRow('Dates'.tr,
            '${DateFormat('d MMM').format(DateTime.parse(hotelbookingdata.bookingResponse?.data?.booking?.startDate ?? DateTime.now().toString()))} - ${DateFormat('d MMM').format(DateTime.parse(hotelbookingdata.bookingResponse?.data?.booking?.endDate ?? DateTime.now().toString()))}'),
        ...(hotelbookingdata.bookingResponse?.data?.booking?.personTypes ?? [])
            .map((personType) => _buildInfoRow(
                "${personType.name}: ${personType.number} x \$${personType.price}",
                "\$${(double.parse(personType.number ?? "0") * double.parse(personType.price ?? "0")).toStringAsFixed(2)}"))
            .toList(),
        ...(hotelbookingdata.bookingResponse?.data?.booking?.buyerFees ?? [])
            .map((element) =>
                _buildInfoRow(element.name ?? "", "\$${element.price}"))
            .toList(),
        ...(hotelbookingdata.bookingResponse?.data?.booking?.extraPrice ?? [])
            .map((element) =>
                _buildInfoRow(element.name ?? "", "\$${element.price}"))
            .toList(),
        Divider(),
        _buildTotal('Total'.tr,
            '\$${hotelbookingdata.bookingResponse?.data?.booking?.total ?? '0'}'),
        _buildTotal('Paid'.tr,
            '\$${hotelbookingdata.bookingResponse?.data?.booking?.paid ?? '0'}'),
        _buildTotal('Remain'.tr,
            '\$${hotelbookingdata.bookingResponse?.data?.booking?.payNow ?? '0'}'),
        Divider(),
      ],
    );
  }

  Widget _buildUserInfo() {
    final hotelbookingdata = Provider.of<HomeProvider>(context, listen: true);
    return Column(
      children: [
        _buildInfoRow('First Name'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.firstName ?? ''),
        _buildInfoRow('Last Name'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.lastName ?? ''),
        _buildInfoRow('Email'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.email ?? ''),
        _buildInfoRow('Phone'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.phone ?? ''),
        _buildInfoRow('Address line 1'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.address ?? ''),
        _buildInfoRow('Address line 2'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.address2 ?? ''),
        _buildInfoRow('Country'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.country ?? ''),
        _buildInfoRow('State/Province/Region'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.state ?? ''),
        _buildInfoRow('City'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.city ?? ''),
        _buildInfoRow('ZIP code/Postal code'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.zipCode ?? ''),
        _buildInfoRow(
            'Special Requirements'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.customerNotes ??
                ''),
      ],
    );
  }
}
