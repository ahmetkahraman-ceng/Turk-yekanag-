import 'package:turkiye_kan_agi/bootstrap.dart';
import 'package:turkiye_kan_agi/core/config/app_environment.dart';

/// PROD ortamı giriş noktası (`flutter run -t lib/main_prod.dart --release`).
Future<void> main() async {
  await bootstrap(AppEnvironment.prod());
}
