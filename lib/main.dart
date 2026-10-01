import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  await NotificationService.instance.init();
  final storage = await StorageService.create();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(storage),
      child: const CadenceApp(),
    ),
  );
}
