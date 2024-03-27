import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_demo/constants/strings.dart';
import 'package:firebase_messaging_demo/service/notifications_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  /** If we are going to use further firebase services we need to
   * initialise the firebase setup
   */
  await _firebaseInitialisation();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _firebaseInitialisation();
  await NotificationService.init();
  runApp(const FirebaseMessagingDemo());
}

class FirebaseMessagingDemo extends StatelessWidget {
  const FirebaseMessagingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: appName,
      home: Scaffold(
        body: Center(
          child: Text('Flutter push notifications demo'),
        ),
      ),
    );
  }
}

Future<void> _firebaseInitialisation() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
