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
  final String? initialLocationName;

  const LocationPickerScreen({
    super.key,
    this.initialLatitude = 0,
    this.initialLongitude = 0,
    this.initialLocationName,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  LatLng? _marker;
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialLocationName);
    if (widget.initialLatitude != 0 || widget.initialLongitude != 0) {
      _marker = LatLng(widget.initialLatitude, widget.initialLongitude);
    }
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
    if (_marker == null) return;
    Navigator.of(context).pop(LocationPickerResult(
      latitude: _marker!.latitude,
      longitude: _marker!.longitude,
      locationName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _marker ?? const LatLng(38.7, -9.1),
                zoom: 14,
              ),
              onMapCreated: (c) => _mapController = c,
              onTap: _onMapTap,
              markers: _marker != null
                  ? {Marker(markerId: const MarkerId('selected'), position: _marker!)}
                  : {},
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
                Text(
                  _marker != null
                      ? '${_marker!.latitude.toStringAsFixed(5)}, ${_marker!.longitude.toStringAsFixed(5)}'
                      : 'Tap on the map to select a location',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _marker != null ? null : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _marker != null ? _confirm : null,
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
