import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_tracker/notifiers/geolocator_notifier.dart';
import 'package:location_tracker/services/gelocator_service.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen>
    with WidgetsBindingObserver {
  late final GeolocatorNotifier _geoNotifier;

  bool _openedSettings = false;

  @override
  void initState() {
    super.initState();
    _geoNotifier = GeolocatorNotifier(GelocatorService());
    _geoNotifier.startListening();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _openedSettings) {
      _openedSettings = false;
      _geoNotifier.refreshAfterSettings();
    }
  }

  @override
  void dispose() {
    _geoNotifier.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _geoNotifier,
        builder: (context, child) {
          if (_geoNotifier.isLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (_geoNotifier.error != null) {
            final errStr = _geoNotifier.error.toString();
            if (errStr.contains("deniedForever") ||
                errStr.contains("permanently")) {
              return Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    bool opened = await Geolocator.openLocationSettings();
                    _openedSettings = true;
                    if (!context.mounted) return;
                    if (!opened) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Could not open app settings"),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text("Open App Settings"),
                ),
              );
            } else if (errStr.contains("denied")) {
              return Center(
                child: ElevatedButton.icon(
                  onPressed: () => _geoNotifier.loadLocation(),
                  icon: const Icon(Icons.location_city),
                  label: const Text("Grant Permission"),
                ),
              );
            } else {
              return Center(child: Text("Error: $errStr"));
            }
          }

          final pos = _geoNotifier.currentPosition;
          if (pos != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Latitude : ${pos.latitude}'),
                  Text('Longitude : ${pos.longitude}'),
                ],
              ),
            );
          }

          return const Center(child: Text("Fetching location..."));
        },
      ),
    );
  }
}
