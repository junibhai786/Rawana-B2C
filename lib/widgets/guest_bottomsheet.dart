// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:moonbnd/constants.dart';
import 'package:get/get.dart';

void showGuestBottomSheet(BuildContext context,
    {required int initialAdults,
    required int initialChildren,
    required Function(int adults, int children) onSave}) {
  int adults = initialAdults;
  int children = initialChildren;

  showModalBottomSheet(
    backgroundColor: Colors.white, // Background color changed to white
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
                      "Guests".tr,
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
                _buildAdultsSelector(
                  adults,
                  (value) => setState(() => adults = value),
                ),
                Divider(),
                SizedBox(height: 10),
                _buildChildrenSelector(
                  children,
                  (value) => setState(() => children = value),
                ),
                SizedBox(height: 24),
                Divider(),
                _buildBottomBar(
                  context,
                  () {
                    setState(() {
                      adults = 0;
                      children = 0;
                    });
                  },
                  () {
                    onSave(adults, children);
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

Widget _buildAdultsSelector(int value, Function(int) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align vertically in center
        children: [
          Text(
            "Adults".tr,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          QuantitySelector(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
      Text(
        "Ages 13 or above".tr, // Added ages description under Adults
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    ],
  );
}

Widget _buildChildrenSelector(int value, Function(int) onChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Children".tr,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          QuantitySelector(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
      Text(
        "Ages 2-12".tr,
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
            "Clear all".tr,
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
                    "Save".tr,
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
