// ignore_for_file: prefer_const_constructors

import 'package:google_fonts/google_fonts.dart';
import 'package:moonbnd/Provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../widgets/tertiary_button.dart';
import 'otp_screen.dart';
import '../../widgets/form.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context, listen: true);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Text(
                "Forgot Password".tr,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(
              height: 32,
            ),

            //Email
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: CustomTextField(
                hintText: 'Email'.tr,
                margin: false,
                controller: emailcontroller,
                prefixicon: Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(
              height: 24,
            ),

            //text TOR

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Text(
                  "To recover your password, please enter your email address."
                      .tr,
              style: GoogleFonts.spaceGrotesk(),),
            ),
            const SizedBox(
              height: 24,
            ),

            //Continue button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: TertiaryButton(
                  text: "Send".tr,
                  press: () async {
                    await provider.resendOtp(emailcontroller.text).then(
                      (value) {
                        if (value == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpScreen(
                                forget: true,
                                email: emailcontroller.text,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
