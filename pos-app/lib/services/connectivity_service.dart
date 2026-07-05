import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum SyncStatus { online, offline, pendingSync }

class ConnectivityService {
  final _conn = Connectivity();
  final _ctrl = StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get stream => _ctrl.stream;

  ConnectivityService() {
    _conn.onConnectivityChanged.listen((res) {
      final isOnline = res.any((r) => r != ConnectivityResult.none);
      _ctrl.add(isOnline ? SyncStatus.online : SyncStatus.offline);
    });
  }

  Future<SyncStatus> currentStatus() async {
    final res = await _conn.checkConnectivity();
    final isOnline = res.any((r) => r != ConnectivityResult.none);
    return isOnline ? SyncStatus.online : SyncStatus.offline;
  }

  void dispose() => _ctrl.close();
}
