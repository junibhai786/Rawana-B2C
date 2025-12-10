import 'package:flutter/material.dart';
import 'package:moonbnd/constants.dart';
import 'package:get/get.dart';

void showRoomSelectionBottomSheet(
  BuildContext context, {
  required int initialRooms,
  required List<double> roomPrices,
  required int numberOfNights,
  required Function(int rooms) onSave,
  required double roomPrice,
}) {
  int rooms = initialRooms;

  showModalBottomSheet(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Number of Rooms".tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 10),
                _buildRoomSelector(
                  rooms,
                  (value) => setState(() => rooms = value),
                  roomPrices,
                  numberOfNights,
                ),
                SizedBox(height: 24),
                Divider(),
                _buildBottomBar(
                  context,
                  () {
                    setState(() {
                      rooms = 0;
                    });
                  },
                  () {
                    onSave(rooms);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildRoomSelector(int value, Function(int) onChanged,
    List<double> roomPrices, int numberOfNights) {
  double totalPrice =
      roomPrices.take(value).fold(0, (sum, price) => sum + price);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Rooms".tr,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          QuantitySelector(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
      SizedBox(height: 8),
      Text(
        "\$${(totalPrice * numberOfNights).toStringAsFixed(2)}/$numberOfNights nights"
            .tr,
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
    ],
  );
}

Widget _buildBottomBar(
    BuildContext context, VoidCallback onClear, VoidCallback onSave) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onClear,
          child: Text(
            "Clear".tr,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kSecondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onSave,
            child: Text(
              "Save".tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class QuantitySelector extends StatelessWidget {
  final int value;
  final Function(int) onChanged;

  const QuantitySelector({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int maxRooms = 10;

    return Row(
      children: [
        InkWell(
          onTap: () {
            if (value > 0) onChanged(value - 1);
          },
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              border: Border.all(color: kColor1),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            child: Icon(Icons.remove,
                size: 20, color: value > 0 ? Colors.black : Colors.grey),
          ),
        ),
        SizedBox(
          width: 42,
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (value < maxRooms) onChanged(value + 1);
          },
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              border: Border.all(color: kColor1),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            child: Icon(Icons.add,
                size: 20, color: value < maxRooms ? Colors.black : Colors.grey),
          ),
        ),
      ],
    );
  }
}
