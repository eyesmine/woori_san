import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import '../core/api_client.dart';
import '../core/logger.dart';

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
      AppLogger.info('Firebase 미초기화, 알림 스킵', tag: 'Notification');
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

    // FCM 토큰 가져오기 (iOS는 APNS 토큰 준비 대기 필요)
    try {
      if (Platform.isIOS) {
        final apnsToken = await _messaging!.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 3));
        }
      }
      final token = await _messaging!.getToken();
      if (token != null) {
        await _registerToken(token);
      }
    } catch (e) {
      AppLogger.warning('FCM 토큰 가져오기 실패', tag: 'Notification', error: e);
    }

    // 토큰 갱신 리스너
    _messaging!.onTokenRefresh.listen(_registerToken);

    // 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 백그라운드 탭 핸들러
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // 토픽 구독 (iOS: APNS 토큰 미준비 시 실패 가능)
    try {
      await _messaging!.subscribeToTopic('weather_alerts');
      await _messaging!.subscribeToTopic('hiking_tips');
    } catch (e) {
      AppLogger.warning('토픽 구독 실패', tag: 'Notification', error: e);
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await _apiClient?.post('/devices/', data: {'token': token});
    } catch (e) {
      AppLogger.warning('FCM 토큰 등록 실패', tag: 'Notification', error: e);
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
      AppLogger.warning('알림 네비게이션 실패', tag: 'Notification', error: e);
    }
  }
}
