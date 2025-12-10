import 'package:flutter/material.dart';
import 'package:moonbnd/constants.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';

class EnquiryBottomSheet extends StatefulWidget {
  final String serviceId;
  final String serviceType;

  const EnquiryBottomSheet({
    Key? key,
    required this.serviceId,
    required this.serviceType,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String serviceId,
    required String serviceType,
    required Null Function(
            dynamic name, dynamic email, dynamic phone, dynamic note)
        onEnquirySubmit,
    required Null Function() onClose,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EnquiryBottomSheet(
        serviceId: serviceId,
        serviceType: serviceType,
      ),
    );
  }

  @override
  State<EnquiryBottomSheet> createState() => _EnquiryBottomSheetState();
}

class _EnquiryBottomSheetState extends State<EnquiryBottomSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitEnquiry() async {
    if (_formKey.currentState!.validate()) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final result = await homeProvider.sendEnquiry(
        serviceId: widget.serviceId,
        serviceType: widget.serviceType,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        note: _noteController.text,
      );

      if (result != null && result['status'] == 1) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(result['message'] ?? 'Enquiry submitted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result?['message'] ?? ''}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get keyboard height to adjust bottom padding
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enquiry'.tr,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Divider(thickness: 1),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name*'.tr,
                border: OutlineInputBorder(),
              ),
              style: TextStyle(height: 1),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email*'.tr,
                border: OutlineInputBorder(),
              ),
              style: TextStyle(height: 1),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email'.tr;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email address'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone*'.tr,
                border: OutlineInputBorder(),
              ),
              style: TextStyle(height: 1),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number'.tr;
                }
                if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
                  return 'Please enter a valid phone number'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Note*'.tr,
                border: OutlineInputBorder(),
              ),
              style: TextStyle(height: 1),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a note'.tr;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Divider(thickness: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel'.tr,
                      style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _submitEnquiry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Send Now'.tr,
                      style: TextStyle(
                        color: kBackgroundColor,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
