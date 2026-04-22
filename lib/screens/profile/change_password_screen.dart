import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/data_models/all_space_item_screen.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Visibility toggles for password fields
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Update Password'.tr,style: GoogleFonts.spaceGrotesk(color: Colors.black,fontWeight: FontWeight.w500)),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPasswordField(
                        label: 'Current Password'.tr,
                        controller: _currentPasswordController,
                        hintText: 'Current Password'.tr,
                        isPasswordVisible: _isCurrentPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isCurrentPasswordVisible =
                                !_isCurrentPasswordVisible;
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      _buildPasswordField(
                        label: 'New Password'.tr,
                        controller: _newPasswordController,
                        hintText: 'New Password'.tr,
                        isPasswordVisible: _isNewPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                      ),
                      SizedBox(height: 8),
                      Text(
                        '*require at least one uppercase, one lowercase letter, one number and one symbol'
                            .tr,
                        style:  GoogleFonts.spaceGrotesk(color: Colors.black,fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: 16),
                      _buildPasswordField(
                        label: 'Confirm Password'.tr,
                        controller: _confirmPasswordController,
                        hintText: 'Confirm Password'.tr,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cancel'.tr,style: GoogleFonts.spaceGrotesk(color: Colors.black,fontWeight: FontWeight.w500)),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _updatePassword,
                              child: Text('Update'.tr,style: GoogleFonts.spaceGrotesk(color: Colors.white,fontWeight: FontWeight.w500)),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        ],
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
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(color: Colors.black,fontWeight: FontWeight.w700)
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: onVisibilityToggle,
            ),
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

  void _updatePassword() async {
    if (_confirmPasswordController.text != _newPasswordController.text) {
      // Replace with your error handling method
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Confirm and New Password must match.".tr)),
      );
    } else {
      if (_formKey.currentState!.validate()) {
        setState(() {
          loading = true;
        });
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        bool success = await authProvider.changePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
        );

        log("$success success");

        setState(() {
          loading = false;
        });

        if (success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SignInScreen()),
          );
        }
      }
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
