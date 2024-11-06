import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> subscribeToTopic(String topicName) async {
    await _firebaseMessaging.subscribeToTopic(topicName);
    log("subscribed bro $topicName");
  }

  Future<void> initNotifications() async {
    log("asking for persmissions");
    await _firebaseMessaging.requestPermission();

    final hmm = await _firebaseMessaging.getNotificationSettings();
    log(hmm.authorizationStatus.toString());

    final fCMToken = await _firebaseMessaging.getToken();
    log('Token: $fCMToken');
  }

  Future<void> emergencyUpdate() async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('Routes').doc('Route_1');
    await docRef.update({
      'Emergency': true,
    });
  }
}
