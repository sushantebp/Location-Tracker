import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_tracker/services/gelocator_service.dart';

class GeolocatorNotifier extends ChangeNotifier {
  final GelocatorService _gelocatorService;

  GeolocatorNotifier(this._gelocatorService);

  Position? _currentPosition;
  StreamSubscription<Position>? _subscription;
  bool _isLoading = false;
  Object? _error;

  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  Object? get error => _error;
  bool get hasPermission =>
      _currentPosition != null ||
      (_error != null && _error.toString().contains("denied"));

  Future<void> loadLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPosition = await _gelocatorService.determinePosition();
    } catch (e) {
      _error = e;
      _currentPosition = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startListening() async {
    await loadLocation();
    // if permission not granted
    if (_currentPosition == null) return;
    // if no subscription
    if (_subscription != null) return;

    _subscription = _gelocatorService.positionStream.listen(
      (position) {
        _currentPosition = position;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = error;
        notifyListeners();
      },
      onDone: () {
        _subscription = null;
      },
    );
  }

  Future<void> refreshAfterSettings() async {
    _subscription?.cancel();
    _subscription = null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPosition = await _gelocatorService.determinePosition();
      startListening();
    } catch (e) {
      _error = e;
      _currentPosition = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
