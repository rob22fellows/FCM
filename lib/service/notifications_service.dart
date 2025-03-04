import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  ///single instance of FCM
  static final FirebaseMessaging messaging = FirebaseMessaging.instance;

  ///To store the FCM token
  static String? _token;

  ///notification plugin initialisation
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  ///notification channel to handle android notifications
  static const AndroidNotificationChannel _androidNotificationChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  ///notification channel to handle iOS notifications
  static const DarwinNotificationDetails _iOSNotificationChannel =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  ///ask permission from the user to display notifications
  static void _requestPermission() async {
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      /// User has granted the notification permission
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      /// User has only granted the provisional permission
    } else {
      /// User has discarded the permission popup or denied the notification permission
    }
  }

  ///setup the FCM token to receive notifications
  static void _getFCMToken() async {
    _token = await messaging.getToken();

    ///onTokenRefresh stream allows us to listen to the token value whenever it changes
    messaging.onTokenRefresh.listen((newValue) {
      _token = newValue;
    });

    debugPrint('FCM Token: $_token');
    }

  static void _configureLocalNotificationPlugin() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      ),
      onDidReceiveNotificationResponse: (response) {},
    );

    /** Update the iOS foreground notification presentation options to allow
     heads up notifications. */
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void _createAndroidNotificationChannel() async {
    /** we have created the android notification channel which
      we had specified in the AndroidManifest.xml file earlier */
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidNotificationChannel);
  }

  static void _showForegroundNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidNotificationChannel.id,
            _androidNotificationChannel.name,
            channelDescription: _androidNotificationChannel.description,
            icon: 'launch_background',
          ),
          iOS: _iOSNotificationChannel,
        ),
      );
    }
  }

  static void _handleBackgroundNotificationOnTap(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      debugPrint('Notification clicked: ${notification.title}');
    }
  }

  static Future<void> init() async {
    _requestPermission();
    _getFCMToken();
    _configureLocalNotificationPlugin();
    _createAndroidNotificationChannel();

    /// Foreground notification handler
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    /// Background notification handler
    FirebaseMessaging.onMessageOpenedApp
        .listen(_handleBackgroundNotificationOnTap);
  }
}
