// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:moonbnd/constants.dart';

class PersonType {
  final String name;
  final String desc;
  final int min;
  final int max;
  final double price;

  PersonType({
    required this.name,
    required this.desc,
    required this.min,
    required this.max,
    required this.price,
  });
}

void guestTourSheet(
  BuildContext context, {
  required List<PersonType> personTypes,
  required Function(Map<String, int> selectedGuests, double totalPrice) onSave,
}) {
  Map<String, int> guestCounts = {};
  // Initialize counts based on minimum values
  for (var type in personTypes) {
    guestCounts[type.name] = type.min;
  }

  double calculateTotalPrice() {
    double total = 0;
    for (var type in personTypes) {
      total += (guestCounts[type.name] ?? 0) * type.price;
    }
    return total;
  }

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
                      "Guests",
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
                ...personTypes.map((type) => Column(
                      children: [
                        _buildGuestTypeSelector(
                          type: type,
                          value: guestCounts[type.name] ?? 0,
                          onChanged: (value) {
                            setState(() {
                              guestCounts[type.name] = value;
                            });
                          },
                        ),
                        Divider(),
                      ],
                    )),
                SizedBox(height: 24),
                Divider(),
                _buildBottomBar(
                  context,
                  () {
                    setState(() {
                      for (var type in personTypes) {
                        guestCounts[type.name] = type.min;
                      }
                    });
                  },
                  () {
                    onSave(guestCounts, calculateTotalPrice());
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

Widget _buildGuestTypeSelector({
  required PersonType type,
  required int value,
  required Function(int) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type.name,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "\$${type.price.toStringAsFixed(2)}",
                style: TextStyle(
                  color: kSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          QuantitySelector(
            value: value,
            onChanged: (newValue) {
              if (newValue >= type.min && newValue <= type.max) {
                onChanged(newValue);
              }
            },
          ),
        ],
      ),
      Text(
        type.desc,
        style: TextStyle(fontSize: 12, color: grey),
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
            "Clear all",
            style: TextStyle(
              fontFamily: 'Inter',
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
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  SizedBox(width: 8),
                  Text(
                    "Save",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// Quantity Selector Widget
class QuantitySelector extends StatefulWidget {
  final int value;
  final Function(int) onChanged;

  const QuantitySelector({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            if (widget.value > 0) widget.onChanged(widget.value - 1);
          },
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              border: Border.all(color: kColor1),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            child: Icon(Icons.remove, size: 20, color: Colors.black),
          ),
        ),
        SizedBox(
          width: 42,
          child: Center(
            child: Text(
              '${widget.value}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            widget.onChanged(widget.value + 1);
          },
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              border: Border.all(color: kColor1),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            child: Icon(Icons.add, size: 20, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
