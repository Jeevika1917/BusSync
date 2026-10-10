import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/stop_model.dart';
import '../models/parking_location_model.dart';
import '../models/bus_model.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'token': data['token'],
        'user': UserModel.fromJson(data['user']),
      };
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Login failed');
    }
  }

  Future<List<StopModel>> fetchStops() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.stops}');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => StopModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load bus stops');
    }
  }

  Future<List<ParkingLocationModel>> fetchParkingLocations() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.parkingLocations}');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => ParkingLocationModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load parking locations');
    }
  }

  Future<List<BusModel>> fetchBuses({int? stopId}) async {
    String uri = '${ApiConstants.baseUrl}${ApiConstants.buses}';
    if (stopId != null) {
      uri += '?stopId=$stopId';
    }
    final response = await _client.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((item) => BusModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load buses');
    }
  }

  Future<BusModel> fetchBusById(int busId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.buses}/$busId');
    final response = await _client.get(url);

    if (response.statusCode == 200) {
      return BusModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load bus details');
    }
  }

  Future<BusModel> fetchDriverBus(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.driverBus}');
    final response = await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return BusModel.fromJson(jsonDecode(response.body));
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Failed to load assigned bus');
    }
  }

  Future<BusModel> updateDriverBus(
    String token, {
    required int parkingLocationId,
    required List<int> stopIds,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.driverBus}');
    final response = await _client.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'parking_location_id': parkingLocationId,
        'stop_ids': stopIds,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return BusModel.fromJson(data['bus']);
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Failed to update bus information');
    }
  }

  Future<BusModel> reserveSeats(int busId, int seats) async {
    final url = Uri.parse(ApiConstants.busReservations(busId));
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'seats': seats}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return BusModel.fromJson(data['bus']);
    } else {
      throw Exception(data['message'] ?? data['error'] ?? 'Not enough seats available');
    }
  }

  Future<BusModel> adminCreateBus(String token, Map<String, dynamic> data) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.adminBuses}');
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return BusModel.fromJson(jsonDecode(response.body));
    } else {
      final err = jsonDecode(response.body);
      throw Exception(err['error'] ?? 'Failed to create bus');
    }
  }
}
