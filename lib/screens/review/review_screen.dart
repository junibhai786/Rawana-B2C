// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overall Rating',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
                    fontFamily: 'Inter'.tr),
              ),
              SizedBox(height: 16),
              _buildRatingBars(),
              SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '20 Reviews'.tr,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryColor,
                        fontFamily: 'Inter'.tr),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Text('Most Recent'.tr),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildReviewItem(),
              _buildReviewItem(),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Add a review'.tr,
                    style: TextStyle(fontFamily: 'Inter'.tr, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: kSecondaryColor,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Navigate to add review screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBars() {
    return Column(
      children: [
        _buildRatingBar(5, 0.8),
        _buildRatingBar(4, 0.6),
        _buildRatingBar(3, 0.5),
        _buildRatingBar(2, 0.2),
        _buildRatingBar(1, 0.2),
      ],
    );
  }

  Widget _buildRatingBar(int stars, double ratio) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SvgPicture.asset("assets/icons/staricon.svg"),
          SizedBox(width: 4),
          Text('$stars',
              style: TextStyle(fontFamily: 'Inter'.tr, fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    NetworkImage('https://example.com/profile.jpg'),
                radius: 20,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Millie Brown'.tr,
                      style: TextStyle(
                          fontFamily: 'Inter'.tr,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text('Jaipur, India'.tr,
                      style: TextStyle(
                          fontFamily: 'Inter'.tr, color: Colors.grey)),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(Icons.star, color: kPrimaryColor, size: 18),
                ),
              ),
              SizedBox(width: 8),
              Text('12 Jan 2024'.tr,
                  style: TextStyle(fontFamily: 'Inter'.tr, color: Colors.grey)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'It offers a luxurious and serene escape with its beautiful Greece-style architecture, spacious bedrooms, private pool, and exceptional service, all in a prime location close to the beach and top restaurants.',
            style: TextStyle(fontFamily: 'Inter'.tr, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
