import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../core/constants/api_constants.dart';
import '../models/bus_model.dart';

class SocketService {
  IO.Socket? _socket;
  final List<void Function(BusModel bus)> _busUpdatedListeners = [];

  void initSocket() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      ApiConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      debugPrint('Socket.IO Connected to ${ApiConstants.socketUrl}');
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket.IO Disconnected');
    });

    _socket!.on('bus_updated', (data) {
      if (data != null && data is Map<String, dynamic>) {
        try {
          final bus = BusModel.fromJson(data);
          for (var listener in _busUpdatedListeners) {
            listener(bus);
          }
        } catch (e) {
          debugPrint('Error parsing socket bus_updated event: $e');
        }
      }
    });

    _socket!.connect();
  }

  void addBusUpdatedListener(void Function(BusModel bus) listener) {
    if (!_busUpdatedListeners.contains(listener)) {
      _busUpdatedListeners.add(listener);
    }
  }

  void removeBusUpdatedListener(void Function(BusModel bus) listener) {
    _busUpdatedListeners.remove(listener);
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _busUpdatedListeners.clear();
  }
}
