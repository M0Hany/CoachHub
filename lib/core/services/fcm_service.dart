import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'package:coachhub/core/services/token_service.dart';
import 'package:coachhub/core/network/http_client.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  FirebaseMessaging? _firebaseMessaging;
  // final FlutterLocalNotificationsPlugin _localNotifications = 
  //     FlutterLocalNotificationsPlugin();
  final TokenService _tokenService = TokenService();
  final HttpClient _httpClient = HttpClient();

  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  FirebaseMessaging get _messaging {
    _firebaseMessaging ??= FirebaseMessaging.instance;
    return _firebaseMessaging!;
  }

  Future<void> initialize() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Request permission for iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Get FCM token
    _fcmToken = await _messaging.getToken();
    print('FCM Token: $_fcmToken');

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      print('FCM Token refreshed: $_fcmToken');
      // Send new token to your backend
      _sendTokenToBackend(token);
    });

    // Initialize local notifications
    // await _initializeLocalNotifications();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  // Future<void> _initializeLocalNotifications() async {
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('@mipmap/ic_launcher');

  //   const DarwinInitializationSettings initializationSettingsIOS =
  //       DarwinInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestSoundPermission: true,
  //   );

  //   const InitializationSettings initializationSettings =
  //       InitializationSettings(
  //     android: initializationSettingsAndroid,
  //     iOS: initializationSettingsIOS,
  //   );

  //   await _localNotifications.initialize(
  //     initializationSettings,
  //     onDidReceiveNotificationResponse: _onNotificationTapped,
  //   );
  // }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      // _showLocalNotification(message);
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    print('Message data: ${message.data}');
    // Navigate to specific screen based on message data
    _handleNotificationNavigation(message.data);
  }

  // void _onNotificationTapped(NotificationResponse response) {
  //   print('Notification tapped: ${response.payload}');
  //   // Handle notification tap
  // }

  // Future<void> _showLocalNotification(RemoteMessage message) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'coachhub_channel',
  //     'CoachHub Notifications',
  //     channelDescription: 'Notifications from CoachHub app',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );

  //   const DarwinNotificationDetails iOSPlatformChannelSpecifics =
  //       DarwinNotificationDetails();

  //   const NotificationDetails platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //     iOS: iOSPlatformChannelSpecifics,
  //   );

  //   await _localNotifications.show(
  //     message.hashCode,
  //     message.notification?.title,
  //     message.notification?.body,
  //     platformChannelSpecifics,
  //     payload: json.encode(message.data),
  //   );
  // }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Navigate to specific screen based on notification data
    // Example: if (data['screen'] == 'chat') { navigate to chat }
    print('Handling notification navigation with data: $data');
  }

  Future<void> _sendTokenToBackend(String token) async {
    print('🔄 FCM: _sendTokenToBackend() called with token: ${token.substring(0, 20)}...');
    try {
      print('🚀 FCM: Making HTTP request to backend...');

      final response = await _httpClient.post(
        '/api/auth/FCM-token',
        data: {'token': token},
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      print('📡 FCM: HTTP response received: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('✅ FCM: Token successfully sent to backend');
      } else {
        print('❌ FCM: Failed to send token to backend: ${response.statusCode}');
        print('📄 FCM: Response: ${response.data}');
      }
    } catch (e) {
      print('❌ FCM: Error sending token to backend: $e');
      if (e is DioException) {
        print('🔍 FCM: Dio error type: ${e.type}');
        print('🔍 FCM: Dio error response: ${e.response?.data}');
        print('🔍 FCM: Dio error status: ${e.response?.statusCode}');
      }
    }
  }

  Future<void> sendTokenToBackend() async {
    print('🔄 FCM: sendTokenToBackend() called');
    
    // If FCM token is not available, try to get it first
    if (_fcmToken == null) {
      print('🔄 FCM: Token is null, trying to get it...');
      try {
        _fcmToken = await _messaging.getToken();
        print('✅ FCM: Retrieved FCM token for backend: $_fcmToken');
      } catch (e) {
        print('❌ FCM: Error getting FCM token: $e');
        return;
      }
    } else {
      print('✅ FCM: Using existing token: $_fcmToken');
    }
    
    if (_fcmToken != null) {
      print('🚀 FCM: Sending token to backend...');
      await _sendTokenToBackend(_fcmToken!);
    } else {
      print('❌ FCM: FCM token is still not available');
    }
  }

  /// Force refresh and send FCM token to backend
  Future<void> refreshAndSendToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      print('Refreshed FCM token: $_fcmToken');
      if (_fcmToken != null) {
        await _sendTokenToBackend(_fcmToken!);
      }
    } catch (e) {
      print('Error refreshing FCM token: $e');
    }
  }

  /// Get current FCM token (for debugging/testing)
  String? getCurrentToken() {
    return _fcmToken;
  }

  /// Check if FCM is properly initialized
  bool get isInitialized => _firebaseMessaging != null;

  /// Test method to manually trigger FCM token sending
  Future<void> testSendTokenToBackend() async {
    print('🧪 FCM: Test method called');
    await sendTokenToBackend();
  }
}

// Top-level function for background message handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
} 