import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../constants.dart';

//build social button
class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key,
    required this.icon,
    required this.press,
    required this.text,
  });

  final String icon, text;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        elevation: 0.0,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: kColor1,
            width: 0.8,
          ),
        ),
      ),
      onPressed: press,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            height: 20,
          ),
          const SizedBox(
            width: 14, 
          ),
          Text(
            text,
            style:  TextStyle(
              color: kPrimaryColor,
              fontSize: 14,
              fontFamily: 'Inter'.tr,
            ),
          ),
        ],
      ),
    );
  }
}
