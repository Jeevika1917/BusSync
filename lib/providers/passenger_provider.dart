import 'package:flutter/material.dart';
import '../models/stop_model.dart';
import '../models/bus_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../core/utils/freshness_utils.dart';

class PassengerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  List<StopModel> _stops = [];
  StopModel? _selectedStop;
  List<BusModel> _buses = [];

  bool _isLoadingStops = false;
  bool _isLoadingBuses = false;
  String? _stopsError;
  String? _busesError;

  List<StopModel> get stops => _stops;
  StopModel? get selectedStop => _selectedStop;
  List<BusModel> get buses => _buses;
  bool get isLoadingStops => _isLoadingStops;
  bool get isLoadingBuses => _isLoadingBuses;
  String? get stopsError => _stopsError;
  String? get busesError => _busesError;

  PassengerProvider() {
    _socketService.initSocket();
    _socketService.addBusUpdatedListener(_onBusUpdatedRealtime);
  }

  void _onBusUpdatedRealtime(BusModel updatedBus) {
    bool found = false;
    for (int i = 0; i < _buses.length; i++) {
      if (_buses[i].id == updatedBus.id) {
        _buses[i] = updatedBus;
        found = true;
        break;
      }
    }

    if (!found && _selectedStop != null) {
      bool servesSelectedStop = updatedBus.stops.any((s) => s.id == _selectedStop!.id);
      if (servesSelectedStop) {
        _buses.add(updatedBus);
      }
    }

    _applySorting();
    notifyListeners();
  }

  void _applySorting() {
    FreshnessUtils.sortBuses<BusModel>(
      buses: _buses,
      getAvailableSeats: (b) => b.availableSeats,
      getLastUpdated: (b) => b.lastUpdated,
    );
  }

  Future<void> fetchStops() async {
    _isLoadingStops = true;
    _stopsError = null;
    notifyListeners();

    try {
      _stops = await _apiService.fetchStops();
      _isLoadingStops = false;
      notifyListeners();
    } catch (e) {
      _isLoadingStops = false;
      _stopsError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void selectStop(StopModel? stop) {
    _selectedStop = stop;
    fetchBuses();
  }

  Future<void> fetchBuses() async {
    _isLoadingBuses = true;
    _busesError = null;
    notifyListeners();

    try {
      _buses = await _apiService.fetchBuses(stopId: _selectedStop?.id);
      _applySorting();
      _isLoadingBuses = false;
      notifyListeners();
    } catch (e) {
      _isLoadingBuses = false;
      _busesError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> reserveSeats(int busId, int seats) async {
    try {
      final updatedBus = await _apiService.reserveSeats(busId, seats);
      _onBusUpdatedRealtime(updatedBus);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _socketService.removeBusUpdatedListener(_onBusUpdatedRealtime);
    super.dispose();
  }
}
