// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ReservationDetailsScreen extends StatefulWidget {
  final String bookingCode;
  ReservationDetailsScreen({super.key, required this.bookingCode});
  @override
  _ReservationDetailsScreenState createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState extends State<ReservationDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  int calculateNights(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 0;

    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    return end.difference(start).inDays; // Calculate difference in days
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchBookingDetails();
  }

  Future<void> _fetchBookingDetails() async {
    setState(() => _isLoading = true);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.fetchBookingDetails(widget.bookingCode);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final hotelbookingdata = Provider.of<HomeProvider>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(
                  'Check out this reservation: ${hotelbookingdata.bookingResponse?.data?.booking?.shareUrl}');
            },
          ),
        ],
        // title: Text('Reservation Details'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reservation Details'.tr,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: kPrimaryColor,
                            fontFamily: 'Inter'.tr),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${'Booking ID:'.tr} ${hotelbookingdata.bookingResponse?.data?.booking?.id}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Inter'.tr,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        width: 3.0,
                        color:
                            kPrimaryColor, // Color of the selected tab indicator
                      ),
                    ),
                    labelColor: kPrimaryColor, // Selected tab text color
                    unselectedLabelColor:
                        Colors.grey, // Unselected tab text color
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: [
                      Tab(
                        child: Text(
                          'Booking Details'.tr,
                          style: TextStyle(
                              color: _tabController.index == 0
                                  ? kPrimaryColor
                                  : grey,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Personal Information'.tr,
                          style: TextStyle(
                              color: _tabController.index == 1
                                  ? kPrimaryColor
                                  : grey,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildBookingDetailsTab(),
                      _buildPersonalInformationTab(),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        child: TertiaryButton(
            text: "Download Invoice".tr,
            press: () {
              Provider.of<HomeProvider>(context, listen: false)
                  .downloadInvoice(widget.bookingCode);
            }),
      ),
      ),
    );
  }

  Widget _buildBookingDetailsTab() {
    final hotelbookingdata = Provider.of<HomeProvider>(context, listen: true);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildDetailRow('Booking Status'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.status ?? ''),
          _buildDetailRow(
              'Booking Date'.tr,
              DateFormat('d MMM yyyy').format(DateTime.parse(hotelbookingdata
                      .bookingResponse?.data?.booking?.createdAt
                      .toString() ??
                  DateTime.now().toString()))),
          _buildDetailRow('Payment Method'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.gateway ?? ''),
          _buildDetailRow(
              'Check in'.tr,
              DateFormat('d MMM yyyy').format(DateTime.parse(hotelbookingdata
                      .bookingResponse?.data?.booking?.startDate
                      .toString() ??
                  DateTime.now().toString()))),
          _buildDetailRow(
              'Check out'.tr,
              DateFormat('d MMM yyyy').format(DateTime.parse(hotelbookingdata
                      .bookingResponse?.data?.booking?.endDate
                      .toString() ??
                  DateTime.now().toString()))),
          _buildDetailRow('Nights'.tr,
              '${calculateNights(hotelbookingdata.bookingResponse?.data?.booking?.startDate, hotelbookingdata.bookingResponse?.data?.booking?.endDate)}'),
          _buildDetailRow(
              'Guests'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.totalGuests
                      .toString() ??
                  ''),
          ...(hotelbookingdata
                      .bookingResponse?.data?.booking?.service?.roomDetails ??
                  [])
              .map((element) {
            return _buildDetailRow("${element.roomTitle} * ${element.number}",
                "\$${element.price}");
          }),
          Divider(height: 32, thickness: 1),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Extra Prices'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 16),
          ...(hotelbookingdata.bookingResponse?.data?.booking?.extraPrice)!
              .map((element) {
            return _buildDetailRow(element.name ?? "", "\$${element.price}");
          }),
          ...(hotelbookingdata.bookingResponse?.data?.booking?.buyerFees)!
              .map((element) {
            return _buildDetailRow(element.name ?? "", "\$${element.price}");
          }),
          Divider(height: 32, thickness: 1),
          _buildDetailRow('Total'.tr,
              '\$${hotelbookingdata.bookingResponse?.data?.booking?.total ?? '0'}',
              isBold: true),
          _buildDetailRow('Paid'.tr,
              '\$${hotelbookingdata.bookingResponse?.data?.booking?.paid ?? '0'}',
              isBold: true),
          _buildDetailRow('Remain'.tr,
              '\$${hotelbookingdata.bookingResponse?.data?.booking?.payNow ?? '0'}',
              isBold: true),
          Divider(
            height: 20,
            thickness: 1,
            endIndent: 0,
            indent: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationTab() {
    final hotelbookingdata = Provider.of<HomeProvider>(context, listen: true);
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPersonalDetailRow('First Name'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.firstName ?? ''),
          _buildPersonalDetailRow('Last Name'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.lastName ?? ''),
          _buildPersonalDetailRow('Email'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.email ?? ''),
          _buildPersonalDetailRow('Phone'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.phone ?? ''),
          _buildPersonalDetailRow('Address 1'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.address ?? ''),
          _buildPersonalDetailRow('Address 2'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.address2 ?? ''),
          _buildPersonalDetailRow('Country'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.country ?? ''),
          _buildPersonalDetailRow('State'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.state ?? ''),
          _buildPersonalDetailRow('City'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.city ?? ''),
          _buildPersonalDetailRow('ZIP Code'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.zipCode ?? ''),
          _buildPersonalDetailRow(
              'Special Requirements'.tr,
              hotelbookingdata.bookingResponse?.data?.booking?.customerNotes ??
                  ''),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? kPrimaryColor : grey,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                color: isBold ? kPrimaryColor : grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
                color: kPrimaryColor,
                fontSize: 16,
                fontFamily: 'Inter'.tr,
                fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: grey,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
