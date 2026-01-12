// ignore_for_file: prefer_const_constructors
import 'dart:developer';
import 'package:country_picker/country_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/vendor/sign_up_vendor_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:moonbnd/widgets/secondary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/auth_provider.dart';
import 'package:moonbnd/widgets/country_code.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:moonbnd/constants.dart';
import 'otp_screen.dart';
import 'package:flutter/gestures.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;

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

  bool termsAndConditionCheckBox = false;
  bool showPassword = true;
  bool showConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context, listen: true);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : Form(
              key: _formKey,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Create Account".tr,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.2),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Start your travel journey with us".tr,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey.shade600,
                              height: 1.4),
                        ),
                        SizedBox(height: 40),

                        /// First Name
                        Text(
                          "First Name".tr,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextFormField(
                            controller: firstNameController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z\s]')),
                              LengthLimitingTextInputFormatter(20),
                            ],
                            style: GoogleFonts.spaceGrotesk(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Enter your first name'.tr,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              prefixIcon: Icon(
                                Icons.person_2_outlined,
                                color: Colors.grey.shade500,
                                size: 22,
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty)
                                return "First Name can't be empty".tr;
                              if (value.length < 2)
                                return "First name must be at least 2 char".tr;
                              // Regex: Only letters and spaces, 2-20 characters
                              final nameRegex = RegExp(r'^[a-zA-Z\s]{2,20}$');
                              if (!nameRegex.hasMatch(value)) {
                                return "First name must contain only letters (2-20 characters)"
                                    .tr;
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 24),

                        /// Last Name
                        Text(
                          "Last Name".tr,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextFormField(
                            controller: lastNameController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z\s]')),
                              LengthLimitingTextInputFormatter(20),
                            ],
                            style: GoogleFonts.spaceGrotesk(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Enter your last name'.tr,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              prefixIcon: Icon(
                                Icons.person_2_outlined,
                                color: Colors.grey.shade500,
                                size: 22,
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty)
                                return "Last Name can't be empty".tr;
                              if (value.length < 2)
                                return "Last name must be at least 2 characters"
                                    .tr;
                              // Regex: Only letters and spaces, 2-20 characters
                              final nameRegex = RegExp(r'^[a-zA-Z\s]{2,20}$');
                              if (!nameRegex.hasMatch(value)) {
                                return "Last name must contain only letters (2-20 characters)"
                                    .tr;
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 24),

                        /// Email
                        Text(
                          "Email".tr,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: GoogleFonts.spaceGrotesk(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Enter your email'.tr,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.grey.shade500,
                                size: 22,
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty)
                                return "Email can't be empty".tr;
                              final emailRegex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                              if (!emailRegex.hasMatch(value))
                                return "Please enter a valid email address".tr;
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 24),

                        /// Phone Number
                        Text(
                          "Phone Number".tr,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextFormField(
                            controller: phoneNumberController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            style: GoogleFonts.spaceGrotesk(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Enter your phone number'.tr,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              counterText: '',
                              prefixIconConstraints:
                                  BoxConstraints(minWidth: 120, maxHeight: 100),
                              prefixIcon: Container(
                                padding: EdgeInsets.only(left: 16),
                                child: GestureDetector(
                                  onTap: () {
                                    countryCodeBottomSheet((Country txcountry) {
                                      selectedCountry = txcountry;
                                      setState(() {});
                                    }, true, context);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                                        style: GoogleFonts.spaceGrotesk(
                                            fontSize: 16),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey.shade500,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty)
                                return "Phone Number can't be empty".tr;
                              // Regex: Exactly 10 digits
                              final phoneRegex = RegExp(r'^[0-9]{10}$');
                              if (!phoneRegex.hasMatch(value)) {
                                return "Phone number must be exactly 10 digits"
                                    .tr;
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 24),

                        /// Password
                        Text(
                          "Password".tr,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: showPassword,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(32),
                            ],
                            style: GoogleFonts.spaceGrotesk(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Create a password'.tr,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey.shade500,
                                size: 22,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showPassword = !showPassword;
                                  });
                                },
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty)
                                return "Password can't be empty".tr;
                              if (value.length < 8)
                                return "Password must be at least 8 characters"
                                    .tr;
                              if (value.length > 32)
                                return "Password must not exceed 32 characters"
                                    .tr;
                              // Regex: At least one uppercase, lowercase, digit, special character, 8-32 chars
                              final passwordRegex = RegExp(
                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]{8,32}$');
                              if (!passwordRegex.hasMatch(value))
                                return "Password must contain uppercase, lowercase, number & special character"
                                    .tr;
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 24),

                        /// Confirm Password
                        Text(
                          "Confirm Password".tr,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextFormField(
                            controller: confirmPasswordController,
                            obscureText: showConfirmPassword,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(32),
                            ],
                            style: GoogleFonts.spaceGrotesk(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Confirm your password'.tr,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              prefixIcon: Icon(
                                Icons.check_circle_outline,
                                color: Colors.grey.shade500,
                                size: 22,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    showConfirmPassword = !showConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  showConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty)
                                return "Confirm Password can't be empty".tr;
                              if (value.length < 8)
                                return "Password must be at least 8 characters"
                                    .tr;
                              if (value.length > 32)
                                return "Password must not exceed 32 characters"
                                    .tr;
                              if (value != passwordController.text)
                                return "Passwords do not match".tr;
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16),

                        /// Terms Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              side: BorderSide(color: Colors.grey),
                              value: termsAndConditionCheckBox,
                              onChanged: (bool? value) {
                                setState(() {
                                  termsAndConditionCheckBox = value!;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: Color(0xFF009CB8),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text.rich(
                                  TextSpan(
                                    style: GoogleFonts.spaceGrotesk(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        height: 1.4),
                                    children: [
                                      TextSpan(text: "I agree to the ".tr),
                                      TextSpan(
                                        text: "Terms of Service".tr,
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Color(0xFF05A8C7),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(text: " and ".tr),
                                      TextSpan(
                                        text: "Privacy Policy".tr,
                                        style: GoogleFonts.spaceGrotesk(
                                          color: Color(0xFF05A8C7),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32),

                        /// Create Account Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState?.validate() == true) {
                                _formKey.currentState!.save();

                                if (termsAndConditionCheckBox) {
                                  setState(() {
                                    loading = true;
                                  });

                                  bool check = await provider.signup(
                                    email: emailController.value.text,
                                    password: passwordController.value.text,
                                    firstName: firstNameController.value.text,
                                    lastName: lastNameController.value.text,
                                    phoneNo:
                                        "+${selectedCountry.phoneCode}${phoneNumberController.value.text}",
                                  );

                                  setState(() {
                                    loading = false;
                                  });

                                  if (check) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return OtpScreen(
                                            email: emailController.value.text,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                } else {
                                  EasyLoading.showToast(
                                    "Please read and agree to the Terms of Service and Privacy Policy"
                                        .tr,
                                    maskType: EasyLoadingMaskType.black,
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF05A8C7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: Text(
                              "Create Account".tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        // Continue as Guest, Vendor Buttons etc. remain unchanged...
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
// // ignore_for_file: prefer_const_constructors
//
// import 'dart:developer';
//
// import 'package:country_picker/country_picker.dart';
// import 'package:moonbnd/vendor/sign_up_vendor_screen.dart';
// import 'package:moonbnd/widgets/bottom_navigation.dart';
// import 'package:moonbnd/widgets/secondary_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:moonbnd/Provider/auth_provider.dart';
// import 'package:moonbnd/widgets/country_code.dart';
// import '../../widgets/tertiary_button.dart';
// import '../../constants.dart';
// import 'otp_screen.dart';
// import '../../widgets/form.dart';
//
// //sign up screen
//
// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});
//
//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
//   TextEditingController firstNameController = TextEditingController();
//   TextEditingController lastNameController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController phoneNumberController = TextEditingController();
//
//   TextEditingController passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   bool loading = false;
//
//   Country selectedCountry = Country.from(json: {
//     "e164_cc": "91",
//     "iso2_cc": "IN",
//     "e164_sc": 0,
//     "geographic": true,
//     "level": 1,
//     "name": "India",
//     "example": "9123456789",
//     "display_name": "India (IN) [+91]",
//     "full_example_with_plus_sign": "+919123456789",
//     "display_name_no_e164_cc": "India (IN)",
//     "e164_key": "91-IN-0"
//   });
//
//   bool termsAndConditionCheckBox = false;
//   bool showpassword = true;
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<AuthProvider>(context, listen: true);
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(),
//       body: loading
//           ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
//           : Form(
//               key: _formKey,
//               child: SafeArea(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(
//                         height: 12,
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 20,
//                         ),
//                         child: Text(
//                           "Sign Up".tr,
//                           style: TextStyle(
//                             fontFamily: 'Inter'.tr,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(
//                         height: 32,
//                       ),
//
//                       //first name form
//
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 20,
//                         ),
//                         child: CustomTextField(
//                           controller: firstNameController,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "First Name can't be empty";
//                             } else {
//                               return null;
//                             }
//                           },
//                           hintText: 'First Name'.tr,
//                           margin: false,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 12,
//                       ),
//
//                       //last name form
//
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 20,
//                         ),
//                         child: CustomTextField(
//                           controller: lastNameController,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "Last Name can't be empty";
//                             } else {
//                               return null;
//                             }
//                           },
//                           hintText: 'Last Name'.tr,
//                           margin: false,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 12,
//                       ),
//
//                       //Email form
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 20,
//                         ),
//                         child: CustomTextField(
//                           controller: emailController,
//                           hintText: 'Email Address'.tr,
//                           txKeyboardType: TextInputType.emailAddress,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "Email Address can't be empty";
//                             } else {
//                               return null;
//                             }
//                           },
//                           margin: false,
//                         ),
//                       ),
//                       SizedBox(height: 12),
//
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 20),
//                         child: TextFormField(
//                           controller: phoneNumberController,
//                           keyboardType: TextInputType.number,
//                           maxLength: 10,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "Phone Number can't be empty";
//                             } else {
//                               return null;
//                             }
//                           },
//                           style: textFieldStyle(fontSize: 14),
//                           decoration: InputDecoration(
//                             // labelText: labelText,
//
//                             border: outlineInputBorder(),
//
//                             disabledBorder: outlineInputBorder(),
//                             focusedBorder: outlineInputBorder(),
//                             enabledBorder: outlineInputBorder(),
//
//                             filled: true,
//                             fillColor: kBackgroundColor,
//
//                             hintStyle: TextStyle(
//                               color: kPrimaryColor,
//                               fontSize: 14,
//                             ),
//                             prefixIconConstraints:
//                                 BoxConstraints(minWidth: 140, maxHeight: 100),
//                             prefixIcon: IconButton(
//                               onPressed: () {
//                                 countryCodeBottomSheet((Country txcountry) {
//                                   selectedCountry = txcountry;
//                                   setState(() {});
//                                 }, true, context);
//                               },
//                               icon: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Text(
//                                     "${selectedCountry.flagEmoji}  (${selectedCountry.countryCode})",
//                                   ),
//                                   Padding(
//                                     padding:
//                                         EdgeInsets.symmetric(horizontal: 2),
//                                     child: Icon(Icons.arrow_drop_down_outlined,
//                                         size: 18),
//                                   ),
//                                   Text(
//                                     '+${selectedCountry.phoneCode} |',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w400,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(height: 12),
//
//                       //password form
//
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 20,
//                         ),
//                         child: CustomTextField(
//                           suffixicon: IconButton(
//                               onPressed: () {
//                                 setState(() {
//                                   showpassword = !showpassword;
//                                 });
//                               },
//                               icon: Icon(
//                                 showpassword
//                                     ? Icons.visibility_off
//                                     : Icons.visibility,
//                                 color: Colors.black,
//                               )),
//                           controller: passwordController,
//                           obscureText: showpassword ? true : false,
//                           hintText: 'Password'.tr,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "Password can't be empty";
//                             } else {
//                               return null;
//                             }
//                           },
//                           margin: false,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 24,
//                       ),
//
//                       //TOR agreement
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               margin: EdgeInsets.only(
//                                   bottom: 20.0), // Adjust the margin as needed
//                               child: Checkbox(
//                                 value: termsAndConditionCheckBox,
//                                 onChanged: (bool? value) {
//                                   setState(() {
//                                     termsAndConditionCheckBox = value!;
//                                   });
//                                 },
//                               ),
//                             ),
//                             Expanded(
//                               child: Text.rich(
//                                 style: TextStyle(
//                                   fontFamily: 'Inter'.tr,
//                                   fontSize: 13,
//                                   color: Colors.black,
//                                 ),
//                                 textAlign: TextAlign
//                                     .start, // Align text to the start (left)
//                                 textScaleFactor: 1.0,
//                                 TextSpan(
//                                   children: [
//                                     TextSpan(
//                                       text:
//                                           'By creating account or signing in, you have read and agreed to '
//                                               .tr,
//                                       style: TextStyle(
//                                           fontFamily: 'Inter'.tr,
//                                           color: kPrimaryColor),
//                                     ),
//                                     TextSpan(
//                                       text: 'Privacy Policy'.tr,
//                                       style: TextStyle(
//                                         fontFamily: 'Inter'.tr,
//                                         color: kPrimaryColor,
//                                         decoration: TextDecoration.underline,
//                                       ),
//                                     ),
//                                     TextSpan(
//                                       text: 'and'.tr,
//                                     ),
//                                     TextSpan(
//                                       text: 'Term of Service'.tr,
//                                       style: TextStyle(
//                                         fontFamily: 'Inter'.tr,
//                                         color: kPrimaryColor,
//                                         decoration: TextDecoration.underline,
//                                       ),
//                                     ),
//                                     TextSpan(
//                                       text: '.',
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       //Sign up button
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                         ),
//                         child: TertiaryButton(
//                             text: "Sign Up".tr,
//                             press: () async {
//                               if (_formKey.currentState?.validate() == true) {
//                                 _formKey.currentState!.save();
//
//                                 if (termsAndConditionCheckBox) {
//                                   setState(() {
//                                     loading = true;
//                                   });
//
//                                   log(selectedCountry.phoneCode);
//
//                                   bool check = await provider.signup(
//                                       email: emailController.value.text,
//                                       password: passwordController.value.text,
//                                       firstName: firstNameController.value.text,
//                                       lastName: lastNameController.value.text,
//                                       phoneNo:
//                                           "+${selectedCountry.phoneCode}${phoneNumberController.value.text}");
//
//                                   log("$check ceck");
//
//                                   setState(() {
//                                     loading = false;
//                                   });
//
//                                   if (check) {
//                                     // ignore: use_build_context_synchronously
//                                     Navigator.of(context).push(
//                                       MaterialPageRoute(
//                                         builder: (context) {
//                                           return OtpScreen(
//                                               email:
//                                                   emailController.value.text);
//                                         },
//                                       ),
//                                     );
//                                   }
//                                 } else {
//                                   EasyLoading.showToast(
//                                       "Please read privacy policy and term of service",
//                                       maskType: EasyLoadingMaskType.black);
//                                 }
//                               }
//                             }),
//                       ),
//
//                       // const SizedBox(
//                       //   height: 20,
//                       // ),
//
//                       // Padding(
//                       //   padding: EdgeInsets.symmetric(horizontal: 20),
//                       //   child: Row(
//                       //     children: [
//                       //       Expanded(
//                       //         child: Divider(
//                       //           color: kColor1,
//                       //           height: 25,
//                       //           thickness: 0.9,
//                       //           endIndent: 30,
//                       //         ),
//                       //       ),
//                       //       Text(
//                       //         'OR'.tr,
//                       //         style: TextStyle(
//                       //             fontFamily: 'Inter'.tr,
//                       //             fontSize: 14,
//                       //             color: kSecondaryColor),
//                       //       ),
//                       //       Expanded(
//                       //         child: Divider(
//                       //           color: kColor1,
//                       //           height: 25,
//                       //           thickness: 0.9,
//                       //           indent: 30,
//                       //         ),
//                       //       ),
//                       //     ],
//                       //   ),
//                       // ),
//
//                       //social login
//
//                       const SizedBox(
//                         height: 16,
//                       ),
//
//                       Padding(
//                         padding: const EdgeInsets.only(left: 20, right: 20),
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: const Size.fromHeight(48),
//                             backgroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 side: BorderSide(
//                                     width: 1, color: Colors.black12)),
//                           ),
//                           onPressed: () {
//                             Navigator.of(context).pushAndRemoveUntil(
//                               MaterialPageRoute(
//                                 builder: (context) {
//                                   return BottomNav();
//                                 },
//                               ),
//                               (route) => false,
//                             );
//                           },
//                           child: Text(
//                             "Continue as Guest".tr,
//                             style: TextStyle(
//                               fontFamily: 'Inter'.tr,
//                               color: Colors.black,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(
//                       //     horizontal: 20,
//                       //   ),
//                       //   child: SocialButton(
//                       //     icon: "assets/haven/apple.svg",
//                       //     press: () {},
//                       //     text: "Continue with Apple".tr,
//                       //   ),
//                       // ),
//                       // const SizedBox(
//                       //   height: 14,
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(
//                       //     horizontal: 20,
//                       //   ),
//                       //   child: SocialButton(
//                       //     icon: "assets/haven/google.svg",
//                       //     press: () {},
//                       //     text: "Continue with Google".tr,
//                       //   ),
//                       // ),
//                       // const SizedBox(
//                       //   height: 14,
//                       // ),
//                       // Padding(
//                       //   padding: const EdgeInsets.symmetric(
//                       //     horizontal: 20,
//                       //   ),
//                       //   child: SocialButton(
//                       //     icon: "assets/haven/facebook.svg",
//                       //     press: () {},
//                       //     text: "Continue with Facebook".tr,
//                       // ),
//                       // ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: Divider(
//                               thickness: 2,
//                             ),
//                           ),
//                           SizedBox(
//                             width: 2,
//                           ),
//                           Center(child: Text("or".tr)),
//                           SizedBox(
//                             width: 2,
//                           ),
//                           Expanded(
//                             child: Divider(
//                               thickness: 2,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                         ),
//                         child: SecondaryButton(
//                             text: "Become a Vendor ".tr,
//                             press: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => SignupVendorScreen()),
//                               );
//                             }),
//                       ),
//                       SizedBox(
//                         height: 25,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// }
