import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class LoggerService {
  /*
   * Logger Service to handle logging and error reporting.
   * - In DEBUG mode: Logs to console.
   * - In RELEASE mode: Logs to Firebase Crashlytics.
   */

  static final LoggerService _instance = LoggerService._internal();

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  /// Log a regular message (info level)
  void log(String message) {
    if (kDebugMode) {
      debugPrint('[INFO] $message');
    } else if (!kIsWeb) {
      FirebaseCrashlytics.instance.log(message);
    }
  }

  /// Log an error/exception
  Future<void> recordError(dynamic exception, StackTrace? stack, {String? reason, bool fatal = false}) async {
    if (kDebugMode) {
      debugPrint('[ERROR] $exception');
      if (reason != null) debugPrint('[REASON] $reason');
      if (stack != null) debugPrintStack(stackTrace: stack);
    } else if (!kIsWeb) {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        reason: reason,
        fatal: fatal,
      );
    }
  }

  /// Sets custom keys for the current session (e.g. user ID)
  Future<void> setUserIdentifier(String identifier) async {
    if (!kDebugMode && !kIsWeb) {
      await FirebaseCrashlytics.instance.setUserIdentifier(identifier);
    }
  }
}
