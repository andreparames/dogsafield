import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerResult {
  final double latitude;
  final double longitude;
  final String? locationName;

  const LocationPickerResult({required this.latitude, required this.longitude, this.locationName});
}

class LocationPickerScreen extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const LocationPickerScreen({super.key, this.initialLatitude = 0, this.initialLongitude = 0});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  late LatLng _marker;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _marker = widget.initialLatitude != 0 || widget.initialLongitude != 0
        ? LatLng(widget.initialLatitude, widget.initialLongitude)
        : const LatLng(38.7, -9.1);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapTap(LatLng latlng) {
    setState(() => _marker = latlng);
  }

  void _confirm() {
    Navigator.of(context).pop(LocationPickerResult(
      latitude: _marker.latitude,
      longitude: _marker.longitude,
      locationName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _marker, zoom: 14),
              onMapCreated: (c) => _mapController = c,
              onTap: _onMapTap,
              markers: {Marker(markerId: const MarkerId('selected'), position: _marker)},
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Location name (optional)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Text('${_marker.latitude.toStringAsFixed(5)}, ${_marker.longitude.toStringAsFixed(5)}', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _confirm,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirm Location'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
