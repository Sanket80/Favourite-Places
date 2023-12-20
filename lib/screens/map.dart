import 'package:favourite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.location = const PlaceLocation(
      latitude: 37.422,
      longitude: -122.084,
      address: '',
    ),
    this.isSelecting = true,
    required this.onSelectLocation,
  });

  final PlaceLocation location;
  final bool isSelecting;
  final void Function(LatLng) onSelectLocation;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isSelecting ? 'Pick your Location' : 'Your Location'),
        actions: [
          if (widget.isSelecting)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.of(context).pop(
                  _selectedLocation,
                );
              },
            ),
        ],
      ),
      body: Container(
        height: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(37.422,
                -122.084), // Initial center, doesn't matter since the user will select a location
            zoom: 13.0,
            onTap: widget.isSelecting
                ? (TapPosition? tapPosition, LatLng latLng) {
                    setState(() {
                      _selectedLocation = latLng;
                    });
                  }
                : null,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
          ],
        ),
      ),
      floatingActionButton: widget.isSelecting
          ? FloatingActionButton(
              onPressed: () {
                if (_selectedLocation != null) {
                  widget.onSelectLocation(_selectedLocation!);
                  Navigator.pop(context);
                }
              },
              child: const Icon(Icons.check),
            )
          : null,
    );
  }
}
