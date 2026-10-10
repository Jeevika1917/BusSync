import 'package:flutter/material.dart';
import '../models/bus_model.dart';
import '../models/stop_model.dart';
import '../models/parking_location_model.dart';
import '../services/api_service.dart';
import '../core/utils/freshness_utils.dart';

class DriverProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  BusModel? _assignedBus;
  ParkingLocationModel? _selectedParkingLocation;
  List<StopModel> _selectedStops = [];

  List<ParkingLocationModel> _parkingLocations = [];
  List<StopModel> _allStops = [];

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  BusModel? get assignedBus => _assignedBus;
  ParkingLocationModel? get selectedParkingLocation => _selectedParkingLocation;
  List<StopModel> get selectedStops => _selectedStops;
  List<ParkingLocationModel> get parkingLocations => _parkingLocations;
  List<StopModel> get allStops => _allStops;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> fetchDriverData(String authToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _parkingLocations = await _apiService.fetchParkingLocations();
      _allStops = await _apiService.fetchStops();

      _assignedBus = await _apiService.fetchDriverBus(authToken);
      if (_assignedBus != null) {
        _selectedStops = List.from(_assignedBus!.stops);

        if (_assignedBus!.parkingLocationId != null) {
          _selectedParkingLocation = _parkingLocations.firstWhere(
            (p) => p.id == _assignedBus!.parkingLocationId,
            orElse: () => _parkingLocations.first,
          );
        } else if (_parkingLocations.isNotEmpty) {
          _selectedParkingLocation = _parkingLocations.first;
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void setParkingLocation(ParkingLocationModel? location) {
    _selectedParkingLocation = location;
    notifyListeners();
  }

  void addStop(StopModel stop) {
    if (!_selectedStops.contains(stop)) {
      _selectedStops.add(stop);
      notifyListeners();
    }
  }

  void removeStop(StopModel stop) {
    _selectedStops.remove(stop);
    notifyListeners();
  }

  Future<bool> saveBusUpdate(String authToken) async {
    if (_assignedBus == null || _selectedParkingLocation == null) {
      _errorMessage = 'Bus and parking location are required';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updatedBus = await _apiService.updateDriverBus(
        authToken,
        parkingLocationId: _selectedParkingLocation!.id,
        stopIds: _selectedStops.map((s) => s.id).toList(),
      );

      _assignedBus = updatedBus;
      _selectedStops = List.from(updatedBus.stops);
      _isSaving = false;
      _successMessage = 'Bus information updated successfully!';
      notifyListeners();
      return true;
    } catch (e) {
      _isSaving = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
