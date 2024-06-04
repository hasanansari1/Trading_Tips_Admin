import 'dart:math';
import 'package:equitystar/Notifications/notfication_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      if(kDebugMode){
        print("Permission granted");
      }
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      if (kDebugMode) {
        print('Permission granted.');
      }
    }else{
      if(kDebugMode){
        print("Permission denied");
      }
    }

  }


  void initLocalNotifications(BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings
    );

    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      onDidReceiveNotificationResponse: (payload){
          handleMessage(context, message);
      }
    );
  }

  void firebaseInit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) {

      if (kDebugMode) {
        print(message.notification!.title.toString());
      }
      if (kDebugMode) {
        print(message.notification!.body.toString());
      }
      print(message.data.toString());
      print(message.data['type']);
      print(message.data['id']);

      initLocalNotifications(context, message);
      showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {

    AndroidNotificationChannel androidNotificationChannel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'High importance notification',
      importance: Importance.max
    );

    // AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    //     androidNotificationChannel.id.toString(),
    //     androidNotificationChannel.name.toString(),
    //     channelDescription: 'Channel Description!',
    //     importance: Importance.high,
    //     priority: Priority.high,
    //     ticker: 'ticker'
    //     // 'High importance notification',
    // );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      androidNotificationChannel.id.toString(),
      androidNotificationChannel.name.toString(),
      channelDescription: 'Channel Description!',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@mipmap/ic_launcher',
    );


    const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );


    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );


    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails
      );
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) async{
    if(message.data['type'] == 'msg'){
      Navigator.push(context, MaterialPageRoute(builder: (context) => Notifications(id: message.data['id'],)));
    }
  }

}