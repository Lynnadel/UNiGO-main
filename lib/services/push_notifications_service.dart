import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PushNotificationsService {
  PushNotificationsService._();
  static final PushNotificationsService instance = PushNotificationsService._();

  final _messaging = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final _local = FlutterLocalNotificationsPlugin();

  static const String channelId = 'unigo_push';
  static const String channelName = 'UniGO Notifications';

  String? _lastUid;
  String? _cachedToken;

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);
    await _local.initialize(settings);

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: 'UniGO push notifications',
            importance: Importance.high,
          ),
        );

    FirebaseMessaging.onMessage.listen((msg) async {
      final n = msg.notification;
      if (n == null) return;

      await _local.show(
        n.hashCode,
        n.title ?? 'UniGO',
        n.body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    });

    _messaging.onTokenRefresh.listen((newToken) async {
      final user = _auth.currentUser;

      final oldToken = _cachedToken;
      _cachedToken = newToken;

      if (user == null) return;

      if (oldToken != null && oldToken != newToken) {
        try {
          await _db
              .collection('users')
              .doc(user.uid)
              .collection('fcmTokens')
              .doc(oldToken)
              .delete();
        } catch (_) {}
      }

      await _registerTokenForUid(user.uid);
    });

    _auth.authStateChanges().listen((user) async {
      if (_lastUid != null && (_lastUid != user?.uid)) {
        await _unregisterTokenForUid(_lastUid!);
      }

      if (user == null) {
        _lastUid = null;
        return;
      }

      _lastUid = user.uid;
      await _registerTokenForUid(user.uid);
    });
  }

  Future<String?> _getToken() async {
    _cachedToken ??= await _messaging.getToken();
    return _cachedToken;
  }

  Future<void> _registerTokenForUid(String uid) async {
    final token = await _getToken();
    if (token == null) return;

    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token);

    await ref.set({
      'token': token,
      'platform': Platform.operatingSystem,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _unregisterTokenForUid(String uid) async {
    final token = await _getToken();
    if (token == null) return;

    final ref = _db
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token);

    try {
      await ref.delete();
    } catch (_) {}
  }
}
