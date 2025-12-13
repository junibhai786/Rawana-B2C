import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/auth_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/screens/profile/change_password_screen.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginSecurityScreen extends StatelessWidget {
  const LoginSecurityScreen({Key? key}) : super(key: key);

  void _showDeleteConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Are you sure?'.tr,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Account Delete Permanently'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      color: Colors.black54,

                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Expanded(
                  //   child: OutlinedButton(
                  //     style: OutlinedButton.styleFrom(
                  //       side: const BorderSide(color: flutterpads),
                  //       foregroundColor: flutterpads,
                  //       padding: const EdgeInsets.symmetric(vertical: 12),
                  //     ),
                  //     onPressed: () async {
                  //       Navigator.pop(context);
                  //       SharedPreferences prefs =
                  //           await SharedPreferences.getInstance();
                  //       // handle delete action
                  //       final authProvider =
                  //           Provider.of<AuthProvider>(context, listen: false);
                  //       final result = await authProvider.deleteMyAccount();
                  //       if (result == true) {
                  //         await prefs.clear();
                  //              if (context.mounted) {
                  //           Navigator.pushAndRemoveUntil(
                  //             context,
                  //             MaterialPageRoute(
                  //                 builder: (context) => SignInScreen()),
                  //             (route) => false, // Clear all previous routes
                  //           );
                  //         }

                  //         // Account deleted successfully
                  //         // ignore: use_build_context_synchronously
                  //       } else {
                  //         // Show error message
                  //         // ignore: use_build_context_synchronously
                  //         ScaffoldMessenger.of(context).showSnackBar(
                  //           SnackBar(
                  //               content: Text(
                  //                   'Failed to delete account. Please try again.'
                  //                       .tr)),
                  //         );
                  //       }
                  //       // Handle delete action
                  //     },
                  //     child: Text('Delete'.tr),
                  //   ),
                  // ),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: flutterpads),
                        foregroundColor: flutterpads,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        // Show loading indicator or disable button during processing
                        try {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);

                          // Delete account and check result
                          final result = await authProvider.deleteMyAccount();
                          if (result == true) {
                            await prefs.clear(); // Clear user data

                            // Navigate to SignInScreen after account deletion
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignInScreen()),
                                (route) => false, // Clear all previous routes
                              );
                            }
                          } else {
                            // Show error message
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to delete account. Please try again.'
                                        .tr,
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'An error occurred. Please try again.'.tr),
                              ),
                            );
                          }
                        }
                      },
                      child: Text('Delete'.tr,style:  GoogleFonts.spaceGrotesk(color: Colors.black,fontWeight: FontWeight.w500),),
                    ),
                  ),

                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'.tr,style: GoogleFonts.spaceGrotesk(color: Colors.white,fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,

        elevation: 0,
        title: Text('Login & Security',style: GoogleFonts.spaceGrotesk(fontSize: 18,fontWeight: FontWeight.w700,color: Colors.black),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 40),
            Text(
              'Login'.tr,
              style: GoogleFonts.spaceGrotesk(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18
              )
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password'.tr,
                      style:  GoogleFonts.spaceGrotesk(
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                          fontSize: 18
                      )
                    ),
                    SizedBox(height: 4),
                    // Text(
                    //   'last updated 1 month ago'.tr,
                    //   style: TextStyle(
                    //     color: grey,
                    //     fontSize: 14,
                    //     fontFamily: 'Inter'.tr,
                    //   ),
                    // ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return ChangePasswordScreen();
                      },
                    ));
                    // Handle password update
                  },
                  child: Text(
                    'Update'.tr,
                    style: GoogleFonts.spaceGrotesk(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        fontSize: 18
                    )
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'Account'.tr,
              style: GoogleFonts.spaceGrotesk(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 18
              )
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delete your account'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                    fontSize: 18
                  )
                ),
                TextButton(
                  onPressed: () => _showDeleteConfirmation(context),
                  child: Text(
                    'Delete'.tr,
                    style: GoogleFonts.spaceGrotesk(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                      fontSize: 18
                    )
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
