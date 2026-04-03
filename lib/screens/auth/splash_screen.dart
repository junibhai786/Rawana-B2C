import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 5 seconds, then navigate to onboarding
    Future.delayed(const Duration(seconds: 5), () async {
      // Set flag that app has launched before
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_launched_before', true);

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFC2E9F2),
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- LOGO SECTION ---
            // OPTION 1: If you have the image asset (Recommended)
            Image.asset(
              'assets/images/logo.png',
              width: 250,
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'signin_screen.dart';
// import '../constants.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(
//       const Duration(seconds: 2),
//       () => Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const SignInScreen(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: kBackgroundColor,
//       body: SafeArea(
//         child: SizedBox(
//           width: double.infinity,
//           child: Column(
//             children: [
//               const Spacer(),
//               SizedBox(
//                 child: Image.asset(
//                   // width: screenWidth * 0.3,
//                   'assets/haven/logo.png',
//                 ),
//               ),
//               const Spacer(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
