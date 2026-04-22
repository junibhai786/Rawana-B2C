import 'dart:developer';
import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/screens/auth/newpassword.dart';
import 'package:flutter/material.dart';
import 'package:moonbnd/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/auth_provider.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import '../../widgets/tertiary_button.dart';
import '../../constants.dart';

class OtpScreen extends StatefulWidget {
  String email;
  bool forget;

  OtpScreen({super.key, this.email = "", this.forget = false});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

  String otpInput = "";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context, listen: true);
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(),
      body: loading
          ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Verification".tr,
                        style: GoogleFonts.spaceGrotesk(

                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Text(
                      "Please enter the 4-digit code you received in your email".tr,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: kPrimaryColor,

                      ),
                      textAlign: TextAlign.left,
                    ),
                    // const SizedBox(
                    //   height: 24,
                    // ),

                    // Text(
                    //   "Please enter the OTP sent to your phone",
                    //   style: TextStyle(fontSize: 16),
                    // ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: screenWidth,
                        child: PinCodeTextField(
                          length: 4,
                          animationType: AnimationType.scale,
                          pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(15),
                              fieldHeight: 60,
                              fieldWidth: 55,
                              inactiveFillColor: Colors.grey.withOpacity(0.1),
                              activeFillColor: Colors.grey.withOpacity(0.1),
                              selectedFillColor: Colors.grey.withOpacity(0.1),
                              inactiveColor: Colors.transparent,
                              activeColor: Colors.transparent,
                              selectedColor: AppColors.primary.withOpacity(0.3)
                          ),
                          animationDuration: Duration(milliseconds: 300),
                          enableActiveFill: true,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              otpInput = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            return false; // Prevent text pasting
                          },
                          appContext: context,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Allow only numeric input
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    const SizedBox(
                      height: 20,
                    ),
                    //Sign up button
                    TertiaryButton(
                        text: "Verify".tr,
                        press: () async {
                          // if (_formKey.currentState?.validate() == true) {
                          //                 _formKey.currentState!.save();

                          if (otpInput.isNotEmpty) {
                            setState(() {
                              loading = true;
                            });

                            bool check = await provider.verifyOtp(
                                widget.email, otpInput);

                            log("$check ceck");

                            setState(() {
                              loading = false;
                            });

                            if (check) {
                              if (widget.forget == true) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ResetPasswordScreen(
                                        email: widget.email,
                                      );
                                    },
                                  ),
                                );
                              } else {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return BottomNav();
                                    },
                                  ),
                                  (route) => false,
                                );
                              }
                            }
                            // ignore: use_build_context_synchronously
                          } else {
                            EasyLoading.showToast("Please enter otp".tr,
                                maskType: EasyLoadingMaskType.black);
                          }
                          //               }
//
                        }),
                    const SizedBox(
                      height: 24,
                    ),
                    Text(
                      "Didn't receive any code?".tr,
                      style: GoogleFonts.spaceGrotesk(
                        color: kPrimaryColor,

                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          loading = true;
                        });
                        await provider.resendOtp(widget.email);
                        setState(() {
                          loading = false;
                        });
                      },
                      child: Text(
                        "Resend new code".tr,
                        style: GoogleFonts.spaceGrotesk(

                          color: kPrimaryColor,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
