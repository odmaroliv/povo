import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:povo/app/core/routes/app_routes.dart';
import 'package:povo/app/services/firebase_service.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notification channels
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'povo_notifications', // id
    'Povo Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  // Initialize service
  Future<NotificationService> init() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Handle FCM messages
    _setupFCMListeners();

    return this;
  }

  Future<void> _initializeLocalNotifications() async {
    // Initialize the plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        // Handle iOS foreground notification
      },
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        _handleNotificationTap(response.payload);
      },
    );

    // Create notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _setupFCMListeners() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');

        // Show local notification
        _showLocalNotification(
          id: message.hashCode,
          title: message.notification?.title ?? 'Povo',
          body: message.notification?.body ?? '',
          payload: message.data.toString(),
        );
      }
    });

    // Handle background/terminated messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _handleNotificationTap(message.data.toString());
    });

    // Check if the app was opened from a notification
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state via notification');
        _handleNotificationTap(message.data.toString());
      }
    });
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    final iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null) {
      print('Notification payload: $payload');

      // Parse the payload
      Map<String, dynamic> data = {};
      try {
        payload
            .replaceAll('{', '')
            .replaceAll('}', '')
            .split(',')
            .forEach((element) {
          final parts = element.split(':');
          if (parts.length == 2) {
            data[parts[0].trim()] = parts[1].trim();
          }
        });

        // Navigate based on notification type
        if (data.containsKey('type')) {
          switch (data['type']) {
            case 'new_event':
              if (data.containsKey('eventId')) {
                Get.toNamed(AppRoutes.EVENT_DETAILS,
                    arguments: data['eventId']);
              }
              break;
            case 'photo_approved':
              if (data.containsKey('eventId')) {
                Get.toNamed(AppRoutes.GALLERY, arguments: data['eventId']);
              }
              break;
            case 'event_invitation':
              if (data.containsKey('eventId')) {
                Get.toNamed(AppRoutes.JOIN_EVENT, arguments: data['eventId']);
              }
              break;
            default:
              Get.toNamed(AppRoutes.HOME);
          }
        }
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  // Subscribe to topics
  Future<void> subscribeToEvent(String eventId) async {
    await _messaging.subscribeToTopic('event_$eventId');
  }

  Future<void> unsubscribeFromEvent(String eventId) async {
    await _messaging.unsubscribeFromTopic('event_$eventId');
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }

  // Save FCM token to user profile
  Future<void> saveFCMToken(String userId) async {
    final token = await getFCMToken();

    if (token != null) {
      await Get.find<FirebaseService>().usersCollection.doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    }
  }
}

// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if necessary
  // For proper implementation, you need to initialize Firebase in this handler
  print('Handling a background message: ${message.messageId}');
}
