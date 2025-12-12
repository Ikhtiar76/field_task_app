// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:field_task_app/core/constants/colors.dart';
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
  final double? distanceInMeters;

  const ReusableMap({
    super.key,
    required this.mode,
    this.initialLocation,
    this.radius = 100,
    this.onPick,
    this.distanceInMeters,
  });

  @override
  State<ReusableMap> createState() => _ReusableMapState();
}

class _ReusableMapState extends State<ReusableMap> with WidgetsBindingObserver {
  final MapController _mapController = MapController();

  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  double _currentZoom = 14.7;
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
          backgroundColor: white,
          title: const Text('Enable Location'),
          content: const Text(
            'Location services are disabled. Please enable GPS to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: black)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openLocationSettings();
              },
              child: const Text(
                'Open Settings',
                style: TextStyle(color: black),
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
      return Container(
        height: screenHeight * 0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: grey.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(screenHeight * 0.05),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: grey.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text('Getting your location...'),
              ],
            ),
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
        border: Border.all(color: grey.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.1),
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
                    borderColor: widget.mode == MapMode.picker
                        ? Colors.blue
                        : (widget.distanceInMeters != null &&
                              widget.distanceInMeters! <= 100)
                        ? Colors.green
                        : red,
                    borderStrokeWidth: 2,
                    color: widget.mode == MapMode.picker
                        ? Colors.blue.withOpacity(0.15)
                        : (widget.distanceInMeters != null &&
                              widget.distanceInMeters! <= 100)
                        ? Colors.green.withOpacity(0.15)
                        : red.withOpacity(0.15),
                  ),
                ],
              ),
            if (widget.mode == MapMode.viewer &&
                _currentLocation != null &&
                _selectedLocation != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_currentLocation!, _selectedLocation!],
                    color: Colors.blueAccent,
                    strokeWidth: 2,
                    pattern: StrokePattern.dotted(),
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
                    child: const Icon(Icons.location_on, color: red, size: 25),
                  ),
                  if (widget.mode == MapMode.viewer)
                    Marker(
                      point: _currentLocation!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: black.withOpacity(0.25),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: white, width: 2),
                        ),
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
