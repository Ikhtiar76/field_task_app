// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum MapMode { picker, viewer }

class ReusableMap extends StatefulWidget {
  final MapMode mode;
  final LatLng? initialLocation;
  final double radius;
  final Function(LatLng?)? onPick;

  const ReusableMap({
    super.key,
    required this.mode,
    this.initialLocation,
    this.radius = 100,
    this.onPick,
  });

  @override
  State<ReusableMap> createState() => _ReusableMapState();
}

class _ReusableMapState extends State<ReusableMap> with WidgetsBindingObserver {
  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  double _currentZoom = 15;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _determinePosition();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _determinePosition();
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Enable Location'),
          content: const Text(
            'Location services are disabled. Please enable GPS to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openLocationSettings();
              },
              child: const Text(
                'Open Settings',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);

      _selectedLocation = widget.initialLocation ?? _currentLocation;

      _loading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedLocation != null) {
        _mapController.move(_selectedLocation!, _currentZoom);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (_loading || _currentLocation == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(screenHeight * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.grey.shade500),
              const SizedBox(height: 16),
              const Text('Getting your location...'),
            ],
          ),
        ),
      );
    }

    return _buildMap(context);
  }

  Widget _buildMap(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedLocation!,
            initialZoom: _currentZoom,
            minZoom: 5,
            maxZoom: 20,
            onPositionChanged: (pos, _) {
              _currentZoom = pos.zoom;
            },

            onTap: widget.mode == MapMode.picker
                ? (tapPos, point) {
                    setState(() => _selectedLocation = point);
                    widget.onPick?.call(point);
                  }
                : null,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
              userAgentPackageName: 'com.example.field_task_app',
              maxNativeZoom: 20,
            ),

            if (_selectedLocation != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _selectedLocation!,
                    radius: widget.radius,
                    useRadiusInMeter: true,
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                    color: Colors.blue.withOpacity(0.15),
                  ),
                ],
              ),
            if (_selectedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation!,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
