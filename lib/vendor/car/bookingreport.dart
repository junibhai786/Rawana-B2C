import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:get/get.dart';

class BookingreprotScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Booking History',
                  style:
                      TextStyle(color: Colors.black), // Set text color to black
                ),
              ),
              Tab(
                child: Text(
                  'Booking Report',
                  style:
                      TextStyle(color: Colors.black), // Set text color to black
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BookingHistory(),
            BookingReport(),
          ],
        ),
      ),
    );
  }
}

class BookingHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        BookingCard(),
        BookingCard(),
      ],
    );
  }
}

class BookingReport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        BookingCard(),
        BookingCard(),
      ],
    );
  }
}

class BookingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mercedes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Order Date: 09/03/2024'),
            const Text('Execution Time:'),
            const Text('Start Date: 10/03/2024'),
            const Text('End Date: 11/03/2024'),
            const Text('Duration: 1 day'),
            const SizedBox(height: 8),
            const Text('Payment Detail',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('Total: \$50'),
            const Text('Paid: \$0'),
            const Text('Remain: \$50'),
            const SizedBox(height: 8),
            const Text('Commission: \$39'),
            const Text('Status: Processing',
                style: TextStyle(color: AppColors.accent)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: TertiaryButton(press: () {}, text: 'Details'.tr)),
                Spacer(),
                Expanded(
                    child: TertiaryButton(press: () {}, text: 'Invoice'.tr)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
