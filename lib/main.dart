import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moonbnd/Provider/space_provider.dart';
import 'package:moonbnd/Provider/flight_provider.dart';
import 'package:moonbnd/Provider/flight_vendor_provider.dart';
import 'package:moonbnd/Provider/hotel_provider.dart';
import 'package:moonbnd/Provider/singup_vendor_provider.dart';
import 'package:moonbnd/Provider/boat_provider.dart';
import 'package:moonbnd/Provider/event_provider.dart';
import 'package:moonbnd/Provider/vendor_boat_provider.dart';
import 'package:moonbnd/Provider/vendor_tour_provider.dart';
import 'package:moonbnd/Provider/search_hotel_provider.dart';
import 'package:moonbnd/language/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:moonbnd/screens/auth/splash_screen.dart';

import 'package:moonbnd/services/push-notification_service.dart';
import 'package:provider/provider.dart';
import 'package:moonbnd/Provider/auth_provider.dart';
import 'package:moonbnd/Provider/home_provider.dart';
import 'package:moonbnd/Provider/tour_provider.dart';
import 'package:moonbnd/constants.dart';
import 'package:moonbnd/language/localization.dart';
import 'package:moonbnd/screens/auth/signin_screen.dart';
import 'package:moonbnd/widgets/bottom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Register background message handler before runApp
  FirebaseMessaging.onBackgroundMessage(
      PushNotificationService.backgroundHandler);

  try {
    final RemoteMessage? remoteMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (remoteMessage != null) {
      // body = NotificationHelper.convertNotification(remoteMessage.data);
    }
    await PushNotificationService.initialize();
  } catch (_) {}
  await GetStorage.init();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  configLoading();
  Get.put(LanguageController());

  runApp(MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.hourGlass
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => HomeProvider()),
        ChangeNotifierProvider(create: (context) => VendorAuthProvider()),
        ChangeNotifierProvider(create: (context) => BoatProvider()),
        ChangeNotifierProvider(create: (context) => TourProvider()),
        ChangeNotifierProvider(create: (context) => EventProvider()),
        ChangeNotifierProvider(create: (context) => SpaceProvider()),
        ChangeNotifierProvider(create: (context) => VendorHotelProvider()),
        ChangeNotifierProvider(create: (context) => FlightProvider()),
        ChangeNotifierProvider(create: (context) => VendorFlightProvider()),
        ChangeNotifierProvider(create: (context) => SearchHotelProvider()),
        ChangeNotifierProvider(create: (context) => VendorTourProvider()),
        ChangeNotifierProvider(create: (context) => VendorBoatProvider()),
      ],
      child: GetMaterialApp(
        theme: havenTheme(),
        debugShowCheckedModeBanner: false,
        locale: Locale(GetStorage().read<String>('lang') ?? languagedefault),
        translations: LocaliztionApp(),
        fallbackLocale: Locale(languagedefault),
        home: NavigationScreen(),
        builder: EasyLoading.init(),
      ),
    );
  }
}

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<NavigationScreen> {
  void navigationPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("userToken");

    log("$token token");

    await Future.delayed(Duration(seconds: 2));

    if (token == null) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SplashScreen()));
    } else {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => BottomNav()));
    }
  }

  @override
  void initState() {
    super.initState();
    navigationPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            height: 150,
            width: 150,
            child: Image.asset('assets/haven/logo.png'),
          ),
        ),
      ),
    );
  }
}
