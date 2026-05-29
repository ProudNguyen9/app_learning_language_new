import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationTokenService {
  const NotificationTokenService._();

  static Future<void> saveCurrentFcmTokenToSupabase() async {
    final token = await FirebaseMessaging.instance.getToken();
    await saveFcmTokenToSupabase(token);
  }

  static Future<void> saveFcmTokenToSupabase(String? token) async {
    if (token == null || token.isEmpty) {
      return;
    }

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      debugPrint('Chưa đăng nhập nên chưa lưu FCM token lên Supabase');
      return;
    }

    try {
      await supabase.from('user_tokens').upsert({
        'user_id': user.id,
        'fcm_token': token,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (error) {
      debugPrint('Không thể lưu FCM token lên Supabase: $error');
    }
  }
}
