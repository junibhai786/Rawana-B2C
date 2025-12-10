import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/Urls/url_holder_loan.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/widgets/tertiary_button.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moonbnd/constants.dart';

class PricingPackagesScreen extends StatefulWidget {
  const PricingPackagesScreen({super.key});

  @override
  State<PricingPackagesScreen> createState() => _PricingPackagesScreenState();
}

class _PricingPackagesScreenState extends State<PricingPackagesScreen> {
  bool isAnnual = false;
  int _stackIndex = 1;
  late WebViewController webViewController;
  String? token;
  bool isLoadingToken = true; // To handle initial token loading

  @override
  void initState() {
    super.initState();
    _getToken();
    Provider.of<VendorAuthProvider>(context, listen: false)
        .getMe(); // Fetch token on screen initialization
  }

  Future<void> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('userToken');
      isLoadingToken = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VendorAuthProvider>(context, listen: true);
    final webViewUrl =
        "${ApiUrls.webUrl}app-plan/${provider.myProfile!.data!.id}";
    print("WebView URL: $webViewUrl");
    // Display loading indicator while token is being fetched
    if (isLoadingToken) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: kSecondaryColor,
          ),
        ),
      );
    }

    return Scaffold(
      body: token == null
          ? SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Plan".tr,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Log in to select a plan!".tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Inter'.tr,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: TertiaryButton(
                          text: "Log in".tr,
                          press: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => SignInScreen()),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _stackIndex,
                    children: [
                      WebViewWidget(
                        controller: (webViewController = WebViewController()
                          ..setJavaScriptMode(JavaScriptMode.unrestricted)
                          ..setNavigationDelegate(
                            NavigationDelegate(
                              onPageFinished: (url) {
                                setState(() {
                                  _stackIndex = 0; // Hide loader
                                });
                              },
                            ),
                          )
                          ..loadRequest(Uri.parse(
                              "${ApiUrls.webUrl}app-plan/${provider.myProfile!.data!.id}"))),
                      ),
                      const Center(
                        child: CircularProgressIndicator(
                          color: kSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
