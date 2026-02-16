import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'auth_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  Future<void> init() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied, we cannot request permissions.');
      return;
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _startTracking();
  }

  void _startTracking() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 500, // Reduced frequency to save battery/api usage but keep it accurate enough
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position? position) async {
        if (position != null) {
          debugPrint('Location Check: ${position.latitude}, ${position.longitude}');
          try {
             // 1. Get address details
            String? city;
            String? country;
            String? state;
            
            try {
              List<Placemark> placemarks = await placemarkFromCoordinates(
                position.latitude, 
                position.longitude
              );
              
              if (placemarks.isNotEmpty) {
                final place = placemarks.first;
                city = place.locality; // e.g. Mountain View
                country = place.country; // e.g. United States
                state = place.administrativeArea; // e.g. California
              }
            } catch (e) {
              debugPrint('Reverse geocoding failed: $e');
            }

            // 2. Prepare updates
            final updates = <String, dynamic>{
              'latitude': position.latitude,
              'longitude': position.longitude,
            };

            if (city != null) updates['city'] = city;
            if (country != null) updates['country'] = country;
            if (state != null) updates['state'] = state;
            
            if (city != null || country != null) {
              updates['location'] = [city, country].where((s) => s != null && s.isNotEmpty).join(', ');
            }

            // 3. Send to backend
            await AuthService().updateProfile(updates);
            
          } catch (e) {
            debugPrint('Failed to update location: $e');
          }
        }
      },
      onError: (e) {
        debugPrint('Location Stream Error: $e');
      }
    );
  }

  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  Future<Placemark?> getPlacemarkFromPosition(Position position) async {
    try {
      // Import this: import 'package:geocoding/geocoding.dart';
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) return placemarks.first;
    } catch (e) {
      debugPrint('Error getting placemark: $e');
    }
    return null;
  }
}
