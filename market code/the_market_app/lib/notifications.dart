import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print(message.notification?.title);
}

// class Notifications {
//   final _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> initNotifications() async {
//     await _firebaseMessaging.requestPermission();
//     final fcmToken = await _firebaseMessaging.getToken();
//     // print(fcmToken);
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
//   }
// }
