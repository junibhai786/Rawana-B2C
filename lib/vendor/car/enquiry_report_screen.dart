import 'package:moonbnd/constants.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';

class EnquiryReportScreen extends StatelessWidget {
  const EnquiryReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enquiry Report'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildEnquiryCard(
              companyName: 'Toyota Company',
              orderDate: '09/03/2024',
              customerName: 'User',
              email: 'user@gmail.com',
              phone: '1234567890',
              notes: 'User',
              status: 'Pending',
              replies: 0,
              createdAt: '10/02/2024, 07:50',
              context: context,
            ),
            _buildEnquiryCard(
              companyName: 'Toyota Company',
              orderDate: '09/03/2024',
              customerName: 'User',
              email: 'user@gmail.com',
              phone: '1234567890',
              notes: 'User',
              status: 'Pending',
              replies: 0,
              createdAt: '10/02/2024, 07:50',
              context: context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnquiryCard({
    required String companyName,
    required String orderDate,
    required String customerName,
    required String email,
    required String phone,
    required String notes,
    required String status,
    required int replies,
    required String createdAt,
    required BuildContext context,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(companyName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Order Date: $orderDate'),
            SizedBox(height: 8),
            Text('Customer Info',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Name: $customerName'),
            Text('Email: $email'),
            Text('Phone: $phone'),
            Text('Notes: $notes'),
            SizedBox(height: 8),
            Text('Status: $status', style: TextStyle(color: kSecondaryColor)),
            SizedBox(height: 8),
            Text('Replies: $replies'),
            Text('Created At: $createdAt'),
            SizedBox(height: 16),
            TertiaryButton(
              press: () {
                _showActionsModal(context);
              },
              text: 'Actions',
            ),
          ],
        ),
      ),
    );
  }

  void _showActionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              ListTile(
                title: Text('Add Reply'),
                onTap: () {
                  // Handle Add Reply action
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Mark as: Pending'),
                onTap: () {
                  // Handle Mark as Pending action
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Mark as: Completed'),
                onTap: () {
                  // Handle Mark as Completed action
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Mark as: Cancel'),
                onTap: () {
                  // Handle Mark as Cancel action
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
