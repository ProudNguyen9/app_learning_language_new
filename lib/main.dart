import 'package:apphoctienganh/app/app.dart';
import 'package:apphoctienganh/app/di/app_providers.dart';
import 'package:apphoctienganh/core/services/notification_token_service.dart';
import 'package:apphoctienganh/features/ai/data/adapters/ai_chat_message_adapter.dart';
import 'package:apphoctienganh/features/ai/data/adapters/ai_persona_adapter.dart';
import 'package:apphoctienganh/features/ai/domain/ai_chat_message.dart';
import 'package:apphoctienganh/features/ai/domain/ai_persona.dart';
import 'package:apphoctienganh/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      print('Firebase đã được khởi tạo rồi');
    } else {
      rethrow;
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await initFirebase();

  print('Nhận thông báo nền: ${message.notification?.title}');
}

Future<void> setupPushNotification() async {
  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('Trạng thái quyền: ${settings.authorizationStatus}');

  final token = await messaging.getToken();

  print('FCM TOKEN:');
  print(token);

  await NotificationTokenService.saveFcmTokenToSupabase(token);

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('FCM TOKEN REFRESH:');
    print(newToken);
    NotificationTokenService.saveFcmTokenToSupabase(newToken);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('App đang mở nhận thông báo');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');

    final notification = message.notification;
    if (notification != null) {
      showLocalNotification(
        title: notification.title ?? 'Thông báo',
        body: notification.body ?? '',
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('User click notification');
  });
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel androidNotificationChannel =
    AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Kênh thông báo ưu tiên cao',
      importance: Importance.high,
    );

Future<void> setupLocalNotification() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(settings: settings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(androidNotificationChannel);
}

Future<void> showLocalNotification({
  required String title,
  required String body,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'Kênh thông báo ưu tiên cao',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails details = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    id: 0,
    title: title,
    body: body,
    notificationDetails: details,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initFirebase();

  await Supabase.initialize(
    url: 'https://diyhmixgrpdaboczqaps.supabase.co',
    anonKey: 'sb_publishable_9aDbamY-DGVB_1aV3RJXsA_MQ0zZAoM',
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await setupLocalNotification();

  await setupPushNotification();

  await dotenv.load(fileName: '.env');

  await Hive.initFlutter();

  Hive.registerAdapter(AiPersonaAdapter());
  Hive.registerAdapter(AiChatMessageAdapter());

  await Hive.openBox<AiPersonal>('ai_personas');
  await Hive.openBox<AiChatMessage>('ai_chat_messages');

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );

  runApp(MultiProvider(providers: appProviders, child: const App()));
}
