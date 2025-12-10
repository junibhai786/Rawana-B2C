import 'package:flutter/material.dart';
import 'package:get/get.dart';

//section title

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.ktext,
  });

  final String ktext;

  @override
  Widget build(BuildContext context) {
    return Text(
      ktext,
      style:  TextStyle(
        fontSize: 20,
        fontFamily: 'Inter'.tr,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
