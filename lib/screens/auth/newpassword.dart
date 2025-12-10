import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/auth_provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key, this.email}) : super(key: key);
  final String? email;
  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Reset Password".tr,
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      ),
                ),
                SizedBox(height: 28),
                _buildPasswordField(
                  label: 'New Password'.tr,
                  controller: _newPasswordController,
                  hintText: 'New Password',
                ),
                SizedBox(height: 8),
                Text(
                  '*require at least one uppercase, one lowercase letter, one number and one symbol'
                      .tr,
                  style: GoogleFonts.spaceGrotesk(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(height: 20),
                _buildPasswordField(
                  label: 'Confirm Password'.tr,
                  controller: _confirmPasswordController,
                  hintText: 'Confirm Password'.tr,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: resetpassowod,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text('Reset Password'.tr,style: GoogleFonts.spaceGrotesk(),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  void resetpassowod() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.resetpassowrd(
          _newPasswordController.text,
          _confirmPasswordController.text,
          widget.email ?? "");

      log("$success success");

      setState(() {
        loading = false;
      });

      if (success) {
        // Password changed successfully
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              return BottomNav();
            },
          ),
          (route) => false,
        ); // Return to previous screen
      }
      // Error handling is done within the changePassword method
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
