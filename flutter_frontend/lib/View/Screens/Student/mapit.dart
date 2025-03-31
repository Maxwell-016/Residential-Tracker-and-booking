import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../chartbot_fun/ai_funs.dart';
import '../../../src/locations.dart' as locations;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Map<String, Marker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    print("🔍 _onMapCreated triggered"); // Debugging

    final List<Map<String, dynamic>> toBeMarked = await getLocationsToBeMarked();

    setState(() {
      _markers.clear();
      for (final place in toBeMarked) {
        print("📍 Adding Marker: ${place["name"]} at ${place["lat"]}, ${place["lng"]}"); // Debugging

        final marker = Marker(
          markerId: MarkerId(place["id"].toString()),
          position: LatLng(place["lat"], place["lng"]),
          infoWindow: InfoWindow(
            title: place["name"],
            snippet: place["address"],
          ),
        );
        _markers[place["name"]] = marker;
      }
    });

    print("✅ Markers added: ${_markers.length}");
  }

  @override
  Widget build(BuildContext context) {

return ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child:
    GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(0.288879, 34.765982),
            zoom: 15,
          ),
          markers: _markers.values.toSet(),
       )

    );
  }
}