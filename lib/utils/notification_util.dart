import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtil {
  void bannerListen(var context) {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        // print("onMessageOpenedApp: $message");
        // var title = message.notification?.title;
        // var body = message.notification?.body;
        // var category = message.data.values.toString();
        // var titleColor = const Color.fromARGB(188, 198, 198, 198);
        // print("category: $category");

        // if (category == "(emergency)") {
        //   titleColor = const Color(0xFFEF9A9A);
        // } else if (category == "(update)") {
        //   titleColor = const Color.fromARGB(188, 198, 198, 198);
        // }
        // showNotifDialog(title, body, context, titleColor);
      },
    );
  }

// check
/*
  Future<void> playSound(AudioPlayer player) async {
    print("func called");
    await player.play(AssetSource('audio/emergency.wav'));
    print("audio played");
  }
  */

  void showNotifDialog(var title, var body, var context, Color titleColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //Dialog box width
        insetPadding: const EdgeInsets.all(70),
        //padding on top of ok button
        actionsPadding: const EdgeInsets.only(top: 10),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
                color: titleColor,
              ),
              height: 50,
              width: double.infinity,
              child: Center(
                child: Text(
                  title,
                  textScaleFactor: 1.1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Text(
                body,
                textScaleFactor: 0.9,
              ),
            ),
          ],
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3))),
        actions: <Widget>[
          Center(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(188, 198, 198, 198),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(3),
                  ),
                ),
              ),
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class HelperNotification {
  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    const androidInitializationSettings =
        AndroidInitializationSettings("notification_icon");
    const iosInitializationSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(
      (event) => onForegroundMessageHandeler(
        event,
        flutterLocalNotificationsPlugin,
      ),
    );
  }

  static Future<void> onForegroundMessageHandeler(
    RemoteMessage remoteMessage,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    final title = remoteMessage.notification!.title.toString();
    final body = remoteMessage.notification!.body.toString();
    String category = "(update)";
    if (remoteMessage.data.values.isNotEmpty) {
      category = remoteMessage.data.values.toString();
    }

    if (category == "(update)") {
      showNormalBigNotification(
        id: 0,
        title: title,
        body: body,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      );
    } else {
      showEmergencyBigNotification(
        id: 0,
        title: title,
        body: body,
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
      );
    }
  }

  static Future onBackgroundMessageHandeler(
    RemoteMessage remoteMessage,
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    log(remoteMessage.data.toString());
    showNormalBigNotification(
      id: 0,
      title: "hello buddy",
      body: "mera naam hai don",
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    );
  }

  static Future<void> showEmergencyBigNotification({
    required int id,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      // channel id
      "vit_bus_tracking 2",
      // channel name set in android manifest xml,
      "vit_bus_tracking",
      playSound: true,
      channelDescription: "idk",
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.red,
      sound: RawResourceAndroidNotificationSound("alert"),
    );

    const notification = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(id, title, body, notification);
  }

  static Future<void> showNormalBigNotification({
    required int id,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      // channel id
      "vit_bus_tracking 3",
      // channel name set in android manifest xml,
      "vit_bus_tracking",
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.green,
      sound: RawResourceAndroidNotificationSound("update"),
      playSound: true,
    );

    const notification = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(id, title, body, notification);
  }
}
