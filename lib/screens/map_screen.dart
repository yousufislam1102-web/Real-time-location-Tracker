import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/polyline_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final PolylineService _polylineService = PolylineService();

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 15,
  );

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    bool hasPermission = await _locationService.checkAndRequestPermission();
    if (!hasPermission) return;


    Position? initialPosition = await _locationService.getCurrentPosition();
    if (initialPosition != null) {
      _handleNewLocation(initialPosition);
    }


    _locationService.startPeriodicTracking(
      onLocationUpdate: (Position position) {
        _handleNewLocation(position);
      },
    );
  }

  void _handleNewLocation(Position position) {
    LatLng newLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('current_location_marker'),
          position: newLatLng,
          infoWindow: InfoWindow(
            title: 'My current location',
            snippet: 'Lat: ${newLatLng.latitude.toStringAsFixed(4)}, Lng: ${newLatLng.longitude.toStringAsFixed(4)}',
          ),
        ),
      };

      _polylines = _polylineService.updatePolyline(newLatLng);
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: newLatLng, zoom: 17.0),
      ),
    );
  }

  @override
  void dispose() {
    _locationService.stopTracking();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time Location Tracker')),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}