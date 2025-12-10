import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonbnd/constants.dart';

class MyPlansScreen extends StatelessWidget {
  const MyPlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Plans'.tr),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Current Plan'.tr,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildPlanCard(
                    planName: 'Basic'.tr,
                    expiry: '10/02/2024, 07:50'.tr,
                    total: '1 / 5'.tr,
                    price: '\$199'.tr,
                    status: 'Active',
                  ),
                  _buildPlanCard(
                    planName: 'Standard'.tr,
                    expiry: '10/02/2024, 07:50'.tr,
                    total: '1 / 20'.tr,
                    price: '\$499'.tr,
                    status: 'Active'.tr,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String planName,
    required String expiry,
    required String total,
    required String price,
    required String status,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(planName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Expiry: $expiry'.tr),
            SizedBox(height: 8),
            Text('Total: $total'.tr),
            SizedBox(height: 8),
            Text('Price: $price'.tr),
            SizedBox(height: 8),
            Text('Status: $status'.tr, style: TextStyle(color: kSecondaryColor)),
          ],
        ),
      ),
    );
  }
}
