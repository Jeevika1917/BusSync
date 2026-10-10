import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web/Desktop
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static String get socketUrl => baseUrl;

  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';
  static const String stops = '/api/stops';
  static const String parkingLocations = '/api/parking-locations';
  static const String buses = '/api/buses';
  static const String driverBus = '/api/driver/bus';
  static const String adminBuses = '/api/admin/buses';

  static String busReservations(int busId) => '$baseUrl/api/buses/$busId/reservations';
}
