import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Address pieces resolved either from GPS (reverse geocoding) or from an
/// Indian PIN code lookup.
class ResolvedAddress {
  final String country;
  final String state;
  final String district;
  final String city;
  final String pincode;
  final String fullAddress;

  const ResolvedAddress({
    this.country = '',
    this.state = '',
    this.district = '',
    this.city = '',
    this.pincode = '',
    this.fullAddress = '',
  });
}

/// Small helper used by the "use my location" button and the pincode field
/// on the address forms. Kept in one place so both Add Trainee and Add
/// Trainer screens share the exact same behaviour.
class LocationHelper {
  LocationHelper._();

  static const _timeout = Duration(seconds: 8);

  /// Gets the device's current GPS position, asking for permission if needed.
  /// Returns null and reports a message via [onError] if it can't be obtained.
  static Future<Position?> getCurrentPosition({void Function(String)? onError}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        onError?.call("Please turn on location services and try again.");
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        onError?.call("Location permission denied.");
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      ).timeout(_timeout);
    } catch (e) {
      onError?.call("Could not get your location: $e");
      return null;
    }
  }

  /// Converts GPS coordinates into address parts using OpenStreetMap's free
  /// reverse-geocoding service. Returns null if it fails (network/timeout).
  static Future<ResolvedAddress?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        "https://nominatim.openstreetmap.org/reverse"
        "?format=jsonv2&lat=$lat&lon=$lng&zoom=14&addressdetails=1",
      );
      final resp = await http
          .get(uri, headers: {"User-Agent": "FitDeskGymAdmin/1.0"})
          .timeout(_timeout);

      if (resp.statusCode != 200) return null;

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final addr = Map<String, dynamic>.from(json['address'] ?? {});

      return ResolvedAddress(
        country: (addr['country'] ?? 'India').toString(),
        state: (addr['state'] ?? '').toString(),
        district: (addr['state_district'] ?? addr['county'] ?? '').toString(),
        city: (addr['city'] ?? addr['town'] ?? addr['village'] ?? addr['suburb'] ?? '')
            .toString(),
        pincode: (addr['postcode'] ?? '').toString(),
        fullAddress: (json['display_name'] ?? '').toString(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Looks up an Indian PIN code (via the free, keyless India Post API) and
  /// returns its city/district/state. Returns null if the code is invalid,
  /// not found, or the request fails.
  static Future<ResolvedAddress?> lookupIndianPincode(String pincode) async {
    if (!RegExp(r'^\d{6}$').hasMatch(pincode)) return null;

    try {
      final uri = Uri.parse("https://api.postalpincode.in/pincode/$pincode");
      final resp = await http.get(uri).timeout(_timeout);
      if (resp.statusCode != 200) return null;

      final decoded = jsonDecode(resp.body);
      if (decoded is! List || decoded.isEmpty) return null;

      final first = decoded.first as Map<String, dynamic>;
      if (first['Status'] != 'Success') return null;

      final offices = first['PostOffice'] as List?;
      if (offices == null || offices.isEmpty) return null;

      final po = offices.first as Map<String, dynamic>;
      return ResolvedAddress(
        country: (po['Country'] ?? 'India').toString(),
        state: (po['State'] ?? '').toString(),
        district: (po['District'] ?? '').toString(),
        city: (po['Name'] ?? po['District'] ?? '').toString(),
        pincode: pincode,
      );
    } catch (_) {
      return null;
    }
  }
}
