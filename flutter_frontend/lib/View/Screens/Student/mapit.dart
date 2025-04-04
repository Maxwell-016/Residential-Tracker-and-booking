import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../chartbot_fun/ai_funs.dart';

class MapScreen extends StatefulWidget {
   MapScreen({super.key, required this.locations});
  final Future<List<String>> locations;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Map<String, Marker> _markers = {};
  MapType _currentMapType = MapType.normal;

  Future<void> _onMapCreated(GoogleMapController controller) async {
    print("🔍 _onMapCreated triggered");

// <<<<<<< gamma
//     final List<Map<String, dynamic>> toBeMarked = await getLocationsToBeMarked(widget.locations);
// =======
// //     final List<Map<String, dynamic>> toBeMarked =
// //         await getLocationsToBeMarked();
// >>>>>>> main

    setState(() {
      _markers.clear();
      for (final place in toBeMarked) {
// <<<<<<< gamma
// =======
// //         print(
// //             "📍 Adding Marker: ${place["name"]} at ${place["lat"]}, ${place["lng"]}");

// >>>>>>> main
        final marker = Marker(
          markerId: MarkerId(place["id"].toString()),
          position: LatLng(place["lat"], place["lng"]),
          infoWindow: InfoWindow(
            title: place["name"],
            snippet: "${place["address"]}\nRegion: ${place["region"]}\nVacant: ${place["vacant"] == 1 ? 'Yes' : 'No'}",
            onTap: () {
              _showModalBottomSheet(place);
            },
          ),
        );




        _markers[place["name"]] = marker;
      }
    });

    print("Markers added: ${_markers.length}");
  }



 Widget _showModalBottomSheet( Map<String, dynamic>place) {
   return SizedBox(
     height: 300,
     child: Column(
       children: [
         Image.network(
           place["image"],
           height: 150,
           width: double.infinity,
           fit: BoxFit.cover,
         ),
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(place["name"],
                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               Text("Address: ${place["address"]}"),
               Text("Region: ${place["region"]}"),
               Text("Vacant: ${place["vacant"] == 1 ? 'Yes' : 'No'}"),
             ],
           ),
         ),
       ],
     ),
   );
 }


  void _changeMapType() {
    setState(() {

      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
// <<<<<<< gamma
//           ? MapType.terrain
//           : _currentMapType == MapType.terrain
//           ? MapType.hybrid
//           : MapType.normal;
//       print(_currentMapType);
//  =======
// //               ? MapType.terrain
// //               : _currentMapType == MapType.terrain
// //                   ? MapType.hybrid
// //                   : MapType.normal;
// >>>>>>> main
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
