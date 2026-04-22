// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/constants.dart';
import 'package:get/get.dart';

void showGuestBottomSheet(BuildContext context,
    {required int initialAdults,
    required int initialChildren,
    required List<int> initialChildrenAges,
    required Function(int adults, int children, List<int> childrenAges)
        onSave}) {
  int adults = initialAdults;
  int children = initialChildren;
  List<int> childrenAges = List<int>.from(initialChildrenAges);

  // Sync childrenAges with children count
  if (childrenAges.length < children) {
    while (childrenAges.length < children) {
      childrenAges.add(8);
    }
  } else if (childrenAges.length > children) {
    childrenAges = childrenAges.sublist(0, children);
  }

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
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: SingleChildScrollView(
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
                    (value) {
                      setState(() {
                        children = value;
                        // Sync childrenAges list with children count
                        if (childrenAges.length < children) {
                          while (childrenAges.length < children) {
                            childrenAges.add(8);
                          }
                        } else if (childrenAges.length > children) {
                          childrenAges = childrenAges.sublist(0, children);
                        }
                      });
                    },
                  ),
                  // Dynamic child age rows
                  if (children > 0) ...[
                    Divider(),
                    ..._buildChildAgeRows(childrenAges, setState),
                  ],
                  SizedBox(height: 24),
                  Divider(),
                  _buildBottomBar(
                    context,
                    () {
                      setState(() {
                        adults = 1;
                        children = 0;
                        childrenAges.clear();
                      });
                    },
                    () {
                      onSave(adults, children, childrenAges);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Build child age rows
List<Widget> _buildChildAgeRows(List<int> childrenAges, StateSetter setState) {
  return List.generate(
    childrenAges.length,
    (index) {
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Child ${index + 1} Age'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: const Color(0xff1D2025),
                      ),
                    ),
                    Text(
                      'Years'.tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: const Color(0xff6B7280),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Minus button
                    InkWell(
                      onTap: childrenAges[index] > 0
                          ? () {
                              setState(() {
                                childrenAges[index]--;
                              });
                            }
                          : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: childrenAges[index] > 0
                                ? AppColors.primary
                                : const Color(0xffE5E7EB),
                          ),
                        ),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: childrenAges[index] > 0
                              ? AppColors.primary
                              : const Color(0xffD1D5DB),
                        ),
                      ),
                    ),
                    // Age value
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${childrenAges[index]}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xff1D2025),
                        ),
                      ),
                    ),
                    // Plus button
                    InkWell(
                      onTap: () {
                        setState(() {
                          childrenAges[index]++;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (index < childrenAges.length - 1) Divider(),
        ],
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
