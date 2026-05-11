import 'package:apphoctienganh/app/app.dart';
import 'package:apphoctienganh/app/di/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
