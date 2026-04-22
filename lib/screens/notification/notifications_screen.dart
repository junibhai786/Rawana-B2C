// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:google_fonts/google_fonts.dart';
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
import 'package:moonbnd/app_colors.dart';
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
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: provider.notificationmodel?.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              final item = provider.notificationmodel?.data?[index];
                              final notification = item?.datas?.notification;
                              final isUnread = item?.readAt == null;

                              return InkWell(
                                onTap: () {
                                  provider.notificationmodel?.data?[index].datas?.notification?.event ==
                                      'CreatePlanRequest' ||
                                      provider.notificationmodel?.data?[index].datas?.notification
                                          ?.event ==
                                          'UpdatePlanRequest'
                                      ? Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => BottomNav(initialIndex: 2),
                                    ),
                                        (route) => false,
                                  )
                                      : provider.notificationmodel?.data?[index].datas?.notification
                                      ?.event ==
                                      'BookingUpdatedEvent'
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => BookingHistoryScreen()),
                                  )
                                      : provider.notificationmodel?.data?[index].datas?.notification
                                      ?.event ==
                                      'VendorApproved'
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          BottomNav(initialIndex: 2),
                                    ),
                                  )
                                      : (provider.notificationmodel?.data?[index].datas
                                      ?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodel?.data?[index].datas
                                          ?.notification?.type ==
                                          'hotel')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ManageHotelScreen()),
                                  )
                                      : (provider.notificationmodel?.data?[index].datas
                                      ?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodel?.data?[index].datas
                                          ?.notification?.type ==
                                          'car')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ManageCarScreen()),
                                  )
                                      : (provider.notificationmodel?.data?[index].datas
                                      ?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodel?.data?[index]
                                          .datas?.notification?.type ==
                                          'boat')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ManageBoatScreen()),
                                  )
                                      : (provider.notificationmodel?.data?[index]
                                      .datas?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodel?.data?[index]
                                          .datas?.notification?.type ==
                                          'flight')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ManageAllFlightScreen()),
                                  )
                                      : (provider.notificationmodel?.data?[index]
                                      .datas?.notification
                                      ?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodel
                                          ?.data?[index]
                                          .datas
                                          ?.notification
                                          ?.type ==
                                          'tour')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ManageTourScreen()),
                                  )
                                      : (provider.notificationmodel
                                      ?.data?[index]
                                      .datas
                                      ?.notification
                                      ?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodel
                                          ?.data?[index]
                                          .datas
                                          ?.notification
                                          ?.type ==
                                          'event')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AllEventScreen()),
                                  )
                                      : (provider.notificationmodel
                                      ?.data?[index]
                                      .datas
                                      ?.notification
                                      ?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodel
                                          ?.data?[index]
                                          .datas
                                          ?.notification
                                          ?.type ==
                                          'space')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AllSpaceScreen()),
                                  )
                                      : null;

                                  provider
                                      .notificationread(
                                      id: provider.notificationmodel?.data?[index].datas?.id)
                                      .then((value) {
                                    if (value == true) {
                                      provider.fetchnotification();
                                      provider.fetchunreadnotification();
                                      provider.fetchreadnotification();
                                    }
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUnread ? const Color(0xFFF5F9FF) : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isUnread
                                          ? kSecondaryColor.withOpacity(0.25)
                                          : Colors.grey.shade200,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Avatar
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: notification?.avatar?.isNotEmpty == true
                                            ? Image.network(
                                          notification!.avatar!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _avatarPlaceholder(),
                                        )
                                            : _avatarPlaceholder(),
                                      ),

                                      const SizedBox(width: 12),

                                      // Text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification?.message ?? "",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 14.5,
                                                fontWeight:
                                                isUnread ? FontWeight.w600 : FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              formatTimestamp(item?.createdAt ?? ""),
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 11,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Unread indicator
                                      if (isUnread)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8, top: 6),
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: kSecondaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )

                        : selectedFilter == "Unread".tr
                                  ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: provider.notificationmodelunread?.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              final item = provider.notificationmodelunread?.data?[index];
                              final notification = item?.datas?.notification;
                              final isUnread = true; // All items here are unread

                              return InkWell(
                                onTap: () {
                                  // === FULL ON TAP LOGIC PRESERVED ===
                                  provider.notificationmodelunread?.data?[index].datas?.notification?.event ==
                                      'CreatePlanRequest' ||
                                      provider.notificationmodelunread?.data?[index].datas?.notification
                                          ?.event ==
                                          'UpdatePlanRequest'
                                      ? Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => BottomNav(initialIndex: 2),
                                    ),
                                        (route) => false,
                                  )
                                      : provider.notificationmodelunread?.data?[index].datas?.notification
                                      ?.event ==
                                      'BookingUpdatedEvent'
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => BookingHistoryScreen()),
                                  )
                                      : provider.notificationmodelunread?.data?[index].datas?.notification
                                      ?.event ==
                                      'VendorApproved'
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BottomNav(initialIndex: 2),
                                    ),
                                  )
                                      : (provider.notificationmodelunread?.data?[index].datas
                                      ?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelunread?.data?[index].datas
                                          ?.notification?.type ==
                                          'hotel')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ManageHotelScreen()),
                                  )
                                      : (provider.notificationmodelunread?.data?[index].datas
                                      ?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelunread?.data?[index].datas
                                          ?.notification?.type ==
                                          'car')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ManageCarScreen()),
                                  )
                                      : (provider.notificationmodelunread?.data?[index].datas
                                      ?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelunread?.data?[index]
                                          .datas?.notification?.type ==
                                          'boat')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ManageBoatScreen()),
                                  )
                                      : (provider.notificationmodelunread?.data?[index].datas
                                      ?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelunread?.data?[index]
                                          .datas?.notification?.type ==
                                          'flight')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ManageAllFlightScreen()),
                                  )
                                      : (provider.notificationmodelunread?.data?[index]
                                      .datas?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelunread?.data?[index]
                                          .datas?.notification?.type ==
                                          'tour')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ManageTourScreen()),
                                  )
                                      : (provider.notificationmodelunread
                                      ?.data?[index]
                                      .datas
                                      ?.notification
                                      ?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelunread
                                          ?.data?[index]
                                          .datas
                                          ?.notification
                                          ?.type ==
                                          'event')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AllEventScreen()),
                                  )
                                      : (provider.notificationmodelunread
                                      ?.data?[index]
                                      .datas
                                      ?.notification
                                      ?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelread
                                          ?.data?[index]
                                          .datas
                                          ?.notification
                                          ?.type ==
                                          'space')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AllSpaceScreen()),
                                  )
                                      : null;

                                  // Mark as read
                                  provider.notificationread(id: item?.datas?.id).then((value) {
                                    if (value == true) {
                                      provider.fetchnotification();
                                      provider.fetchunreadnotification();
                                      provider.fetchreadnotification();
                                    }
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F9FF),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: kSecondaryColor.withOpacity(0.25),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Avatar
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: notification?.avatar?.isNotEmpty == true
                                            ? Image.network(
                                          notification!.avatar!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                                        )
                                            : _avatarPlaceholder(),
                                      ),
                                      const SizedBox(width: 12),

                                      // Text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification?.message ?? "",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              formatTimestamp(item?.createdAt ?? ""),
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 11,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Unread dot
                                      Container(
                                        margin: const EdgeInsets.only(left: 8, top: 6),
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: kSecondaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )

                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: provider.notificationmodelread?.data?.length ?? 0,
                            itemBuilder: (context, index) {
                              final item = provider.notificationmodelread?.data?[index];
                              final notification = item?.datas?.notification;

                              return InkWell(
                                onTap: () {
                                  // === FULL ON TAP LOGIC PRESERVED ===
                                  provider.notificationmodelread?.data?[index].datas?.notification?.event ==
                                      'CreatePlanRequest' ||
                                      provider.notificationmodelread?.data?[index].datas?.notification
                                          ?.event ==
                                          'UpdatePlanRequest'
                                      ? Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => BottomNav(initialIndex: 2),
                                    ),
                                        (route) => false,
                                  )
                                      : provider.notificationmodelread?.data?[index].datas?.notification
                                      ?.event ==
                                      'BookingUpdatedEvent'
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => BookingHistoryScreen()),
                                  )
                                      : provider.notificationmodelread?.data?[index].datas?.notification
                                      ?.event ==
                                      'VendorApproved'
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => BottomNav(initialIndex: 3),
                                    ),
                                  )
                                      : (provider.notificationmodelread?.data?[index].datas
                                      ?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelread?.data?[index].datas
                                          ?.notification?.type ==
                                          'hotel')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ManageHotelScreen()),
                                  )
                                      : (provider.notificationmodelread?.data?[index].datas
                                      ?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelread?.data?[index].datas
                                          ?.notification?.type ==
                                          'car')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ManageCarScreen()),
                                  )
                                      : (provider.notificationmodelread?.data?[index].datas
                                      ?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelread?.data?[index]
                                          .datas?.notification?.type ==
                                          'boat')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ManageBoatScreen()),
                                  )
                                      : (provider.notificationmodelread?.data?[index].datas
                                      ?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelread?.data?[index]
                                          .datas?.notification?.type ==
                                          'flight')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ManageAllFlightScreen()),
                                  )
                                      : (provider.notificationmodelread?.data?[index].datas
                                      ?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelread?.data?[index]
                                          .datas?.notification?.type ==
                                          'tour')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ManageTourScreen()),
                                  )
                                      : (provider.notificationmodelread?.data?[index]
                                      .datas?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelread?.data?[index]
                                          .datas?.notification?.type ==
                                          'event')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AllEventScreen()),
                                  )
                                      : (provider.notificationmodelread?.data?[index]
                                      .datas?.notification?.event ==
                                      'UpdatedServiceEvent' &&
                                      provider.notificationmodelread?.data?[index]
                                          .datas?.notification?.type ==
                                          'space')
                                      ? Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AllSpaceScreen()),
                                  )
                                      : null;

                                  // Mark as read (optional, already read here)
                                  provider.notificationread(id: item?.datas?.id).then((value) {
                                    if (value == true) {
                                      provider.fetchnotification();
                                      provider.fetchunreadnotification();
                                      provider.fetchreadnotification();
                                    }
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.03),
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Avatar
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: notification?.avatar?.isNotEmpty == true
                                            ? Image.network(
                                          notification!.avatar!,
                                          width: 48,
                                          height: 48,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => _avatarPlaceholder(),
                                        )
                                            : _avatarPlaceholder(),
                                      ),
                                      const SizedBox(width: 12),

                                      // Text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification?.message ?? "",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              formatTimestamp(item?.createdAt ?? ""),
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 11,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Optional: read indicator (faded)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8, top: 6),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade400,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )

                        ],
                      ),
                    ),
                  ),
                )));
  }
  Widget _avatarPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.person, color: Colors.white),
    );
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
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
