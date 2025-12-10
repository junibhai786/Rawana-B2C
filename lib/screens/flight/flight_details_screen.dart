import 'dart:developer';

import 'package:moonbnd/Provider/flight_provider.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/screens/flight/flight_booking_screen.dart';
import 'package:moonbnd/widgets/popup_login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlightDetailsScreen extends StatefulWidget {
  final int flightId;
  const FlightDetailsScreen({super.key, required this.flightId});

  @override
  _FlightDetailsState createState() => _FlightDetailsState();
}

class _FlightDetailsState extends State<FlightDetailsScreen> {
  bool loading = false;
  double totalPrice = 0.0;

  final Map<String, GlobalKey<_AirlineTicketBookingState>> _ticketKeys = {};

  @override
  void initState() {
    super.initState();
    Provider.of<FlightProvider>(context, listen: false)
        .fetchFlightDetails(widget.flightId);
  }

  void calculateTotalPrice() {
    if (mounted) {
      setState(() {
        final flightData = Provider.of<FlightProvider>(context, listen: false)
            .flightDetail
            ?.data;
        totalPrice = 0.0;

        flightData?.flightSeat?.forEach((seat) {
          double seatPrice = double.tryParse(seat.price ?? '0.0') ?? 0.0;
          int passengerCount =
              _ticketKeys[seat.seatType?.name ?? '']?.currentState?._number ??
                  1;
          totalPrice += seatPrice * passengerCount;
        });
      });
    }
  }

  Future<void> _handleBookNow() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('userToken');

    if (token == null) {
      // Show the custom bottom sheet
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        builder: (context) => CustomBottomSheet(
          title: 'Log in to add to'.tr,
          content: 'your booking'.tr,
          onCancel: () {
            Navigator.of(context).pop(); // Close the bottom sheet
          },
          onLogin: () {
            // Close the bottom sheet
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SignInScreen()),
            ); // Navigate to SignInScreen
          },
        ),
      );
      return; // Exit the function if token is null
    }

    final flightData =
        Provider.of<FlightProvider>(context, listen: false).flightDetail?.data;
    if (flightData == null) return;

    List<Map<String, dynamic>> flightSeats = [];

    // Prepare flight seats data
    flightData.flightSeat?.forEach((seat) {
      final seatKey = _ticketKeys[seat.seatType?.name ?? ''];
      final number = seatKey?.currentState?._number ?? 0;

      if (number > 0) {
        flightSeats.add({
          'id': seat.id,
          'price': seat.price,
          'seat_type': {
            'id': seat.seatType?.id,
            'code': seat.seatType?.code,
          },
          'number': number,
        });
      }
    });

    if (flightSeats.isEmpty) {
      // Show error message if no seats selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one seat')),
      );
      return;
    }

    try {
      final result = await Provider.of<FlightProvider>(context, listen: false)
          .addToCartForFlight(
        serviceId: flightData.id.toString(),
        flightSeats: flightSeats,
      );

      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FlightBookingScreen(bookingCode: result['booking_code']),
          ),
        );
        // Success - Navigate to cart or show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully added to booking'.tr)),
        );
      } else {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to booking'.tr)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = Provider.of<FlightProvider>(context, listen: true);
    final flightData = item.flightDetail?.data;

    // Initialize keys for each seat type
    flightData?.flightSeat?.forEach((seat) {
      final seatName = seat.seatType?.name ?? '';
      if (!_ticketKeys.containsKey(seatName)) {
        _ticketKeys[seatName] = GlobalKey<_AirlineTicketBookingState>();
      }
    });

    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.network(
                            item.flightDetail?.data?.airline?.imageUrl ?? '',
                            width: 68,
                            height: 52,
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 200,
                            child: Text(
                                '${item.flightDetail?.data?.title} | ${item.flightDetail?.data?.code}'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildFlightInfo(
                              'Take Off'.tr,
                              DateFormat('HH:mm').format(
                                  DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
                                      item.flightDetail?.data?.departureTime ??
                                          '')),
                              DateFormat('dd MMM, yyyy').format(
                                  DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
                                      item.flightDetail?.data?.departureTime ??
                                          '')),
                              item.flightDetail?.data?.airportTo?.name ?? ''),
                          Center(
                            child: Text(
                              '${item.flightDetail?.data?.duration} hrs'.tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          _buildFlightInfo(
                              'Landing'.tr,
                              DateFormat('HH:mm').format(
                                  DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
                                      item.flightDetail?.data?.arrivalTime ??
                                          '')),
                              DateFormat('dd MMM, yyyy').format(
                                  DateFormat('yyyy-MM-ddTHH:mm:ss.SSSZ').parse(
                                      item.flightDetail?.data?.arrivalTime ??
                                          '')),
                              item.flightDetail?.data?.airportFrom?.name ?? ''),
                        ],
                      ),
                      SizedBox(height: 16),
                      ...flightData?.flightSeat
                              ?.map((seat) => Column(
                                    children: [
                                      AirlineTicketBooking(
                                        key: _ticketKeys[
                                            seat.seatType?.name ?? ''],
                                        baggage: seat.person ?? 'person',
                                        checkIn:
                                            '${seat.baggageCheckIn ?? 6} kgs',
                                        cabin: '${seat.baggageCabin ?? 6} kgs',
                                        price: double.tryParse(
                                                seat.price ?? '22.0') ??
                                            22.0,
                                        name: seat.seatType?.name ?? 'Premium',
                                        onNumberChanged: (value) {
                                          calculateTotalPrice();
                                        },
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ))
                              .toList() ??
                          [],
                      Divider(
                        height: 20,
                        thickness: 1,
                        color: kColor1,
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total'.tr,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$${totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                        ),
                        child: TertiaryButton(
                          text: "Book Now".tr,
                          press: _handleBookNow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFlightInfo(
      String title, String time, String date, String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                fontFamily: 'Inter',
                color: kSecondaryColor)),
        SizedBox(height: 5),
        Text(time,
            style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                fontFamily: 'Inter')),
        SizedBox(height: 5),
        Text(date,
            style: TextStyle(
                color: Colors.grey, fontSize: 12, fontFamily: 'Inter')),
        Text(location,
            style: TextStyle(
                color: Colors.grey, fontSize: 12, fontFamily: 'Inter')),
      ],
    );
  }
}

