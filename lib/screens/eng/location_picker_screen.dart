import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class PickedLocation {
  final double lat;
  final double lng;
  final String? address;
  const PickedLocation({required this.lat, required this.lng, this.address});
}

class LocationPickerScreen extends StatefulWidget {
  final String title;
  const LocationPickerScreen({super.key, required this.title});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  LatLng _center = LatLng(24.7136, 46.6753);
  double _zoom = 14.0;
  String? _address;
  bool _locating = true;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }

  Future<void> _initCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() => _locating = false);
        Get.snackbar('Location', 'Location services are disabled', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _locating = false);
        Get.snackbar('Location', 'Location permission denied', snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() {
        _center = LatLng(pos.latitude, pos.longitude);
        _locating = false;
      });
      _mapController.move(_center, _zoom);
    } catch (e) {
      if (!mounted) return;
      setState(() => _locating = false);
      Get.snackbar('Location', 'Failed to get location: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    try {
      final uri = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(q)}&format=json&limit=1');
      final res = await http.get(uri, headers: {'User-Agent': 'MarsoolApp/1.0'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List && data.isNotEmpty) {
          final m = data.first;
          final lat = double.tryParse(m['lat']?.toString() ?? '') ?? _center.latitude;
          final lon = double.tryParse(m['lon']?.toString() ?? '') ?? _center.longitude;
          final disp = m['display_name']?.toString();
          if (!mounted) return;
          setState(() {
            _center = LatLng(lat, lon);
            _address = disp;
          });
          _mapController.move(_center, _zoom);
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_back, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'delivery.searchHint'.tr,
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) {
                        _debounce?.cancel();
                        _debounce = Timer(const Duration(milliseconds: 350), () {
                          _search(v);
                        });
                      },
                      style: GoogleFonts.ubuntu(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(initialCenter: _center, initialZoom: _zoom),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                    ],
                  ),
                  Center(child: Icon(Icons.place, size: 40, color: Colors.redAccent)),
                  if (_locating)
                    const Positioned(
                      top: 16,
                      right: 16,
                      child: CircularProgressIndicator(),
                    ),
                  Positioned(
                    right: 16,
                    bottom: 90,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'zoom_in',
                          onPressed: () {
                            setState(() {
                              _zoom = (_zoom + 1).clamp(3.0, 20.0);
                            });
                            _mapController.move(_center, _zoom);
                          },
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.add, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: 'zoom_out',
                          onPressed: () {
                            setState(() {
                              _zoom = (_zoom - 1).clamp(3.0, 20.0);
                            });
                            _mapController.move(_center, _zoom);
                          },
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.remove, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () {
                          final loc = PickedLocation(lat: _center.latitude, lng: _center.longitude, address: _address);
                          Navigator.pop(context, loc);
                        },
                        child: Text('Select location', style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}