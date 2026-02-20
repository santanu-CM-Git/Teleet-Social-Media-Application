import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' hide Priority;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:untitled/common/managers/navigation.dart';
import 'package:untitled/common/managers/session_manager.dart';
import 'package:untitled/main.dart';
import 'package:untitled/screens/notification_screen/notification_screen.dart';
import 'package:untitled/screens/video_screen/video_call_screen.dart';
import 'package:untitled/utilities/const.dart';
import 'package:untitled/utilities/params.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// Initialize the audio player
final AudioPlayer _audioPlayer = AudioPlayer();

class FirebaseNotificationManager {
  static var shared = FirebaseNotificationManager();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _gotoCallingFunc(RemoteMessage message) async {
    // Log the received message data
    // print("Handling a Navigation: ${message.data}");
    if (message.data?['zego'] != null) {
      await WakelockPlus.enable();
    }

    // Extract data from the notification
    String? conversationId = message.data['roomId'];

    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString('roomId', conversationId ?? "");

    // Navigate to the GroupVideoCallScreen
    Navigate.to(
      GroupVideoCallScreen(conversationId: conversationId, forceJoin: false),
    );
  }

  void stopSound() async {
    await _audioPlayer.stop();
  }

  void _startPlay() async {
    if (_audioPlayer.state != PlayerState.playing) {
      await _audioPlayer.setVolume(1.0); // Set volume to maximum
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the audio
      await _audioPlayer
          .play(AssetSource('zego_incoming.mp3')); // Play the audio
    }

    // Stop the ringtone after 1 minute
    Future.delayed(const Duration(minutes: 1), () {
      _audioPlayer.stop();
    });
  }

  void _handleNotificationTap(NotificationResponse response) async {
    // print("response.payload ${response.payload}");

    // stopSound();
    await _audioPlayer.stop();

    if (response.actionId == 'accept_call') {
      // Handle "Accept" button tap
      String? conversationId = response.payload;
      Navigate.to(GroupVideoCallScreen(
        conversationId: conversationId,
        forceJoin: true,
      ));
    } else if (response.actionId == 'reject_call') {
      // Handle "Reject" button tap
      flutterLocalNotificationsPlugin.cancel(1); // Close the notification
    } else if (response.payload == "") {
      // Handle tapping on notification body
      Navigate.to(MyHomePage());
    }
  }

  Future<void> _firebaseMessagingNavigationHandler(
      RemoteMessage message) async {
    await WakelockPlus.enable();

    print("Handling a Navigation: ${message.data}");

    if (message.data['screen'] == "RoomsScreen") {
      // Navigate.to(const NotificationScreen());
      // print("Handling a Navigation: ${message.data}");
      // await _gotoCallingFunc(message);
      flutterLocalNotificationsPlugin.cancelAll();
      // Room room = Room();
      // var roomController = RoomController(room);
      // Navigate.to(ChattingView(room: roomController.room))
      //     ?.then(roomController.onBack);

      _startPlay();
    }
  }

  AndroidNotificationChannel channel = AndroidNotificationChannel(
      'teleet', // id
      'Teleet Notification', // title
      description: 'Incoming call notifications',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('zego_incoming'),
      enableLights: true,
      enableVibration: true,
      importance: Importance.max);

  FirebaseNotificationManager() {
    init();
  }

  String newMessageId = '';
  String newMessageIdV = '';

  void init() async {
    subscribeToTopic(notificationTopic);

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, sound: true);

    await firebaseMessaging.requestPermission(
        alert: true, badge: false, sound: true);

    var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    var initializationSettingsIOS = const DarwinInitializationSettings(
        defaultPresentAlert: true,
        defaultPresentSound: true,
        defaultPresentBadge: false);

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        _handleNotificationTap(notificationResponse);
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _firebaseMessagingNavigationHandler(message);
      if (message.data[Param.conversationId] ==
          SessionManager.shared.getStoredConversation()) {
        print('In Same Chat');
        return;
      }
      if (message.messageId != newMessageId || Platform.isAndroid) {
        newMessageId = message.messageId!;
        newMessageIdV = message.messageId ?? '';
        print('Notification: ${message.messageId}');

        if (message.data['screen'] != "RoomsScreen") {
          showNotification(message);
        }

        // if (SchedulerBinding.instance.lifecycleState !=
        //     AppLifecycleState.resumed) {
        //   // App is not in the foreground, show a local notification
        //   // showNotification(message);
        // }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle background or terminated notification
      _firebaseMessagingNavigationHandler(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingNavigationHandler);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    getNotificationToken(
      (token) {},
    );
  }

  void showNotification(RemoteMessage message)async  {
    await WakelockPlus.enable();
    flutterLocalNotificationsPlugin.show(
      1,
      message.data['title'],
      message.data['body'],
      NotificationDetails(
          iOS: const DarwinNotificationDetails(
              presentSound: true, presentAlert: true, presentBadge: false),
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            fullScreenIntent: true,
            sound: RawResourceAndroidNotificationSound('zego_incoming'),
            ongoing:
                true, // Prevents notification from being dismissed automatically
            actions: message.data['screen'] == "RoomsScreen"
                ? <AndroidNotificationAction>[
                    AndroidNotificationAction(
                      'accept_call', // Unique ID for "Accept" action
                      'Accept', // Button label
                      showsUserInterface: true,
                      cancelNotification:
                          true, // Don't cancel the notification when 'Accept' is pressed
                    ),
                    AndroidNotificationAction(
                      'reject_call', // Unique ID for "Reject" action
                      'Reject', // Button label
                      showsUserInterface: true,
                      cancelNotification:
                          true, // Don't cancel the notification when 'Reject' is pressed
                    ),
                  ]
                : [],
          )),
      payload: message.data['roomId'],
    );
  }

  void getNotificationToken(Function(String token) completion) {
    // if (Platform.isIOS) {
    //   FirebaseMessaging.instance.getAPNSToken().then((value) {
    //     print('Token form ios: ${value}');
    //     completion(value ?? 'No Token');
    //   });
    // }
    // else{
      FirebaseMessaging.instance.getToken().then((value) {
      print('Token for FCMMMMMM: ${value}');
      completion(value ?? 'No Token');
    });
    // }
  }

  void subscribeToTopic(String topic) async {
    var user = SessionManager.shared.getUser();
    if (user == null || user.isPushNotifications == 1) {
      await firebaseMessaging
          .subscribeToTopic('${topic}_${Platform.isIOS ? 'ios' : 'android'}')
          .onError((error, stackTrace) {
        print(error);
      });

      if (kDebugMode)
        await firebaseMessaging.subscribeToTopic(
            'test_${topic}_${Platform.isIOS ? 'ios' : 'android'}');
    }
  }

  void unsubscribeToTopic(String topic) async {
    await firebaseMessaging
        .unsubscribeFromTopic('${topic}_${Platform.isIOS ? 'ios' : 'android'}');

    if (kDebugMode)
      await firebaseMessaging.subscribeToTopic(
          'test_${topic}_${Platform.isIOS ? 'ios' : 'android'}');
  }

  void setupListener() async {
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        print("Notification Receive Success :: ${message.notification?.body}");
        Map<String, dynamic> body = message.data;
        String? conversationId = body[Param.conversationId];
        if (conversationId == SessionManager.shared.getStoredConversation()) {
          print("In same chat");
          return;
        }

        // showNotification(message);
      },
    );
  }
}
