import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';

//secondary button

class TextIconButtom extends StatelessWidget {
  const TextIconButtom(
      {super.key,
      required this.text,
      required this.press,
      required this.icon,
      this.textcolor,
      this.backgroudcolour,
      this.buttonColor,
      this.borderColor,
      this.size});

  final String text;
  final Widget icon;
  final Color? textcolor;
  final Color? backgroudcolour;
  final Color? buttonColor;
  final Color? borderColor;

  final double? size;

  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton.icon(
          icon: icon,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: buttonColor ?? backgroudcolour ?? kSecondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: borderColor ?? Colors.transparent),
            ),
          ),
          onPressed: press,
          label: Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter'.tr,
              color: textcolor ?? Colors.white,
              fontSize: size ?? 14,
              fontWeight: FontWeight.w600,
            ),
          )),
    );
  }
}
