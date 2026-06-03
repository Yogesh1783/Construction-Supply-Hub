import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';

class AddressResult {
  final String address;
  final String city;
  final String zipCode;
  final double lat;
  final double lng;

  const AddressResult({
    required this.address,
    required this.city,
    required this.zipCode,
    required this.lat,
    required this.lng,
  });
}

class AddressPickerScreen extends StatefulWidget {
  const AddressPickerScreen({super.key});

  @override
  State<AddressPickerScreen> createState() => _AddressPickerScreenState();
}

class _AddressPickerScreenState extends State<AddressPickerScreen> {
  final _mapCtrl = MapController();
  final _searchCtrl = TextEditingController();
  final _dio = Dio();

  // Default centre: India
  LatLng _pin = const LatLng(20.5937, 78.9629);
  String _resolvedAddress = '';
  String _resolvedCity = '';
  String _resolvedZip = '';
  bool _geocoding = false;
  bool _locating = false;

  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _moveToCurrentLocation();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _dio.close();
    super.dispose();
  }

  // ── Location ──────────────────────────────────────────────────────
  Future<void> _moveToCurrentLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever ||
          perm == LocationPermission.denied) return;

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
      final ll = LatLng(pos.latitude, pos.longitude);
      _mapCtrl.move(ll, 15);
      setState(() => _pin = ll);
      _reverseGeocode(ll);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  // ── Reverse geocode (pin → address) ──────────────────────────────
  Future<void> _reverseGeocode(LatLng ll) async {
    setState(() {
      _geocoding = true;
      _resolvedAddress = 'Fetching address…';
      _resolvedCity = '';
      _resolvedZip = '';
    });
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': ll.latitude,
          'lon': ll.longitude,
          'format': 'json',
          'addressdetails': '1',
        },
        options: Options(headers: {
          'User-Agent': 'CSH-Mobile-App/1.0',
          'Accept-Language': 'en',
        }),
      );
      final data = res.data;
      final addr = data['address'] as Map<String, dynamic>? ?? {};

      final road = addr['road'] ?? addr['pedestrian'] ?? addr['suburb'] ?? '';
      final neighbourhood =
          addr['neighbourhood'] ?? addr['quarter'] ?? addr['hamlet'] ?? '';
      final city = addr['city'] ??
          addr['town'] ??
          addr['village'] ??
          addr['county'] ??
          '';
      final postcode = addr['postcode'] ?? '';
      final state = addr['state'] ?? '';

      final addressLine =
          [road, neighbourhood, state].where((s) => s.isNotEmpty).join(', ');

      if (mounted) {
        setState(() {
          _resolvedAddress = addressLine.isNotEmpty
              ? addressLine
              : data['display_name'] ?? '';
          _resolvedCity = city;
          _resolvedZip = postcode;
          _geocoding = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _resolvedAddress = 'Could not fetch address';
          _geocoding = false;
        });
      }
    }
  }

  // ── Search suggestions (Nominatim) ───────────────────────────────
  void _onSearchChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () => _search(q));
  }

  Future<void> _search(String q) async {
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': q,
          'format': 'json',
          'addressdetails': '1',
          'limit': '6',
          'countrycodes': 'in',
        },
        options: Options(headers: {
          'User-Agent': 'CSH-Mobile-App/1.0',
          'Accept-Language': 'en',
        }),
      );
      if (mounted) {
        setState(() {
          _suggestions = List<Map<String, dynamic>>.from(res.data);
        });
      }
    } catch (_) {}
  }

  void _selectSuggestion(Map<String, dynamic> s) {
    final ll = LatLng(
        double.parse(s['lat'].toString()), double.parse(s['lon'].toString()));
    _mapCtrl.move(ll, 15);
    setState(() {
      _pin = ll;
      _suggestions = [];
      _searchCtrl.text = s['display_name'] ?? '';
    });
    _reverseGeocode(ll);
    FocusScope.of(context).unfocus();
  }

  void _confirm() {
    if (_resolvedAddress.isEmpty || _geocoding) return;
    Navigator.of(context).pop(AddressResult(
      address: _resolvedAddress,
      city: _resolvedCity,
      zipCode: _resolvedZip,
      lat: _pin.latitude,
      lng: _pin.longitude,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Delivery Location')),
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _pin,
              initialZoom: 5,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture && pos.center != null) {
                  setState(() => _pin = pos.center!);
                  _debounce?.cancel();
                  _debounce = Timer(
                    const Duration(milliseconds: 800),
                    () => _reverseGeocode(_pin),
                  );
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.csh.csh_mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pin,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_pin,
                      color: Color(0xFFfa9c23),
                      size: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Search bar ─────────────────────────────────────────────
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search address or place…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _suggestions = []);
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(10),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final s = _suggestions[i];
                        return ListTile(
                          dense: true,
                          leading:
                              const Icon(Icons.place_outlined, size: 18),
                          title: Text(
                            s['display_name'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () => _selectSuggestion(s),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ── Current location button ────────────────────────────────
          Positioned(
            right: 12,
            bottom: 160,
            child: FloatingActionButton.small(
              heroTag: 'locate',
              onPressed: _locating ? null : _moveToCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF232f3e),
              child: _locating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.my_location),
            ),
          ),

          // ── Address card + confirm ─────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, -3)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_pin,
                          color: Color(0xFFfa9c23)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _geocoding
                            ? const Text('Fetching address…',
                                style: TextStyle(color: Colors.grey))
                            : Text(
                                _resolvedAddress.isNotEmpty
                                    ? _resolvedAddress
                                    : 'Pan or search to select a location',
                                maxLines: 2,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ],
                  ),
                  if (_resolvedCity.isNotEmpty || _resolvedZip.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 32),
                      child: Text(
                        [_resolvedCity, _resolvedZip]
                            .where((s) => s.isNotEmpty)
                            .join(' – '),
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed:
                        (_geocoding || _resolvedAddress.isEmpty)
                            ? null
                            : _confirm,
                    icon: const Icon(Icons.check),
                    label: const Text('Use This Location'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
