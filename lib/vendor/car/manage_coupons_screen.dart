import 'package:moonbnd/constants.dart';
import 'package:moonbnd/vendor/car/add_coupon_screen.dart';
import 'package:moonbnd/widgets/elevatedbuttonicon.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:get/get.dart';

class ManageCouponsScreen extends StatelessWidget {
  const ManageCouponsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Coupon'.tr),
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
              'Manage Coupons',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Showing 2 of 2 Coupons'),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildCouponCard(
                    code: 'SS123',
                    description: 'Test Coupon2',
                    amount: '\$1200',
                    status: 'Publish',
                    endDate: '10/02/2024, 07:50',
                  ),
                  _buildCouponCard(
                    code: 'SS111',
                    description: 'Test Coupon',
                    amount: '\$1200',
                    status: 'Publish',
                    endDate: '10/02/2024, 07:50',
                  ),
                ],
              ),
            ),
            TextIconButtom(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCouponScreen()),
                );
              },
              text: 'Add Coupon'.tr,
              borderColor: Colors.black,
              backgroudcolour: Colors.white,
              textcolor: Colors.black,
              icon: Icon(
                Icons.add,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard({
    required String code,
    required String description,
    required String amount,
    required String status,
    required String endDate,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(code,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(description),
            SizedBox(height: 8),
            Text('Amount: $amount'),
            SizedBox(height: 8),
            Text('Status: $status', style: TextStyle(color: kSecondaryColor)),
            SizedBox(height: 8),
            Text('End Date: $endDate'),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 50,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      // Edit coupon action
                    },
                    child: Text('Edit'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  color: Colors.red,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.white),
                    onPressed: () {
                      // Delete coupon action
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
