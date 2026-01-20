import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:todo_app/app.dart';
import 'package:todo_app/routes/app_router.dart';
import 'package:todo_app/utils/global.dart';

void main() async {
  // Set up error handling for unhandled exceptions
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // In release mode, send to crash reporting service
      // FirebaseCrashlytics.instance.recordFlutterError(details);
    }
  };

  // Handle errors from async operations outside of Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    // Log WebSocket errors but don't crash the app
    if (error.toString().contains('WebSocket') ||
        error.toString().contains('Connection timed out')) {
      print('Main: Caught WebSocket error: $error');
      print('Main: This is expected when server is unreachable');
      return true; // Prevent crash
    }
    return false; // Let other errors propagate
  };

  await dotenv.load(fileName: 'environment/.env');
  getIt.registerSingleton(AppRouter());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) => runApp(const App()));
}
