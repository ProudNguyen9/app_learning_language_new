import 'package:apphoctienganh/app/app.dart';
import 'package:apphoctienganh/app/di/app_providers.dart';
import 'package:apphoctienganh/features/ai/data/adapters/ai_chat_message_adapter.dart';
import 'package:apphoctienganh/features/ai/data/adapters/ai_persona_adapter.dart';
import 'package:apphoctienganh/features/ai/domain/ai_chat_message.dart';
import 'package:apphoctienganh/features/ai/domain/ai_persona.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  await Supabase.initialize(
    url: 'https://diyhmixgrpdaboczqaps.supabase.co',
    anonKey: 'sb_publishable_9aDbamY-DGVB_1aV3RJXsA_MQ0zZAoM',
  );
  runApp(MultiProvider(providers: appProviders, child: const App()));
}
