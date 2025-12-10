// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:moonbnd/constants.dart';

import 'package:moonbnd/widgets/tertiary_button.dart'; // For handling file paths
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';

class UpdateVerificationDataScreen extends StatefulWidget {
  const UpdateVerificationDataScreen({super.key});

  @override
  _UpdateVerificationDataScreenState createState() =>
      _UpdateVerificationDataScreenState();
}

class _UpdateVerificationDataScreenState
    extends State<UpdateVerificationDataScreen> {
  File? selectedIdCardFile;
  File? selectedLicenseFile;
  TextEditingController phoneController = TextEditingController();

  bool _isLoading = false;

  Future<void> _pickImageForIdCard() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, maxWidth: 2400);
    if (image != null) {
      setState(() {
        selectedIdCardFile = File(image.path);
      });
      await Provider.of<HomeProvider>(context, listen: false)
          .uploadVerificationImage(File(image.path), true);

      // Refresh the UI
      setState(() {});
    }
  }

  Future<void> _pickImageForLicense() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, maxWidth: 2400);
    if (image != null) {
      setState(() {
        selectedLicenseFile = File(image.path);
      });
      // Upload the image
      await Provider.of<HomeProvider>(context, listen: false)
          .uploadVerificationImage(File(image.path), false);

      // Refresh the UI
      setState(() {});
    }
  }

  void _deleteIdCardImage() {
    setState(() {
      selectedIdCardFile = null;
    });
  }

  void _deleteLicenseImage() {
    setState(() {
      selectedLicenseFile = null;
    });
  }

  void _saveVerificationData() async {
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<HomeProvider>(context, listen: false);

    log("${phoneController.text} checking");
    log("${provider.verifyIdCard?.name} checking");
    log("${provider.verifyTradeLicense?.name} checking");
    // Validate inputs
    if (phoneController.text.isEmpty ||
        provider.verifyIdCard == null ||
        provider.verifyTradeLicense == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide all required information'.tr)),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Prepare the data
    final idCard = provider.verifyIdCard!;
    final tradeLicense = provider.verifyTradeLicense!;

    // Call the submitVerification API
    bool check = await provider.submitVerification(
      phoneNumber: phoneController.text,
      idCard: idCard,
      tradeLicenses: [tradeLicense],
    );

    if (check) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification data submitted successfully'.tr)),
      );
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }

    // Navigate back or to a success screen

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // title: Text('Update Verification Data',
        //     style: TextStyle(color: Colors.black,fontFamily: 'Inter'.tr,)),
        // backgroundColor: Colors.white,
        // elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Update Verification Data'.tr,
                      style: TextStyle(
                          fontFamily: 'Inter'.tr,
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w600)),
                  // SizedBox(height: 0),
                  SizedBox(height: 40),

                  _buildInputField('Phone'.tr),
                  SizedBox(height: 16),
                  _buildFileSelectionField('ID Card'.tr, selectedIdCardFile,
                      _pickImageForIdCard, _deleteIdCardImage),
                  SizedBox(height: 16),
                  _buildFileSelectionField(
                      'Trade License'.tr,
                      selectedLicenseFile,
                      _pickImageForLicense,
                      _deleteLicenseImage),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: kSecondaryColor)
                        : TertiaryButton(
                            text: "Save".tr,
                            press: _saveVerificationData,
                          ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildInputField(String label) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kColor1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: phoneController,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Inter'.tr,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildFileSelectionField(String label, File? selectedFile,
      VoidCallback onPickImage, VoidCallback onDeleteImage) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: kColor1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(label,
                style: TextStyle(
                    fontFamily: 'Inter'.tr,
                    fontSize: 16,
                    color: kPrimaryColor)),
          ),
          Row(
            children: [
              if (selectedFile != null)
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.file(
                        selectedFile,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: onDeleteImage, // Delete image when clicked
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ), // Display selected image preview with delete option if present
              Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: kSecondaryColor,
                    borderRadius:
                        BorderRadius.circular(8), // Apply border radius
                  ),
                  child: TextButton.icon(
                    icon: SvgPicture.asset(
                      'assets/icons/upload_icon.svg',
                    ),
                    label: Text('Select File',
                        style: TextStyle(
                            fontFamily: 'Inter'.tr, color: Colors.white)),
                    onPressed:
                        onPickImage, // Trigger respective image selection
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
