import 'package:firebase_messaging/firebase_messaging.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  print('Background message received: ${message.messageId}');
}

class PushNotificationService {
  static FirebaseMessaging? _messaging;

  static Future<void> Function(RemoteMessage) get backgroundHandler =>
      _firebaseMessagingBackgroundHandler;

  static Future<void> initialize() async {
    _messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    } else {
      print('User declined or has not accepted notification permission');
    }

    String? token = await _messaging!.getToken();
    print('FCM Token: $token');

    _messaging!.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.messageId}');
    
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped: ${message.messageId}');
      // Handle notification tap here
    });
  }
}
