import 'dart:convert';

import 'package:favourite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/place.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectPlace});

  final void Function(PlaceLocation) onSelectPlace;

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;

  void _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    final url = Uri.parse(
        'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${lat}&longitude=${lng}&localityLanguage=en');

    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['locality'];

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: lat,
        longitude: lng,
        address: address,
      );
      _isGettingLocation = false;
    });

    widget.onSelectPlace(_pickedLocation!);
  }

  void _selectOnMap() async {
    final selectedLocation =
    await Navigator.of(context).push<LatLng?>(
      MaterialPageRoute(
          builder: (ctx) => MapScreen(
            location: _pickedLocation ??
                PlaceLocation(latitude: 0, longitude: 0, address: ''),
            isSelecting: true,
            onSelectLocation: (LatLng location) {
              setState(() {
                _pickedLocation = PlaceLocation(
                  latitude: location.latitude,
                  longitude: location.longitude,
                  address:
                  '', // You can update the address logic here
                );
              });
            },
          )),
    );

    if (selectedLocation != null) {
      // Handle the selected location here
      // You can update the UI or call your onSelectPlace callback
    }
}

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Center(
      child: Text(
        _pickedLocation == null
            ? 'No Location Chosen'
            : 'Location: ${_pickedLocation!.address}',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
      ),
    );

    if (_isGettingLocation) {
      previewContent = const Center(
        child: CircularProgressIndicator(),
      );
    }

    Widget mapContent = Container(); // Default empty container

    if (_pickedLocation != null) {
      previewContent = Container(
        height: 200,
        child: FlutterMap(
          options: MapOptions(
            center:
                LatLng(_pickedLocation!.latitude, _pickedLocation!.longitude),
            zoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
              onPressed: _getCurrentLocation,
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
              onPressed: _selectOnMap,
            ),
          ],
        ),
      ],
    );
  }
}
