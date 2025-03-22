import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMaps extends StatefulWidget {
  const GoogleMaps({super.key});

  @override
  State<GoogleMaps> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  late GoogleMapController mapController;
  final List<Marker> _markers = [];
  bool showMaps = true;
  @override
  void initState() {
    super.initState();
    _markers.add(Marker(
      markerId: MarkerId('Location'),
      position: LatLng(695014.22832226, 31429.648590579),
    ));

    if (_markers.isNotEmpty) {
      setState(() {
        showMaps = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: showMaps?  Container(
        height: 300,
        width: 1200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12)
        ),
        child: GoogleMap(
          onMapCreated: (controller){
            setState(() {
              mapController = controller;
            });
          },
          markers: Set.of(_markers),
          mapType: MapType.terrain,
          initialCameraPosition: CameraPosition(target: LatLng(695014.22832226, 31429.648590579),zoom: 13),

        ),
      )  :CircularProgressIndicator(),
    );
  }
}
