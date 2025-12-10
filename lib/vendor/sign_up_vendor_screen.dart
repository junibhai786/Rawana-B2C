import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/auth/otp_screen.dart';
import 'package:moonbnd/widgets/checkbox.dart';
import 'package:moonbnd/widgets/country_code.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/api_interface.dart';
import 'package:country_picker/country_picker.dart';

class SignupVendorScreen extends StatefulWidget {
  SignupVendorScreen({super.key});

  @override
  State<SignupVendorScreen> createState() => _SignupVendorScreenState();
}

class _SignupVendorScreenState extends State<SignupVendorScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Country selectedCountry = Country.from(json: {
    "e164_cc": "91",
    "iso2_cc": "IN",
    "e164_sc": 0,
    "geographic": true,
    "level": 1,
    "name": "India",
    "example": "9123456789",
    "display_name": "India (IN) [+91]",
    "full_example_with_plus_sign": "+919123456789",
    "display_name_no_e164_cc": "India (IN)",
    "e164_key": "91-IN-0"
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorAuthProvider>(context, listen: true);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
        ),
        body: Form(
          key: _formKey,
          child: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.only(
                  left: 24,
                  top: 2,
                  right: 24,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Become a vendor".tr,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: kPrimaryColor,

                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Join our community to unlock your greatest asset and welcome paying guests into your home."
                                .tr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: kPrimaryColor,

                            ),
                          ),
                          const SizedBox(height: 26),
                          _buildFirstNameInput(context),
                          _buildLastNameInput(context),
                          _buildBusinessNameInput(context),
                          _buildEmailInput(context),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Container(
                              child: TextFormField(
                                controller:
                                    provider.mobileNumberInputController,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Phone Number can't be empty";
                                  } else {
                                    return null;
                                  }
                                },
                                style: textFieldStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  // labelText: labelText,

                                  border: outlineInputBorder(),

                                  disabledBorder: outlineInputBorder(),
                                  focusedBorder: outlineInputBorder(),
                                  enabledBorder: outlineInputBorder(),

                                  filled: true,
                                  fillColor: kBackgroundColor,

                                  hintStyle: GoogleFonts.spaceGrotesk(
                                    color: kPrimaryColor,
                                    fontSize: 14,
                                  ),
                                  prefixIconConstraints: BoxConstraints(
                                      minWidth: 140, maxHeight: 100),
                                  prefixIcon: IconButton(
                                    onPressed: () {
                                      countryCodeBottomSheet(
                                          (Country txcountry) {
                                        selectedCountry = txcountry;
                                        setState(() {});
                                      }, true, context);
                                    },
                                    icon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "${selectedCountry.flagEmoji}  (${selectedCountry.countryCode})",
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 2),
                                          child: Icon(
                                              Icons.arrow_drop_down_outlined,
                                              size: 18),
                                        ),
                                        Text(
                                          '+${selectedCountry.phoneCode} |',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _buildPasswordInput(context),
                          _buildTermsAndPrivacyCheckbox(context),
                          const SizedBox(
                            height: 20,
                          ),
                          TertiaryButton(
                            text: "Update My Profile As Vendor".tr,
                            press: () async {
                              if (provider.termsAndPrivacyCheckbox == false) {
                                showErrorToast(
                                    "Please accept the terms and privacy policy"
                                        .tr);
                              } else {
                                bool check = await provider.loginvendor(
                                    provider.firstnamecontroller.text,
                                    provider.lastNameInputController.text,
                                    provider.businessNameInputController.text,
                                    provider.emailInputController.text,
                                    "+${selectedCountry.phoneCode}${provider.mobileNumberInputController.text}",
                                    provider.passwordInputController.text,
                                    "1");
                                log("$check ceck");

                                // ignore: use_build_context_synchronously
                                if (check == true) {
                                  provider.firstnamecontroller.clear();
                                  provider.lastNameInputController.clear();
                                  provider.businessNameInputController.clear();
                                  provider.emailInputController.clear();
                                  provider.mobileNumberInputController.clear();
                                  provider.passwordInputController.clear();
                                  provider.termsAndPrivacyCheckbox = false;

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return OtpScreen(
                                            email: provider.emailInputController
                                                .value.text);
                                      },
                                    ),
                                  );
                                }
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 56)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildFirstNameInput(BuildContext context) {
  return Consumer<VendorAuthProvider>(
    builder: (context, provider, child) {
      return CustomTextField(
        controller: provider.firstnamecontroller,
        hintText: "First Name".tr,
        validator: (value) {
          if (value!.isEmpty) {
            return "err_msg_please_enter_valid_text".tr;
          }
          return null;
        },
      );
    },
  );
}

Widget _buildLastNameInput(BuildContext context) {
  return Consumer<VendorAuthProvider>(
    builder: (context, provider, child) {
      return CustomTextField(
        controller: provider.lastNameInputController,
        hintText: "Last Name".tr,
        validator: (value) {
          if (value!.isEmpty) {
            return "err_msg_please_enter_valid_text".tr;
          }
          return null;
        },
      );
    },
  );
}

Widget _buildBusinessNameInput(BuildContext context) {
  return Consumer<VendorAuthProvider>(
    builder: (context, provider, child) {
      return CustomTextField(
        controller: provider.businessNameInputController,
        hintText: "Business Name".tr,
        validator: (value) {
          if (value!.isEmpty) {
            return "err_msg_please_enter_valid_text".tr;
          }
          return null;
        },
      );
    },
  );
}

Widget _buildEmailInput(BuildContext context) {
  return Consumer<VendorAuthProvider>(
    builder: (context, provider, child) {
      return CustomTextField(
        controller: provider.emailInputController,
        hintText: "Email".tr,
        txKeyboardType: TextInputType.emailAddress,
        // validator: (value) {
        //   if (value == null || (!isValidEmail(value, isRequired: true))) {
        //     return "err_msg_please_enter_valid_email".tr;
        //   }
        //   return null;
        // },
      );
    },
  );
}

Widget _buildPasswordInput(BuildContext context) {
  return Consumer<VendorAuthProvider>(
    builder: (context, provider, child) {
      return CustomTextField(
        suffixicon: IconButton(
          icon: Icon(provider.isShowPassword
              ? Icons.visibility
              : Icons.visibility_off),
          onPressed: () {
            provider.isShowPassword = !provider.isShowPassword;
            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
            provider.notifyListeners();
          },
        ),
        controller: provider.passwordInputController,
        hintText: "Password".tr,
        txKeyboardType: TextInputType.visiblePassword,
        obscureText: provider.isShowPassword,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "err_msg_please_enter_valid_password".tr;
          }
          return null;
        },
      );
    },
  );
}

Widget _buildTermsAndPrivacyCheckbox(BuildContext context) {
  return Consumer<VendorAuthProvider>(
    builder: (context, provider, child) {
      return CustomCheckboxButton(
        text: "I have read and accept the Terms and Privacy Policy".tr,
        isExpandedText: true,

        value: provider.termsAndPrivacyCheckbox,
        // textStyle: CustomTextStyles.bodyMedium13,
        onChange: (value) {
          provider.updateTermsAndPrivacyCheckbox(value);
        },
      );
    },
  );
}

// Widget _buildSignUpButton(BuildContext context) {
//   return Consumer<VendorAuthProvider>(
//     builder: (context, provider, child) {
//       return   },
//   );
// }
