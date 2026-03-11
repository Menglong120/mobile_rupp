import 'package:flutter/foundation.dart';

String get _devHost {
  if (kIsWeb) return '127.0.0.1';

  // Android emulator -> host machine localhost bridge.
  if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2';

  // Windows/macOS/Linux
  return '127.0.0.1';
}

String get serverBaseUrl => 'http://$_devHost:8000';

String get baseUrl => '$serverBaseUrl/api';
