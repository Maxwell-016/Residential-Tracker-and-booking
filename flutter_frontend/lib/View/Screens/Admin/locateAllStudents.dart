import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../Components/admin_side_nav.dart';



class AllBookedHouses extends StatefulWidget {
  final List<Map<String, dynamic>> houses;
  final String title;

  const AllBookedHouses({super.key, required this.title, required this.houses});

  @override
  State<AllBookedHouses> createState() => _MapScreenState();
}

class _MapScreenState extends State<AllBookedHouses> {
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
            snippet:house["location"] ,
            title: house["name"],
            onTap: () {
                // _showHouseDetails(house);

              _showHouseDetails({"houseName": house["houseName"], "name": house['name'], "email": house['email'], "image":  house["image"], "location":house["location"]});

            },
          ),
        );
        _markers[house["houseName"]] = marker;
      }
    });
  }
//[{"houseName": houseName, "lat": data['lat'], "long": data['long'], "image":  images[0], "location": location}]
  void _showHouseDetails(Map<String, dynamic> house) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 450,
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name : $house['name']", ),
                    Text("Email : $house['email']", ),
                    // Text("Student Phone Number : $house['sphn']", ),
                    // Text("Landlord Name : $house['landlordName']", ),
                    // Text("LandLord Phone Number : $house['lphn']", ),
                    // Text("Location : $house['houseName']",),
                    Text("Location: ${house["location"]}"),
                    // _showHouseDetails({"houseName": houseName, "name": house['name'], "email": house['email'], "image":  images[0], "location":house["location"]});
                  ],
                ),
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
      drawer: const AdminSideNav(),
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
