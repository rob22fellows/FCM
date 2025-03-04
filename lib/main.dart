import 'package:firebase_messaging/firebase_messaging.dart';
import 'service/notifications_service.dart';
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

class FirebaseMessagingDemo extends StatefulWidget {
  const FirebaseMessagingDemo({super.key});

  @override
  _FirebaseMessagingDemoState createState() => _FirebaseMessagingDemoState();
}

class _FirebaseMessagingDemoState extends State<FirebaseMessagingDemo> {
  String _token = 'Fetching token...';

  @override
  void initState() {
    super.initState();
    _getFCMToken();
  }

  void _getFCMToken() {
    NotificationService.messaging.getToken().then((token) {
      setState(() {
        _token = token ?? 'Failed to get token';
      });
    });

    NotificationService.messaging.onTokenRefresh.listen((newValue) {
      setState(() {
        _token = newValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoatMonitor32',
      home: Scaffold(
        body: Center(
          child: Text('FCM Token: $_token'),
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
