import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? currentPosition;
  Placemark? address;
  _determineCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    Position position;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = position;
    });
  }

  _determineAddress(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    setState(() {
      address = placemarks[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: [
              Text('$currentPosition'),
              Text('${address?.country}'),
              Text('${address?.name}'),
              Text('${address?.postalCode}'),
              Text('${address?.street}'),
              Text('${address?.administrativeArea}'),
              Text('${address?.locality}'),
              Text('${address?.thoroughfare}'),
              Text('${address?.subAdministrativeArea}'),
              Text('${address?.subLocality}'),
              ElevatedButton(
                  onPressed: () async{
                    await _determineCurrentPosition();
                    currentPosition != null ? _determineAddress(currentPosition!.latitude, currentPosition!.longitude) : null;
                  },
                  child: const Text('Get Location')
              ),
            ],
          ),
        ),
      ),
    );
  }
}
