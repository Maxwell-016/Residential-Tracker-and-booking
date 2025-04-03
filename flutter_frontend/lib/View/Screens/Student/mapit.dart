import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../chartbot_fun/ai_funs.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Map<String, Marker> _markers = {};
  MapType _currentMapType = MapType.normal; // Default map type

  Future<void> _onMapCreated(GoogleMapController controller) async {
    print("🔍 _onMapCreated triggered");

    final List<Map<String, dynamic>> toBeMarked =
        await getLocationsToBeMarked();

    setState(() {
      _markers.clear();
      for (final place in toBeMarked) {
        print(
            "📍 Adding Marker: ${place["name"]} at ${place["lat"]}, ${place["lng"]}");

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

    print("Markers added: ${_markers.length}");
  }

  void _changeMapType() {
    setState(() {
      // Cycle through different map types
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
              ? MapType.terrain
              : _currentMapType == MapType.terrain
                  ? MapType.hybrid
                  : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0.2927501026141882, 34.762192913490594),
              zoom: 14,
            ),
            markers: _markers.values.toSet(),
            mapType: _currentMapType, // Apply selected map type
          ),
        ),

        // Floating Button to Change Map Type
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _changeMapType,
            child: const Icon(Icons.map),
          ),
        ),
      ],
    );
  }
}
