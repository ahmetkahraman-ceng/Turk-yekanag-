import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turkiye_kan_agi/app.dart';
import 'package:turkiye_kan_agi/core/config/app_environment.dart';
import 'package:turkiye_kan_agi/core/config/firebase_initializer.dart';
import 'package:turkiye_kan_agi/core/services/remote_config_service.dart';

/// Seçilen ortam (dev/prod) ile uygulamayı başlatır.
Future<void> bootstrap(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  final isFirebaseReady = await FirebaseInitializer.initialize(environment);

  final remoteConfigService = FirebaseRemoteConfigService(
    remoteConfig: isFirebaseReady ? FirebaseRemoteConfig.instance : null,
  );
  await remoteConfigService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(environment),
        remoteConfigServiceProvider.overrideWithValue(remoteConfigService),
      ],
      child: const TurkiyeKanAgiApp(),
    ),
  );
}
