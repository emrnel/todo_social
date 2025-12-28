// lib/core/api/api_constants.dart

import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConstants {
  // Railway Production Backend URL

  static const String _productionUrl =
      'https://todosocial-production.up.railway.app/api';

  // Local Development Backend

  static const String _localNetworkIp = '192.168.1.10'; // Bilgisayarının IP'si

  static const int _apiPort = 3000;

  /// Dinamik base URL resolver

  static String get baseUrl {
    // Always use Railway backend (production)
    return _productionUrl;

    /* Use local backend for testing:
    return 'http://localhost:$_apiPort/api';

    Dynamic backend selection:
    if (kReleaseMode) {
      return _productionUrl;
    }

    // Development/Debug mode: Lokal backend kullan
    if (kIsWeb) {
      return 'http://localhost:$_apiPort/api';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_apiPort/api';
    }

    return 'http://localhost:$_apiPort/api';
    */
  }

  /// Railway backend'i zorla kullan (test için)

  static String get productionUrl => _productionUrl;

  /// Lokal backend'i zorla kullan

  static String get localUrl => 'http://10.0.2.2:$_apiPort/api';
}
