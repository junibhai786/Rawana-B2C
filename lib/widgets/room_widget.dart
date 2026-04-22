// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/room_model.dart';
import 'package:moonbnd/widgets/room_selection_bottomsheet.dart';

class RoomWidget extends StatefulWidget {
  final Room room;
  final Function(int roomId, int quantity) onQuantityChanged;

  final VoidCallback? onSelect;

  const RoomWidget({
    super.key,
    required this.room,
    required this.onQuantityChanged,
    this.onSelect,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RoomWidgetState createState() => _RoomWidgetState();
}

class _RoomWidgetState extends State<RoomWidget> {
  int numberOfRooms = 0;
  late double totalPrice;

  @override
  void initState() {
    super.initState();
    totalPrice = 0;
    numberOfRooms = widget.room.numberSelected;
    totalPrice = widget.room.price * numberOfRooms;
  }

  void updatePrice(int rooms) {
    setState(() {
      numberOfRooms = rooms;
      totalPrice = widget.room.price * rooms;
    });
    // Call the onQuantityChanged callback
    widget.onQuantityChanged(widget.room.id, rooms);
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room name & type
              Text(
                widget.room.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryColor,
                ),
              ),
              if (widget.room.bedsHtml.isNotEmpty)
                Text(
                  _stripHtml(widget.room.bedsHtml),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 12),

              // Details row (Icons)
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                   _buildStatItem(
                    Icons.person_outline,
                    "Max ${widget.room.maxAdults ?? _extractNumber(widget.room.adultsHtml)} Adults",
                  ),
                  _buildStatItem(
                    Icons.child_care_outlined,
                    "Max ${widget.room.maxChildren ?? _extractNumber(widget.room.childrenHtml)} Children",
                  ),
                  _buildStatItem(
                    Icons.square_foot_outlined,
                    "${_stripHtml(widget.room.sizeHtml)} sqm",
                  ),
                  if (widget.room.viewType != null && widget.room.viewType!.isNotEmpty)
                    _buildStatItem(
                      Icons.landscape_outlined,
                      widget.room.viewType!,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Amenities (Chips)
              if (widget.room.termFeatures.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: widget.room.termFeatures.take(4).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xffF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (feature.icon.isNotEmpty && !feature.icon.contains('<svg'))
                             Icon(Icons.check, size: 12, color: kPrimaryColor)
                          else
                            const Icon(Icons.check, size: 12, color: Colors.blueGrey),
                          const SizedBox(width: 4),
                          Text(
                            feature.title,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(height: 1, color: Color(0xffF1F5F9)),
              ),

              // Bottom Section: Price and Select
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        numberOfRooms > 0 ? "Available".tr : "Select dates".tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: kPrimaryColor,
                          ),
                          children: [
                            TextSpan(text: "USD ${widget.room.price.toInt()}"),
                            TextSpan(
                              text: " / night",
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                                    ElevatedButton(
                    onPressed: widget.onSelect ?? () {
                      showRoomSelectionBottomSheet(
                        context,
                        initialRooms: numberOfRooms,
                        roomPrice: widget.room.price,
                        numberOfNights: 1,
                        onSave: (rooms) {
                          updatePrice(rooms);
                        },
                        roomPrices: [widget.room.price],
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      widget.onSelect != null ? "Select" : (numberOfRooms > 0 ? "Selected ($numberOfRooms)" : "Select"),
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _extractNumber(String html) {
    final match = RegExp(r'\d+').firstMatch(_stripHtml(html));
    return match?.group(0) ?? "0";
  }
}
