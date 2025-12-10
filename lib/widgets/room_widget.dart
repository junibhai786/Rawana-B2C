// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/modals/room_model.dart';
import 'package:moonbnd/widgets/room_selection_bottomsheet.dart';

class RoomWidget extends StatefulWidget {
  final Room room;
  final Function(int roomId, int quantity) onQuantityChanged;

  const RoomWidget({
    super.key,
    required this.room,
    required this.onQuantityChanged,
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
  }

  void updatePrice(int rooms) {
    setState(() {
      numberOfRooms = rooms;
      totalPrice = widget.room.price * rooms;
    });
    // Call the onQuantityChanged callback
    widget.onQuantityChanged(widget.room.id, rooms);
    // Add to cart API call
    addToCart(widget.room.id, rooms);
  }

  Future<void> addToCart(int roomId, int quantity) async {
    // TODO: Implement the API call to add the room to the cart
    // This is a placeholder for the actual API call
    try {
      // Simulating an API call
      await Future.delayed(Duration(seconds: 1));
      print('Room $roomId added to cart with quantity $quantity');
      // You may want to show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Room added to book successfully')),
      );
    } catch (e) {
      // Handle any errors that occur during the API call
      print('Error adding room to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add room to cart')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: grey),
          boxShadow: [
            BoxShadow(
              color: grey,
              spreadRadius: 2,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Image.network(
                widget.room.image,
                height: 228,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                widget.room.title,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Inter'.tr,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
              child: Text(
                '${widget.room.sizeHtml.replaceAll(RegExp(r'<[^>]*>'), '')} sqm • ${widget.room.bedsHtml.replaceAll(RegExp(r'<[^>]*>'), '')} beds • ${widget.room.adultsHtml.replaceAll(RegExp(r'<[^>]*>'), '')} adults • ${widget.room.childrenHtml.replaceAll(RegExp(r'<[^>]*>'), '')} children',
                style: TextStyle(
                    fontFamily: 'Inter'.tr, fontSize: 14, color: grey),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
              child: Row(
                children: [
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Inter'.tr,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryColor,
                    ),
                  ),
                  Text(
                    ' for $numberOfRooms ${numberOfRooms == 1 ? 'room' : 'rooms'}',
                    style: TextStyle(
                      fontFamily: 'Inter'.tr,
                      fontSize: 14,
                      color: grey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: GestureDetector(
                onTap: () {
                  showRoomSelectionBottomSheet(
                    context,
                    initialRooms: numberOfRooms,
                    roomPrice: widget.room.price,
                    numberOfNights:
                        1, // You may want to pass this as a parameter
                    onSave: (rooms) {
                      updatePrice(rooms);
                    },
                    roomPrices: [widget.room.price],
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: grey),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$numberOfRooms ${numberOfRooms == 1 ? 'room' : 'rooms'}',
                        style: TextStyle(
                          fontFamily: 'Inter'.tr,
                          fontSize: 14,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
