import 'package:flutter/foundation.dart';

// If you run on a real device, set this to your PC's LAN IP (example: "192.168.1.10").
// Leave empty to use platform defaults.
const String manualDevHost = '10.10.10.203';

String get _devHost {
  if (manualDevHost.isNotEmpty) return manualDevHost;
  if (kIsWeb) return '127.0.0.1';

  // Android emulator -> host machine
  if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2';

  // Windows/macOS/Linux/iOS simulator
  return '127.0.0.1';
}

String get serverBaseUrl => 'http://$_devHost:8000';

String get baseUrl => '$serverBaseUrl/api';
