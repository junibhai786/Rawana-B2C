// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 4;

  String getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Very Bad!';
      case 2:
        return 'Bad!';
      case 3:
        return 'Okay!';
      case 4:
        return 'Good!';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }

  Widget buildStar(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _rating = index;
        });
      },
      child: Icon(
        Icons.star,
        color: index <= _rating ? kSecondaryColor : Colors.grey,
        size: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        title: Text(
          "Review".tr,
          style: TextStyle(
              color: kPrimaryColor,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter'.tr),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How was your stay at".tr,
              style: TextStyle(
                  fontSize: 24,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter'.tr),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "Dylan Hotel",
              style: TextStyle(
                  fontSize: 28,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter'.tr),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: kColor1),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/150'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Rate your stay at Dylan Hotel",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) => buildStar(index + 1)),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                getRatingText(_rating),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Spacer(),
            Divider(
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
            const SizedBox(height: 10),
            TertiaryButton(
              text: "Submit Review".tr,
              press: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BottomNav(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
