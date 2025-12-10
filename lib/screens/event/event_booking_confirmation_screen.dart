// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/screens/event/event_detail_screen.dart';
import 'package:moonbnd/screens/hotel/hotel_booking_history_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// ignore: must_be_immutable
class BookingConfirmedScreenForEvent extends StatefulWidget {
  final String bookingCode;
  List<PersonTypeForEvent> txpersonTypes;
  BookingConfirmedScreenForEvent(
      {super.key, required this.bookingCode, required this.txpersonTypes});

  @override
  State<BookingConfirmedScreenForEvent> createState() =>
      _BookingConfirmedScreenState();
}

class _BookingConfirmedScreenState
    extends State<BookingConfirmedScreenForEvent> {
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
    // ignore: deprecated_member_use
    WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              return BottomNav();
            },
          ),
          (route) => false,
        );
        return true;
      },
      child: Container(), // This container is just a placeholder
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset('assets/icons/arrowleft.svg'),
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) {
                return BottomNav();
              },
            ),
            (route) => false,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/icons/shareicon.svg'),
            onPressed: () async {
              await Share.share(
                  hotelbookingdata.bookingResponse?.data?.booking?.shareUrl ??
                      "");
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
                hotelbookingdata.bookingResponse?.data?.booking?.service
                        ?.vendorDetails?.email ??
                    '',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter'.tr,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w400,
                    color: kPrimaryColor),
              ),
              _buildInfoRow(
                  'Booking Number'.tr,
                  (hotelbookingdata.bookingResponse?.data?.booking!.id ?? 0)
                      .toString()),
              _buildInfoRow(
                  'Booking Date'.tr,
                  DateFormat("dd/MM/yyyy").format(DateTime.parse(
                      "${hotelbookingdata.bookingResponse?.data?.booking?.createdAt}"))),
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
                  // MaterialPageRoute(
                  //   builder: (context) => const BottomNav(),
                  // );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BookingHistoryScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
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
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter'.tr,
                    color: kPrimaryColor)),
          ),
          Spacer(),
          Container(
            alignment: Alignment.centerRight,
            width: 200,
            child: Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Inter'.tr,
                    color: grey)),
          ),
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Text(
                      hotelbookingdata
                              .bookingResponse?.data?.booking?.service?.title ??
                          '',
                      maxLines: 2,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Inter'.tr,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 250,
                  child: Text(
                      hotelbookingdata.bookingResponse?.data?.booking?.service
                              ?.address ??
                          '',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Inter'.tr,
                      )),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
        _buildInfoRow(
            'Start Date'.tr,
            DateFormat("dd/MM/yyyy").format(
              DateTime.parse(
                  "${hotelbookingdata.bookingResponse?.data?.booking?.startDate}"),
            )),
        SizedBox(height: 10),
        ...(widget.txpersonTypes).map((element) {
          return widget.txpersonTypes.isEmpty
              ? Center()
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (element.desc != "0")
                              Text(element.name,
                                  style: TextStyle(
                                      fontFamily: 'Inter'.tr,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: kPrimaryColor)),
                            if (element.desc != "0")
                              Text("\$${element.desc}",
                                  style: TextStyle(
                                      fontFamily: 'Inter'.tr,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey)),
                          ],
                        ),
                        Text("${element.countValue}",
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Inter'.tr,
                                fontWeight: FontWeight.w400,
                                color: grey)),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                );
        }),
        Divider(color: Colors.grey, thickness: 1),
        _buildInfoRow(
          'Rental Price'.tr,
          "\$${hotelbookingdata.bookingResponse?.data?.booking?.service?.salePrice == 0 ? hotelbookingdata.bookingResponse?.data?.booking?.service?.price : hotelbookingdata.bookingResponse?.data?.booking?.service?.salePrice}",
        ),
        ...(hotelbookingdata.bookingResponse?.data?.booking?.buyerFees)!
            .map((element) {
          return _buildInfoRow(element.name ?? "", "\$${element.price}");
        }),
        ...(hotelbookingdata.bookingResponse?.data?.booking?.extraPrice)!
            .map((element) {
          return _buildInfoRow(element.name ?? "", "\$${element.price}");
        }),
        Divider(color: Colors.grey, thickness: 1),
        _buildTotal(
          'Total'.tr,
          "\$${hotelbookingdata.bookingResponse?.data?.booking?.total ?? ""}",
        ),
        _buildTotal('Paid'.tr,
            '\$${hotelbookingdata.bookingResponse?.data?.booking?.paid ?? ""}'),
        _buildTotal(
          'Remain'.tr,
          "\$${hotelbookingdata.bookingResponse?.data?.booking?.payNow ?? ""}",
        ),
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
        _buildInfoRow('City'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.city ?? ''),
        _buildInfoRow('State/Province/Region'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.state ?? ''),
        _buildInfoRow('ZIP code/Postal code'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.zipCode ?? ''),
        _buildInfoRow('Country'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.country ?? ''),
        _buildInfoRow(
            'Special Requirements'.tr,
            hotelbookingdata.bookingResponse?.data?.booking?.customerNotes ??
                ''),
      ],
    );
  }
}
