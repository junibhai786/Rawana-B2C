// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';

//tor agreement

class TorAgreement extends StatelessWidget {
  const TorAgreement({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Text.rich(
        style: TextStyle(fontFamily: 'Inter'.tr, fontSize: 13),
        textAlign: TextAlign.center,
        TextSpan(
          children: [
            TextSpan(
                text:
                    'By creating account or signing in, you have read and agreed to '
                        .tr,
                style: TextStyle(fontFamily: 'Inter'.tr, color: kPrimaryColor)),
            TextSpan(
              text: 'Privacy Policy'.tr,
              style: TextStyle(
                fontFamily: 'Inter'.tr,
                color: kPrimaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: ' and '.tr,
            ),
            TextSpan(
              text: 'Term of Service',
              style: TextStyle(
                fontFamily: 'Inter'.tr,
                color: kPrimaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: '.',
            ),
          ],
        ),
      ),
    );
  }
}
