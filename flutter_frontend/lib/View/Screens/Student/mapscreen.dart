import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreenHouses extends StatefulWidget {
  final List<Map<String, dynamic>> houses;
  final String title;

  const MapScreenHouses({super.key, required this.title, required this.houses});

  @override
  State<MapScreenHouses> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreenHouses> {
  final Map<String, Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setMarkers();
  }

  void _setMarkers() {
    setState(() {
      _markers.clear();
      for (final house in widget.houses) {
        final marker = Marker(
          markerId: MarkerId(house["houseName"]),
          position: LatLng(house["lat"], house["long"]),
          infoWindow: InfoWindow(
            snippet:house["houseName"] ,
            title: house["location"],
            onTap: () {
              _showHouseDetails(house);
            },
          ),
        );
        _markers[house["houseName"]] = marker;
      }
    });
  }

  void _showHouseDetails(Map<String, dynamic> house) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Image.network(
                house["image"],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(house["houseName"], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Location: ${house["location"]}"),
                    Text("Latitude:  ${house["lat"]},Longitude:${house["long"]}"),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.houses[0]["lat"], widget.houses[0]["long"]),
          zoom: 14,
        ),
        markers: _markers.values.toSet(),
      ),
    );
  }
}
