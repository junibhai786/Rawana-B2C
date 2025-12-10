import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';

//secondary button

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.press,
  });

  final String text;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: const BorderSide(
          color: kPrimaryColor,
          width: 1,
        ),
        elevation: 0,
      ),
      onPressed: press,
      child: Text(
        text,
        style:  TextStyle(
          color: kPrimaryColor,
          fontSize: 14,
          fontFamily: 'Inter'.tr,
        ),
      ),
    );
  }
}
