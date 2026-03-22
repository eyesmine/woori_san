import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import '../core/api_client.dart';

class NotificationService {
  FirebaseMessaging? _messaging;
  final ApiClient? _apiClient;
  final GoRouter? _router;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool get _isFirebaseReady => _messaging != null;

  NotificationService({ApiClient? apiClient, GoRouter? router})
      : _apiClient = apiClient,
        _router = router;

  Future<void> initialize() async {
    try {
      _messaging = FirebaseMessaging.instance;
    } catch (e) {
      debugPrint('NotificationService: Firebase not initialized, skipping — $e');
      return;
    }

    // 로컬 알림 초기화
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: darwinSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    if (!_isFirebaseReady) return;

    // 알림 권한 요청
    await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // FCM 토큰 가져오기
    final token = await _messaging!.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    // 토큰 갱신 리스너
    _messaging!.onTokenRefresh.listen(_registerToken);

    // 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 백그라운드 탭 핸들러
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // 토픽 구독
    await _messaging!.subscribeToTopic('weather_alerts');
    await _messaging!.subscribeToTopic('hiking_tips');
  }

  Future<void> _registerToken(String token) async {
    try {
      await _apiClient?.post('/devices/', data: {'token': token});
    } catch (e) {
      debugPrint('NotificationService._registerToken error: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title ?? '우리산',
      notification.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'woori_san_channel',
          '우리산 알림',
          channelDescription: '등산 관련 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: message.data['route'],
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final route = response.payload;
    if (route != null && route.isNotEmpty) {
      _navigateTo(route);
    }
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route == null || route.isEmpty) return;
    _navigateTo(route);
  }

  void _navigateTo(String route) {
    if (_router == null) return;
    try {
      _router.go(route);
    } catch (e) {
      debugPrint('NotificationService._navigateTo error: $e');
    }
  }
}