class AirlineTicketBooking extends StatefulWidget {
  final String baggage;
  final String checkIn;
  final String cabin;
  final double price;
  final String name;
  final Function(int) onNumberChanged;

  const AirlineTicketBooking({
    super.key,
    required this.baggage,
    required this.checkIn,
    required this.cabin,
    required this.price,
    required this.name,
    required this.onNumberChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AirlineTicketBookingState createState() => _AirlineTicketBookingState();
}

class _AirlineTicketBookingState extends State<AirlineTicketBooking> {
  int _number = 0;
  bool isExpanded = false;

  void _updateNumber(int newValue) {
    setState(() {
      _number = newValue;
      widget.onNumberChanged(_number); // Call the callback when number changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kColor1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionPanelList(
        dividerColor: Colors.transparent,
        expandedHeaderPadding: EdgeInsets.zero,
        elevation: 0,
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            this.isExpanded = !this.isExpanded;
          });
        },
        children: [
          ExpansionPanel(
            backgroundColor: Colors.transparent,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(widget.name),
              );
            },
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn('Baggage'.tr, widget.baggage),
                          Align(
                            alignment: Alignment.centerRight,
                            child:
                                _buildInfoColumn('Check In'.tr, widget.checkIn),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: kColor1, height: 1),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn('Cabin'.tr, widget.cabin),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildInfoColumn('Price'.tr,
                                '\$${widget.price.toStringAsFixed(2)}'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Number'.tr),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              if (_number > 1) {
                                _updateNumber(_number - 1);
                              }
                            },
                            child: Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: kColor1),
                                borderRadius: BorderRadius.circular(5),
                                color: kBackgroundColor,
                              ),
                              child: Icon(Icons.remove,
                                  size: 20, color: kPrimaryColor),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('$_number'),
                          SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              _updateNumber(_number + 1);
                            },
                            child: Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                border: Border.all(color: kColor1),
                                borderRadius: BorderRadius.circular(5),
                                color: kBackgroundColor,
                              ),
                              child: Icon(Icons.add,
                                  size: 20, color: kPrimaryColor),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ListTile(
                //   title: Text('Number'),
                //   trailing: Row(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       IconButton(
                //         icon: Icon(Icons.remove),
                //         onPressed: () {
                //           setState(() {
                //             if (_number > 1) {
                //               _number--;
                //             }
                //           });
                //         },
                //       ),
                //       Text('$_number'),
                //       IconButton(
                //         icon: Icon(Icons.add),
                //         onPressed: () {
                //           setState(() {
                //             _number++;
                //           });
                //         },
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
            isExpanded: isExpanded,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String title1, String info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title1, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text(info, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
