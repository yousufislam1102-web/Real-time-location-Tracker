import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineService {
  final List<LatLng> _polylineCoordinates = [];


  Set<Polyline> updatePolyline(LatLng newLatLng) {
    _polylineCoordinates.add(newLatLng);

    return {
      Polyline(
        polylineId: const PolylineId('tracking_polyline'),
        points: _polylineCoordinates,
        color: Colors.blue,
        width: 5,
      ),
    };
  }

  
}