import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/view_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

class LandlordLocationSelection extends ConsumerStatefulWidget {
  const LandlordLocationSelection({super.key});

  @override
  ConsumerState<LandlordLocationSelection> createState() =>
      _LandlordLocationSelectionState();
}

class _LandlordLocationSelectionState extends ConsumerState<LandlordLocationSelection> {
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    Logger logger = Logger();
    return Stack(
      children: [
        FlutterMap(
            mapController: _mapController,
            options: MapOptions(
                initialCenter: LatLng(0.2832, 34.7543),
                maxZoom: 100,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLocation = point;
                  });
                }),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                tileProvider: CancellableNetworkTileProvider(),
              ),
              if (_selectedLocation != null)
                MarkerLayer(markers: [
                  Marker(
                    width: 50.0,
                    height: 50.0,
                    point: _selectedLocation!,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  )
                ])
            ]),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0,bottom: 10.0),
            child: FloatingActionButton.extended(
              onPressed: () {
                if (_selectedLocation != null) {
                  logger.i(_selectedLocation);
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
