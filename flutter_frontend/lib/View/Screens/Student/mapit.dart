import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Screens/Student/haoperlocation.dart';
import 'package:flutter_frontend/data/chart_provider.dart';
import 'package:flutter_frontend/pages/booked.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../chartbot_fun/ai_funs.dart';
import '../../../src/locations.dart' as locations;
import 'mapscreen.dart';

class MapScreen extends StatefulWidget {
  MapScreen({super.key, required this.locations});
  final Future<List<String>> locations;


  @override
  State<MapScreen> createState() => _MapScreenState();
}


class _MapScreenState extends State<MapScreen> {
  final Map<String, Marker> _markers = {};
  MapType _currentMapType = MapType.normal;
  final ChatService chatService = ChatService();


  Future<void> _onMapCreated(GoogleMapController controller) async {


    final List<Map<String, dynamic>> toBeMarked = await getLocationsToBeMarked(widget.locations);

    final Map<String, Marker> newMarkers = {};

    for (final place in toBeMarked) {
      int availableHouses = await AvailableHousesPerArea(place["name"].split(',')[0].toLowerCase());
      print("Available houses at ${place["name"]}: $availableHouses");

      final marker = Marker(
        markerId: MarkerId(place["id"].toString()),
        position: LatLng(place["lat"], place["lng"]),
        infoWindow: InfoWindow(
          title: place["name"],
          snippet:
          "${place["address"]}\nRegion: ${place["region"]}\nVacant Houses: $availableHouses",
          onTap: () {
            if (availableHouses > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AvailableHousesScreen(location: place["name"].split(',')[0].toLowerCase()),
                ),
              );
            }
          },
        ),
      );

      newMarkers[place["name"]] = marker;
    }

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });

    print("Markers added: ${_markers.length}");
  }






  Future<int> AvailableHousesPerArea(String Location) async {
    List<Map<String, dynamic>> houseNo=await chatService.getHousesByLocation(Location.toLowerCase());

    return houseNo.length;

  }





  void _changeMapType() {
    setState(() {

      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
          ? MapType.terrain
          : _currentMapType == MapType.terrain
          ? MapType.hybrid
          : MapType.normal;
      print(_currentMapType);
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
            mapType: MapType.hybrid,
          ),
        ),

        // Floating Button to Change Map Type
        // Positioned(
        //   bottom: 20,
        //   right: 20,
        //   child: FloatingActionButton(
        //     onPressed: _changeMapType,
        //     child: const Icon(Icons.map),
        //   ),
        // ),
      ],
    );
  }
}