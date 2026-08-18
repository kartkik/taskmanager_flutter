import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  ConnectivityService() {
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Could not check connectivity status: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool online = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn);

    if (_isOnline != online) {
      _isOnline = online;
      _connectionStatusController.add(_isOnline);
      debugPrint('Connectivity changed: ${online ? "ONLINE" : "OFFLINE"}');
    }
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
