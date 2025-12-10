// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/screens/hotel/hotel_booking_history_screen.dart';
import 'package:moonbnd/vendor/boat/mange_boat_screen.dart';
import 'package:moonbnd/vendor/car/managecarscreen.dart';
import 'package:moonbnd/vendor/event/all_event_screen.dart';
import 'package:moonbnd/vendor/flight/manage_all_flight_screen.dart';
import 'package:moonbnd/vendor/hotel/manage_hotel_screen.dart';
import 'package:moonbnd/vendor/space/all_space_screen.dart';
import 'package:moonbnd/vendor/tour/manage_tour_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool loading = false;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    setState(() {
      loading = true;
    });

    try {
      final provider = Provider.of<VendorAuthProvider>(context, listen: false);

      // Fetch notifications sequentially
      await provider.fetchnotification();
      await provider.fetchunreadnotification();
      await provider.fetchreadnotification();
    } catch (error) {
      // Handle any errors here
      print('Error fetching notifications: $error');
    } finally {
      // Ensure loading is set to false even if there's an error
      setState(() {
        loading = false;
      });
    }
  }

  String formatTimestamp(String? dateString) {
    if (dateString == null) return 'Invalid Date';

    DateTime parsedDate = DateTime.parse(dateString);
    DateTime times = DateTime.utc(parsedDate.year, parsedDate.month,
        parsedDate.day, parsedDate.hour, parsedDate.minute, parsedDate.second);

    Duration difference = DateTime.now().difference(times);

    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;
    int seconds = difference.inSeconds % 60;

    StringBuffer result = StringBuffer();

    if (days > 0) result.write('$days day${days > 1 ? 's' : ''} ');
    if (hours > 0) result.write('$hours hour${hours > 1 ? 's' : ''} ');
    if (minutes > 0) result.write('$minutes minute${minutes > 1 ? 's' : ''} ');
    if (seconds > 0 || result.isEmpty) {
      result.write('$seconds second${seconds > 1 ? 's' : ''}');
    }

    return result.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorAuthProvider>(context, listen: true);
    return WillPopScope(
        onWillPop: () async {
          provider.fetchunreadnotificationcount();
          // Call the API before popping
          // await provider.fetchunreadnotificationcount();
          return true; // Allow the screen to pop
        },
        child: loading
            ? Center(
                child: CircularProgressIndicator(
                  color: kSecondaryColor,
                ),
              )
            : Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/arrowleft.svg',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedFilter == "All".tr
                                ? "All Notifications".tr
                                : selectedFilter == "Unread".tr
                                    ? "Unread Notifications".tr
                                    : "Read Notification".tr,
                            style: TextStyle(
                              fontSize: 28,
                              fontFamily: 'Inter'.tr,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildSegment("All".tr),
                                const SizedBox(width: 8),
                                _buildSegment("Read".tr),
                                const SizedBox(width: 8),
                                _buildSegment("Unread".tr),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          //notifications list
                          selectedFilter == "All".tr
                              ? ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount:
                                      provider.notificationmodel?.data?.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        provider
                                                        .notificationmodel
                                                        ?.data?[index]
                                                        .datas
                                                        ?.notification
                                                        ?.event ==
                                                    'CreatePlanRequest' ||
                                                provider
                                                        .notificationmodel
                                                        ?.data?[index]
                                                        .datas
                                                        ?.notification
                                                        ?.event ==
                                                    'UpdatePlanRequest'
                                            ? Navigator.of(context)
                                                .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            BottomNav(
                                                              initialIndex: 2,
                                                            )), // 3 is the index for PricingPackagesScreen
                                                    (route) => false)
                                            : provider
                                                        .notificationmodel
                                                        ?.data?[index]
                                                        .datas
                                                        ?.notification
                                                        ?.event ==
                                                    'BookingUpdatedEvent'
                                                ? Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            BookingHistoryScreen()), // 3 is the index for PricingPackagesScreen
                                                  )
                                                : provider
                                                            .notificationmodel
                                                            ?.data?[index]
                                                            .datas
                                                            ?.notification
                                                            ?.event ==
                                                        'VendorApproved'
                                                    ? Navigator.of(context)
                                                        .push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                BottomNav(
                                                                  initialIndex:
                                                                      3,
                                                                )), // 3 is the index for PricingPackagesScreen
                                                      )
                                                    : (provider.notificationmodel?.data?[index].datas?.notification?.event ==
                                                                'UpdatedServiceEvent' &&
                                                            provider
                                                                    .notificationmodel
                                                                    ?.data?[index]
                                                                    .datas
                                                                    ?.notification
                                                                    ?.type ==
                                                                'hotel')
                                                        ? Navigator.of(context).push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ManageHotelScreen()), // 3 is the index for PricingPackagesScreen
                                                          )
                                                        : (provider.notificationmodel?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodel?.data?[index].datas?.notification?.type == 'car')
                                                            ? Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ManageCarScreen()), // 3 is the index for PricingPackagesScreen
                                                              )
                                                            : (provider.notificationmodel?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodel?.data?[index].datas?.notification?.type == 'boat')
                                                                ? Navigator.of(context).push(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ManageBoatScreen()), // 3 is the index for PricingPackagesScreen
                                                                  )
                                                                : (provider.notificationmodel?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodel?.data?[index].datas?.notification?.type == 'flight')
                                                                    ? Navigator.of(context).push(
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ManageAllFlightScreen()), // 3 is the index for PricingPackagesScreen
                                                                      )
                                                                    : (provider.notificationmodel?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodel?.data?[index].datas?.notification?.type == 'tour')
                                                                        ? Navigator.of(context).push(
                                                                            MaterialPageRoute(builder: (context) => ManageTourScreen()), // 3 is the index for PricingPackagesScreen
                                                                          )
                                                                        : (provider.notificationmodel?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodel?.data?[index].datas?.notification?.type == 'event')
                                                                            ? Navigator.of(context).push(
                                                                                MaterialPageRoute(builder: (context) => AllEventScreen()), // 3 is the index for PricingPackagesScreen
                                                                              )
                                                                            : (provider.notificationmodel?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodel?.data?[index].datas?.notification?.type == 'space')
                                                                                ? Navigator.of(context).push(
                                                                                    MaterialPageRoute(builder: (context) => AllSpaceScreen()), // 3 is the index for PricingPackagesScreen
                                                                                  )
                                                                                : null;
                                        provider
                                            .notificationread(
                                                id: provider.notificationmodel
                                                    ?.data?[index].datas?.id)
                                            .then((value) {
                                          if (value == true) {
                                            provider.fetchnotification();
                                            provider.fetchunreadnotification();
                                            provider.fetchreadnotification();
                                          }
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: provider.notificationmodel
                                                        ?.data?[index].readAt ==
                                                    null
                                                ? kColor1
                                                : Colors.white),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: 12,
                                                  bottom: 8,
                                                  left: 10,
                                                  right: 10),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    child: Image.network(
                                                      provider
                                                              .notificationmodel
                                                              ?.data?[index]
                                                              .datas
                                                              ?.notification
                                                              ?.avatar ??
                                                          "",
                                                      width: 48,
                                                      height: 48,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 12,
                                                  ),
                                                  Flexible(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Text(
                                                          provider
                                                                  .notificationmodel
                                                                  ?.data?[index]
                                                                  .datas
                                                                  ?.notification
                                                                  ?.message ??
                                                              "",
                                                          style: TextStyle(
                                                            color:
                                                                kPrimaryColor,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          formatTimestamp(provider
                                                                  .notificationmodel
                                                                  ?.data?[index]
                                                                  .createdAt ??
                                                              ""),
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color:
                                                                kPrimaryColor,
                                                          ),
                                                          textAlign:
                                                              TextAlign.left,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  // dataSrc.read
                                                  //     ? SizedBox.shrink()
                                                  //     : Icon(
                                                  //         Icons.fiber_manual_record,
                                                  //         color: kSecondaryColor,
                                                  //         size: 16,
                                                  //       )
                                                ],
                                              ),
                                            ),
                                            Divider(
                                              height: 4,
                                              color: Colors.grey.shade200,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : selectedFilter == "Unread".tr
                                  ? ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: provider
                                          .notificationmodelunread
                                          ?.data
                                          ?.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            provider
                                                            .notificationmodelunread
                                                            ?.data?[index]
                                                            .datas
                                                            ?.notification
                                                            ?.event ==
                                                        'CreatePlanRequest' ||
                                                    provider
                                                            .notificationmodelunread
                                                            ?.data?[index]
                                                            .datas
                                                            ?.notification
                                                            ?.event ==
                                                        'UpdatePlanRequest'
                                                ? Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                BottomNav(
                                                                  initialIndex:
                                                                      2,
                                                                )), // 3 is the index for PricingPackagesScreen
                                                        (route) => false)
                                                : provider
                                                            .notificationmodelunread
                                                            ?.data?[index]
                                                            .datas
                                                            ?.notification
                                                            ?.event ==
                                                        'BookingUpdatedEvent'
                                                    ? Navigator.of(context)
                                                        .push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                BookingHistoryScreen()), // 3 is the index for PricingPackagesScreen
                                                      )
                                                    : provider
                                                                .notificationmodelunread
                                                                ?.data?[index]
                                                                .datas
                                                                ?.notification
                                                                ?.event ==
                                                            'VendorApproved'
                                                        ? Navigator.of(context)
                                                            .push(
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    BottomNav(
                                                                      initialIndex:
                                                                          3,
                                                                    )), // 3 is the index for PricingPackagesScreen
                                                          )
                                                        : (provider.notificationmodelunread?.data?[index].datas?.notification?.event ==
                                                                    'UpdatedServiceEvent' &&
                                                                provider
                                                                        .notificationmodelunread
                                                                        ?.data?[index]
                                                                        .datas
                                                                        ?.notification
                                                                        ?.type ==
                                                                    'hotel')
                                                            ? Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ManageHotelScreen()), // 3 is the index for PricingPackagesScreen
                                                              )
                                                            : (provider.notificationmodelunread?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodelunread?.data?[index].datas?.notification?.type == 'car')
                                                                ? Navigator.of(context).push(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ManageCarScreen()), // 3 is the index for PricingPackagesScreen
                                                                  )
                                                                : (provider.notificationmodelunread?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodelunread?.data?[index].datas?.notification?.type == 'boat')
                                                                    ? Navigator.of(context).push(
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ManageBoatScreen()), // 3 is the index for PricingPackagesScreen
                                                                      )
                                                                    : (provider.notificationmodelunread?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodelunread?.data?[index].datas?.notification?.type == 'flight')
                                                                        ? Navigator.of(context).push(
                                                                            MaterialPageRoute(builder: (context) => ManageAllFlightScreen()), // 3 is the index for PricingPackagesScreen
                                                                          )
                                                                        : (provider.notificationmodelunread?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodelunread?.data?[index].datas?.notification?.type == 'tour')
                                                                            ? Navigator.of(context).push(
                                                                                MaterialPageRoute(builder: (context) => ManageTourScreen()), // 3 is the index for PricingPackagesScreen
                                                                              )
                                                                            : (provider.notificationmodelunread?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodelunread?.data?[index].datas?.notification?.type == 'event')
                                                                                ? Navigator.of(context).push(
                                                                                    MaterialPageRoute(builder: (context) => AllEventScreen()), // 3 is the index for PricingPackagesScreen
                                                                                  )
                                                                                : (provider.notificationmodelunread?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodelread?.data?[index].datas?.notification?.type == 'space')
                                                                                    ? Navigator.of(context).push(
                                                                                        MaterialPageRoute(builder: (context) => AllSpaceScreen()), // 3 is the index for PricingPackagesScreen
                                                                                      )
                                                                                    : null;
                                            provider
                                                .notificationread(
                                                    id: provider
                                                        .notificationmodelunread
                                                        ?.data?[index]
                                                        .datas
                                                        ?.id)
                                                .then((value) {
                                              if (value == true) {
                                                provider.fetchnotification();
                                                provider
                                                    .fetchunreadnotification();
                                                provider
                                                    .fetchreadnotification();
                                              }
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 12,
                                                      bottom: 8,
                                                      left: 6,
                                                      right: 6),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        child: Image.network(
                                                          provider
                                                                  .notificationmodelunread
                                                                  ?.data?[index]
                                                                  .datas
                                                                  ?.notification
                                                                  ?.avatar ??
                                                              "",
                                                          width: 48,
                                                          height: 48,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 12,
                                                      ),
                                                      Flexible(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .stretch,
                                                          children: [
                                                            Text(
                                                              provider
                                                                      .notificationmodelunread
                                                                      ?.data?[
                                                                          index]
                                                                      .datas
                                                                      ?.notification
                                                                      ?.message ??
                                                                  "",
                                                              style: TextStyle(
                                                                color:
                                                                    kPrimaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Text(
                                                              formatTimestamp(provider
                                                                      .notificationmodelunread
                                                                      ?.data?[
                                                                          index]
                                                                      .createdAt ??
                                                                  ""),
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color:
                                                                    kPrimaryColor,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      // dataSrc.read
                                                      //     ? SizedBox.shrink()
                                                      //     : Icon(
                                                      //         Icons.fiber_manual_record,
                                                      //         color: kSecondaryColor,
                                                      //         size: 16,
                                                      //       )
                                                    ],
                                                  ),
                                                ),
                                                Divider(
                                                  height: 4,
                                                  color: Colors.grey.shade200,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: provider
                                          .notificationmodelread?.data?.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            provider
                                                            .notificationmodelread
                                                            ?.data?[index]
                                                            .datas
                                                            ?.notification
                                                            ?.event ==
                                                        'CreatePlanRequest' ||
                                                    provider
                                                            .notificationmodelread
                                                            ?.data?[index]
                                                            .datas
                                                            ?.notification
                                                            ?.event ==
                                                        'UpdatePlanRequest'
                                                ? Navigator.of(context)
                                                    .pushAndRemoveUntil(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                BottomNav(
                                                                  initialIndex:
                                                                      2,
                                                                )), // 3 is the index for PricingPackagesScreen
                                                        (route) => false)
                                                : provider
                                                            .notificationmodelread
                                                            ?.data?[index]
                                                            .datas
                                                            ?.notification
                                                            ?.event ==
                                                        'BookingUpdatedEvent'
                                                    ? Navigator.of(context)
                                                        .push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                BookingHistoryScreen()), // 3 is the index for PricingPackagesScreen
                                                      )
                                                    : provider
                                                                .notificationmodelread
                                                                ?.data?[index]
                                                                .datas
                                                                ?.notification
                                                                ?.event ==
                                                            'VendorApproved'
                                                        ? Navigator.of(context)
                                                            .push(
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    BottomNav(
                                                                      initialIndex:
                                                                          3,
                                                                    )), // 3 is the index for PricingPackagesScreen
                                                          )
                                                        : (provider.notificationmodelread?.data?[index].datas?.notification?.event ==
                                                                    'UpdatedServiceEvent' &&
                                                                provider
                                                                        .notificationmodelread
                                                                        ?.data?[index]
                                                                        .datas
                                                                        ?.notification
                                                                        ?.type ==
                                                                    'hotel')
                                                            ? Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ManageHotelScreen()), // 3 is the index for PricingPackagesScreen
                                                              )
                                                            : (provider.notificationmodelread?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodelread?.data?[index].datas?.notification?.type == 'car')
                                                                ? Navigator.of(context).push(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ManageCarScreen()), // 3 is the index for PricingPackagesScreen
                                                                  )
                                                                : (provider.notificationmodelread?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodelread?.data?[index].datas?.notification?.type == 'boat')
                                                                    ? Navigator.of(context).push(
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ManageBoatScreen()), // 3 is the index for PricingPackagesScreen
                                                                      )
                                                                    : (provider.notificationmodelread?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodelread?.data?[index].datas?.notification?.type == 'flight')
                                                                        ? Navigator.of(context).push(
                                                                            MaterialPageRoute(builder: (context) => ManageAllFlightScreen()), // 3 is the index for PricingPackagesScreen
                                                                          )
                                                                        : (provider.notificationmodelread?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodelread?.data?[index].datas?.notification?.type == 'tour')
                                                                            ? Navigator.of(context).push(
                                                                                MaterialPageRoute(builder: (context) => ManageTourScreen()), // 3 is the index for PricingPackagesScreen
                                                                              )
                                                                            : (provider.notificationmodelread?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodelread?.data?[index].datas?.notification?.type == 'event')
                                                                                ? Navigator.of(context).push(
                                                                                    MaterialPageRoute(builder: (context) => AllEventScreen()), // 3 is the index for PricingPackagesScreen
                                                                                  )
                                                                                : (provider.notificationmodelread?.data?[index].datas?.notification?.event == 'UpdatedServiceEvent' && provider.notificationmodelread?.data?[index].datas?.notification?.type == 'space')
                                                                                    ? Navigator.of(context).push(
                                                                                        MaterialPageRoute(builder: (context) => AllSpaceScreen()), // 3 is the index for PricingPackagesScreen
                                                                                      )
                                                                                    : null;
                                            provider
                                                .notificationread(
                                                    id: provider
                                                        .notificationmodelread
                                                        ?.data?[index]
                                                        .datas
                                                        ?.id)
                                                .then((value) {
                                              if (value == true) {
                                                provider.fetchnotification();
                                                provider
                                                    .fetchunreadnotification();
                                                provider
                                                    .fetchreadnotification();
                                              }
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: 12,
                                                  bottom: 8,
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: Image.network(
                                                        provider
                                                                .notificationmodelread
                                                                ?.data?[index]
                                                                .datas
                                                                ?.notification
                                                                ?.avatar ??
                                                            "",
                                                        width: 48,
                                                        height: 48,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 12,
                                                    ),
                                                    Flexible(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          Text(
                                                            provider
                                                                    .notificationmodelread
                                                                    ?.data?[
                                                                        index]
                                                                    .datas
                                                                    ?.notification
                                                                    ?.message ??
                                                                "",
                                                            style: TextStyle(
                                                              color:
                                                                  kPrimaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            formatTimestamp(provider
                                                                    .notificationmodelread
                                                                    ?.data?[
                                                                        index]
                                                                    .createdAt ??
                                                                ""),
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color:
                                                                  kPrimaryColor,
                                                            ),
                                                            textAlign:
                                                                TextAlign.left,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    // dataSrc.read
                                                    //     ? SizedBox.shrink()
                                                    //     : Icon(
                                                    //         Icons.fiber_manual_record,
                                                    //         color: kSecondaryColor,
                                                    //         size: 16,
                                                    //       )
                                                  ],
                                                ),
                                              ),
                                              Divider(
                                                height: 4,
                                                color: Colors.grey.shade200,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ],
                      ),
                    ),
                  ),
                )));
  }

  Widget _buildSegment(String text) {
    bool isSelected = selectedFilter == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
