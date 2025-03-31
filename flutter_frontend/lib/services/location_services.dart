import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';

class LandlordLocationSelection extends ConsumerStatefulWidget {
  const LandlordLocationSelection({super.key});

  @override
  ConsumerState<LandlordLocationSelection> createState() =>
      _LandlordLocationSelectionState();
}

class _LandlordLocationSelectionState extends ConsumerState<LandlordLocationSelection> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  final LatLng _initialPosition = LatLng(0.2832, 34.7543);

  @override
  Widget build(BuildContext context) {
    Logger logger = Logger();
    return Stack(
      children: [
        GoogleMap(
            initialCameraPosition: CameraPosition(
                target: _initialPosition,
              zoom: 15,
            ),
            onMapCreated: (controller){
              _mapController = controller;
            },
            onTap: (LatLng position){
              setState(() {
                _selectedLocation = position;
              });
            },
          markers: _selectedLocation != null ? {
              Marker(
                  markerId: MarkerId(_selectedLocation.toString()),
                position: _selectedLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
          }:{},
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0,bottom: 10.0),
            child: FloatingActionButton.extended(
              onPressed: () {
                if (_selectedLocation != null) {
                  logger.i('Selected location: $_selectedLocation');
                  ref.read(locationProvider.notifier).state = _selectedLocation!;
                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.check),
              label: Text("Confirm Location"),
            ),
          ),
        ),
      ],
    );
  }
}
