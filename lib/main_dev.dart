import 'package:turkiye_kan_agi/bootstrap.dart';
import 'package:turkiye_kan_agi/core/config/app_environment.dart';

/// DEV ortamı giriş noktası (`flutter run -t lib/main_dev.dart`).
Future<void> main() async {
  await bootstrap(AppEnvironment.dev());
}
