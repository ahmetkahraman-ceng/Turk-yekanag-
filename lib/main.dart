import 'package:turkiye_kan_agi/bootstrap.dart';
import 'package:turkiye_kan_agi/core/config/app_environment.dart';

/// Varsayılan giriş noktası (APP_ENV=prod verilmezse DEV ortamında başlar).
Future<void> main() async {
  const envName = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  final environment =
      envName == 'prod' ? AppEnvironment.prod() : AppEnvironment.dev();
  await bootstrap(environment);
}
