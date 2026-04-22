import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/language/language_controller.dart';
import 'package:moonbnd/Provider/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:moonbnd/widgets/form.dart';
import 'package:moonbnd/constants.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:moonbnd/app_colors.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LanguageController languageController = Get.find<LanguageController>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late String currentLanguage;
  bool loading = false;
  bool rememberMe = false;
  bool showPassword = true;

  @override
  void initState() {
    super.initState();
    // Always clear fields on screen load to ensure fresh start
    emailController.clear();
    passwordController.clear();
    currentLanguage = languageController.langLocal;
    _loadUserCredentials();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if user is logged out (token is null)
    // and clear the sensitive fields
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.myProfile == null &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      // User has been logged out, clear the sensitive fields
      emailController.clear();
      passwordController.clear();
      rememberMe = false;
    }
  }

  Future<void> _loadUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('remember_me') ?? false;
    final token = prefs.getString('userToken') ?? '';

    setState(() {
      if (rememberMe && token.isNotEmpty) {
        // User is logged in with remember me checked — pre-fill email only
        emailController.text = prefs.getString('email') ?? '';
        // SECURITY: Never pre-fill password field from storage
      } else {
        // User logged out or remember me was off — ensure fields are empty
        emailController.clear();
        passwordController.clear();
      }
    });
  }

  Future<void> _saveUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('email', emailController.text);
      // SECURITY: Never save password to SharedPreferences
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('email');
      // Password not saved, nothing to remove
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
            child: GestureDetector(
              onTap: () => _showLanguageBottomSheet(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.language, color: Colors.black, size: 16),
                    SizedBox(width: 4),
                    Text(
                      currentLanguage,
                      style: TextStyle(color: Colors.black, fontSize: 12),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/icons/rawana.logo.jpeg',
                      height: 60, // Adjust height as needed
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),

                  // Welcome Back Title
                  Text(
                    "Welcome Back".tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),

                  // Subtitle
                  Text(
                    "Sign in to continue your journey".tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Email Label
                  Text(
                    "Enter your email".tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Email Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 50,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your email'.tr,
                        hintStyle: GoogleFonts.spaceGrotesk(
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        counterText: "", // Hide character counter
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.grey.shade500,
                          size: 22,
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Email can't be empty".tr;
                        } else if (!value.contains('@')) {
                          return "Please enter a valid email".tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),

                  // Password Label
                  Text(
                    "Password".tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: showPassword,
                      maxLength: 20,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your password'.tr,
                        hintStyle: GoogleFonts.spaceGrotesk(
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        counterText: "", // Hide character counter
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
                        if (value!.isEmpty) {
                          return "Password can't be empty".tr;
                        } else if (value.length < 6) {
                          return "Password must be at least 6 characters".tr;
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 10),

                  // Remember me & Forgot Password Row
                  Row(
                    children: [
                      // Remember Me Checkbox
                      Row(
                        children: [
                          Checkbox(
                            side: BorderSide(color: Colors.grey),
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            activeColor: Color(0xFF009CB8),
                          ),
                          Text(
                            "Remember me".tr,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: Color(0xff65758B),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      // Forgot Password
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        ),
                        child: Text(
                          "Forgot Password?".tr,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null // Disable button while loading
                          : () async {
                              if (_formKey.currentState?.validate() == true) {
                                _formKey.currentState!.save();
                                setState(() => loading = true);

                                bool check = await provider.login(
                                  emailController.value.text,
                                  passwordController.value.text,
                                  rememberMe,
                                );

                                setState(() => loading = false);

                                if (check) {
                                  await _saveUserCredentials();
                                  // Clear email and password fields after successful login
                                  emailController.clear();
                                  passwordController.clear();
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (context) => BottomNav(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: loading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Sign In".tr,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(width: 1, color: Colors.black12)),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) {
                              return BottomNav();
                            },
                          ),
                          (route) => false,
                        );
                      },
                      child: Text(
                        "Continue as Guest".tr,
                        style: GoogleFonts.spaceGrotesk(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  // Divider with "or continue with"
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or continue with'.tr,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // Social Login Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Image.asset(
                                  'assets/images/google.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.g_mobiledata, size: 24),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Google'.tr,
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Facebook Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Image.asset(
                                  'assets/images/facebook.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.facebook, size: 24),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Facebook'.tr,
                                style: GoogleFonts.spaceGrotesk(
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Don't have an account?
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        children: [
                          TextSpan(text: "Don't have an account? ".tr),
                          TextSpan(
                            text: "Sign Up".tr,
                            style: GoogleFonts.spaceGrotesk(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            recognizer: TapGestureRecognizer()
                              // Guard: no loader should be shown for Sign Up navigation
                              ..onTap = () {
                                // Only navigate to Sign Up, no state changes
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Terms and Privacy
                  Center(
                    child: Text.rich(
                      TextSpan(
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: "By continuing, you agree to our ".tr),
                          TextSpan(
                            text: "Terms of Service".tr,
                            style: GoogleFonts.spaceGrotesk(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: " and ".tr),
                          TextSpan(
                            text: "Privacy Policy".tr,
                            style: GoogleFonts.spaceGrotesk(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Language'.tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('English'.tr, style: GoogleFonts.spaceGrotesk()),
                  trailing: currentLanguage == 'English'
                      ? Text(
                          'Default'.tr,
                          style: TextStyle(color: AppColors.primary),
                        )
                      : null,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: currentLanguage == 'English'
                            ? Colors.grey
                            : Colors.transparent,
                        width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {
                    setState(() {
                      currentLanguage = 'English';
                      languageController.changeLanguage('en');
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Arabic'.tr, style: GoogleFonts.spaceGrotesk()),
                  trailing: currentLanguage == 'Arabic'.tr
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: currentLanguage == 'Arabic'.tr
                            ? Colors.grey
                            : Colors.transparent,
                        width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {
                    setState(() {
                      currentLanguage = 'Arabic'.tr;
                      languageController.changeLanguage('ar');
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// // ignore_for_file: prefer_const_constructors
//
// import 'package:moonbnd/language/language_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:moonbnd/Provider/auth_provider.dart';
// import '../../widgets/tertiary_button.dart';
// import 'signup_screen.dart';
// import '../../widgets/bottom_navigation.dart';
// import 'forgot_password_screen.dart';
// import '../../constants.dart';
// import '../../widgets/form.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SignInScreen extends StatefulWidget {
//   SignInScreen({super.key});
//
//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }
//
// class _SignInScreenState extends State<SignInScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   TextEditingController emailController = TextEditingController();
//
//   TextEditingController passwordController = TextEditingController();
//   final LanguageController languageController = Get.find<LanguageController>();
//   late String currentLanguage;
//   bool loading = false;
//   bool rememberMe = false;
//
//   @override
//   void initState() {
//     super.initState();
//     currentLanguage = languageController.langLocal;
//     _loadUserCredentials();
//   }
//
//   // Load saved credentials if "Remember Me" was checked
//   Future<void> _loadUserCredentials() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       bool rememberMee = prefs.getBool('remember_me') ?? false;
//       print("213213${rememberMee}");
//       print(emailController.text);
//       print(passwordController.text);
//
//       if (rememberMee) {
//         emailController.text = prefs.getString('email') ?? '';
//         passwordController.text = prefs.getString('password') ?? '';
//       }
//     });
//   }
//
//   Future<void> _saveUserCredentials() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (rememberMe) {
//       await prefs.setBool('remember_me', true);
//       await prefs.setString('email', emailController.text);
//       await prefs.setString('password', passwordController.text);
//     } else {
//       await prefs.setBool('remember_me', false);
//       await prefs.remove('email');
//       await prefs.remove('password');
//     }
//   }
//
//   bool showpassword = true;
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<AuthProvider>(context, listen: true);
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         actions: <Widget>[
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
//             child: GestureDetector(
//               onTap: () => _showLanguageBottomSheet(context),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.language, color: Colors.black),
//                     SizedBox(width: 8),
//                     Text(
//                       currentLanguage,
//                       style: TextStyle(color: Colors.black),
//                     ),
//                     Icon(
//                       Icons.keyboard_arrow_down,
//                       color: Colors.black,
//                       size: 18,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: loading
//           ? Center(child: CircularProgressIndicator(color: kSecondaryColor))
//           : SafeArea(
//               child: Form(
//                 key: _formKey,
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
//                           "Log in".tr,
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontFamily: 'Inter'.tr,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 32),
//
//                       //Email
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 20,
//                         ),
//                         child: CustomTextField(
//                           controller: emailController,
//                           txKeyboardType: TextInputType.emailAddress,
//                           hintText: 'Email'.tr,
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "Email can't be empty".tr;
//                             } else {
//                               return null;
//                             }
//                           },
//                           margin: false,
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 16,
//                       ),
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
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return "Password can't be empty".tr;
//                             } else {
//                               return null;
//                             }
//                           },
//                           obscureText: showpassword ? true : false,
//                           hintText: 'Password'.tr,
//                           margin: false,
//                         ),
//                       ),
//                       SizedBox(height: 16),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20),
//                         child: Row(
//                           children: [
//                             Checkbox(
//                               value: rememberMe,
//                               onChanged: (value) {
//                                 setState(() {
//                                   rememberMe = value ?? false;
//                                 });
//                               },
//                             ),
//                             Text("Remember Me".tr),
//                             Spacer(),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 20),
//                               child: Align(
//                                 alignment: Alignment.topRight,
//                                 child: InkWell(
//                                   onTap: () => Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           const ForgotPasswordScreen(),
//                                     ),
//                                   ),
//                                   child: Stack(
//                                     children: [
//                                       Padding(
//                                         padding: EdgeInsets.only(bottom: 0.1),
//                                         child: Text(
//                                           "Forgot Password?".tr,
//                                           style: TextStyle(
//                                             fontFamily: 'Inter'.tr,
//                                             color: kPrimaryColor,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         bottom: 0,
//                                         left: 0,
//                                         right: 0,
//                                         child: Container(
//                                           height: 1,
//                                           color: kPrimaryColor,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(
//                         height: 16,
//                       ),
//
//                       //Sign in button
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                         ),
//                         child: TertiaryButton(
//                             text: "Log in".tr,
//                             press: () async {
//                               if (_formKey.currentState?.validate() == true) {
//                                 _formKey.currentState!.save();
//
//                                 setState(() {
//                                   loading = true;
//                                 });
//
//                                 bool check = await provider.login(
//                                     emailController.value.text,
//                                     passwordController.value.text,
//                                     rememberMe);
//
//                                 setState(() {
//                                   loading = false;
//                                 });
//
//                                 if (check) {
//                                   await _saveUserCredentials();
//
//                                   Navigator.of(context).pushAndRemoveUntil(
//                                     MaterialPageRoute(
//                                       builder: (context) {
//                                         return BottomNav();
//                                       },
//                                     ),
//                                     (route) => false,
//                                   );
//                                 }
//                               }
//                             }),
//                       ),
//                       SizedBox(
//                         height: 20,
//                       ),
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
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Align(
//                             alignment: Alignment.center,
//                             child: Text(
//                               "Don’t have an account?".tr,
//                               style: TextStyle(
//                                   fontFamily: 'Inter'.tr, color: kPrimaryColor),
//                             ),
//                           ),
//                           SizedBox(width: 2),
//                           Align(
//                             alignment: Alignment.center,
//                             child: InkWell(
//                               onTap: () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const SignUpScreen(),
//                                 ),
//                               ),
//                               child: Text(
//                                 "Sign Up Now".tr,
//                                 style: TextStyle(
//                                   fontFamily: 'Inter'.tr,
//                                   color: kPrimaryColor,
//                                   fontWeight: FontWeight.w600,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(
//                         height: 20,
//                       ),
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
//                       //         'or'.tr,
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
//                       const SizedBox(
//                         height: 16,
//                       ),
//
//                       //TOR agreement
//                       const SizedBox(
//                         height: 25,
//                       ),
//
//                       const SizedBox(
//                         height: 24,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
//
//   void _showLanguageBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return SizedBox(
//           height: 220,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   'Select Language'.tr,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: ListTile(
//                   title: Text('English'.tr),
//                   trailing: currentLanguage == 'English'
//                       ? Text(
//                           'Default'.tr,
//                           style: TextStyle(color: AppColors.primary),
//                         )
//                       : null,
//                   shape: RoundedRectangleBorder(
//                     side: BorderSide(
//                         color: currentLanguage == 'English'
//                             ? Colors.grey
//                             : Colors.transparent,
//                         width: 1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   onTap: () {
//                     setState(() {
//                       currentLanguage = 'English';
//                       languageController.changeLanguage('en');
//                     });
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: ListTile(
//                   title: Text('Arabic'.tr),
//                   trailing: currentLanguage == 'Arabic'.tr
//                       ? Icon(Icons.check, color: AppColors.primary)
//                       : null,
//                   shape: RoundedRectangleBorder(
//                     side: BorderSide(
//                         color: currentLanguage == 'Arabic'.tr
//                             ? Colors.grey
//                             : Colors.transparent,
//                         width: 1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   onTap: () {
//                     setState(() {
//                       currentLanguage = 'Arabic'.tr;
//                       languageController.changeLanguage('ar');
//                     });
//                     Navigator.pop(context);
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
