// lib/constants/api_constants.dart

import 'dart:io' show Platform; // Import Platform for checking Android/iOS
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb for checking web platform

class ApiConstants {
  // IMPORTANT: Adjust these URLs based on your backend's actual location
  // and the device/emulator you are using for development.

  static String get BASE_URL {
    if (kIsWeb) {
      // Running on web (Chrome, Edge, etc.)
      // 'localhost' refers to the machine running the browser
      return 'http://localhost:8080/api';
    } else if (Platform.isAndroid) {
      // Running on Android emulator
      // '10.0.2.2' is the special IP address to access the host machine's localhost
      return 'http://10.0.2.2:8080/api';
    } else if (Platform.isIOS) {
      // Running on iOS simulator
      // 'localhost' or '127.0.0.1' refers to the host machine's localhost
      return 'http://localhost:8080/api';
    } else {
      // For physical devices or other platforms, you might need your host machine's actual IP
      // Example: return 'http://192.168.1.5:8080/api';
      // Or, for a deployed backend: return 'https://your-backend-domain.com/api';
      return 'http://localhost:8080/api'; // Default or fallback
    }
  }
}
