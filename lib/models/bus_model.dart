import '../core/utils/freshness_utils.dart';
import 'stop_model.dart';

class BusModel {
  final int id;
  final String busNumber;
  final int capacity;
  final int studentsBoarded;
  final int reservedSeats;
  final int availableSeats;
  final DateTime lastUpdated;
  final int? driverId;
  final String? driverName;
  final int? parkingLocationId;
  final String parkingLocation;
  final List<StopModel> stops;

  BusModel({
    required this.id,
    required this.busNumber,
    required this.capacity,
    required this.studentsBoarded,
    required this.reservedSeats,
    required this.availableSeats,
    required this.lastUpdated,
    this.driverId,
    this.driverName,
    this.parkingLocationId,
    required this.parkingLocation,
    required this.stops,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    final cap = json['capacity'] is int ? json['capacity'] : int.parse(json['capacity'].toString());
    final reserved = json['reserved_seats'] != null
        ? (json['reserved_seats'] is int ? json['reserved_seats'] : int.parse(json['reserved_seats'].toString()))
        : 0;
    final avail = json['available_seats'] != null
        ? (json['available_seats'] is int ? json['available_seats'] : int.parse(json['available_seats'].toString()))
        : (cap - reserved);
    final boarded = json['students_boarded'] != null
        ? (json['students_boarded'] is int ? json['students_boarded'] : int.parse(json['students_boarded'].toString()))
        : 0;

    DateTime parsedDate;
    if (json['last_updated'] != null) {
      try {
        parsedDate = DateTime.parse(json['last_updated'].toString()).toLocal();
      } catch (_) {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    List<StopModel> parsedStops = [];
    if (json['stops'] != null && json['stops'] is List) {
      parsedStops = (json['stops'] as List)
          .map((s) => StopModel.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    return BusModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      busNumber: json['bus_number'] ?? '',
      capacity: cap,
      studentsBoarded: boarded,
      reservedSeats: reserved,
      availableSeats: avail < 0 ? 0 : avail,
      lastUpdated: parsedDate,
      driverId: json['driver_id'] != null ? (json['driver_id'] is int ? json['driver_id'] : int.parse(json['driver_id'].toString())) : null,
      driverName: json['driver_name'],
      parkingLocationId: json['parking_location_id'] != null ? (json['parking_location_id'] is int ? json['parking_location_id'] : int.parse(json['parking_location_id'].toString())) : null,
      parkingLocation: json['parking_location'] ?? 'Not Specified',
      stops: parsedStops,
    );
  }

  FreshnessState get freshnessState => FreshnessUtils.getFreshnessState(lastUpdated);
  BusStatus get busStatus {
    if (availableSeats == 0) return BusStatus.full;
    if (availableSeats <= 5) return BusStatus.almostFull;
    return BusStatus.available;
  }
  String get formattedTimeAgo => FreshnessUtils.formatTimeAgo(lastUpdated);
  bool get isStale => freshnessState == FreshnessState.stale;
  bool get isFull => availableSeats == 0;
}
