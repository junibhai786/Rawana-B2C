import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: bottomInset + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enquiry'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Name
              _buildInputField(
                controller: _nameController,
                label: 'Name*'.tr,
                validator: (value) =>
                value == null || value.isEmpty
                    ? 'Please enter your name'.tr
                    : null,
              ),

              const SizedBox(height: 16),

              // Email
              _buildInputField(
                controller: _emailController,
                label: 'Email*'.tr,
                keyboardType: TextInputType.emailAddress,
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

              // Phone
              _buildInputField(
                controller: _phoneController,
                label: 'Phone*'.tr,
                keyboardType: TextInputType.phone,
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

              // Note
              _buildInputField(
                controller: _noteController,
                label: 'Note*'.tr,
                maxLines: 3,
                validator: (value) =>
                value == null || value.isEmpty
                    ? 'Please enter a note'.tr
                    : null,
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          color: kPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
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
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Send Now'.tr,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
      ),
    );
  }

}
Widget _buildInputField({
  required TextEditingController controller,
  required String label,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    maxLines: maxLines,
    keyboardType: keyboardType,
    validator: validator,
    style: GoogleFonts.spaceGrotesk(
      fontSize: 14,
      color: Colors.black,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        color: Colors.grey[600],
      ),

      // ✅ Grey background
      filled: true,
      fillColor: const Color(0xFFF1F5F9), // light grey

      // ❌ Remove all borders
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,

      // Padding for better height & touch
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
  );
}

