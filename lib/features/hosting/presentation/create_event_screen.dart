import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/location_provider.dart';
import '../../../shared/models/event.dart';
import '../state/hosting_provider.dart';
import 'location_picker_screen.dart';

const _bringOptions = ['Long line leash', 'Human lunch', 'Dog treats', 'Water bowl', 'Poop bags', 'Towel', 'Frisbee', 'Tennis balls'];

class CreateEventScreen extends ConsumerStatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const CreateEventScreen({super.key, this.initialLatitude = 0, this.initialLongitude = 0});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationNameCtrl = TextEditingController();
  EventType? _type;
  double? _latitude;
  double? _longitude;
  DateTime _dateTime = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  int _maxAttendees = 20;
  final Set<String> _whatToBring = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != 0 || widget.initialLongitude != 0) {
      _latitude = widget.initialLatitude;
      _longitude = widget.initialLongitude;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: _time);
    if (time == null || !mounted) return;

    setState(() {
      _dateTime = date;
      _time = time;
    });
  }

  Future<void> _pickLocation() async {
    var lat = _latitude;
    var lng = _longitude;
    if (lat == null || lng == null) {
      try {
        final pos = await ref.read(currentPositionProvider.future);
        if (!mounted) return;
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (_) {
      }
    }
    final result = await context.push<LocationPickerResult>(
      '/hosting/location-picker',
      extra: <String, dynamic>{'lat': lat ?? 0, 'lng': lng ?? 0, 'name': _locationNameCtrl.text},
    );
    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        if (result.locationName != null) _locationNameCtrl.text = result.locationName!;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event type.')),
      );
      return;
    }
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(hostingRepositoryProvider);
      final dt = DateTime(_dateTime.year, _dateTime.month, _dateTime.day, _time.hour, _time.minute);
      await repo.createEvent(DogEvent(
        id: '',
        hostId: '',
        type: _type!,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        locationName: _locationNameCtrl.text.trim().isEmpty ? 'Selected Location' : _locationNameCtrl.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        dateTime: dt,
        maxAttendees: _maxAttendees,
        whatToBring: _whatToBring.toList(),
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created!')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Event Type', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<EventType>(
              emptySelectionAllowed: true,
              segments: const [
                ButtonSegment(value: EventType.dogPicnic, label: Text('Dog Picnic'), icon: Icon(Icons.weekend)),
                ButtonSegment(value: EventType.packWalk, label: Text('Pack Walk'), icon: Icon(Icons.directions_walk)),
                ButtonSegment(value: EventType.fieldGames, label: Text('Field Games'), icon: Icon(Icons.sports)),
              ],
              selected: _type != null ? {_type!} : {},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: const Key('eventTitle'),
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickLocation,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder(), suffixIcon: Icon(Icons.map)),
                child: _latitude != null
                    ? Text('${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}')
                    : Text('Tap to select on map', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDateTime,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date & Time', border: OutlineInputBorder()),
                child: Text('${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}  ${_time.format(context)}'),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _maxAttendees.toString(),
              decoration: const InputDecoration(labelText: 'Max Attendees', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (v) => _maxAttendees = int.tryParse(v) ?? 20,
            ),
            const SizedBox(height: 24),
            Text('What to Bring', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _bringOptions.map((item) => FilterChip(
                label: Text(item),
                selected: _whatToBring.contains(item),
                onSelected: (v) => setState(() => v ? _whatToBring.add(item) : _whatToBring.remove(item)),
              )).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Publish to Field'),
            ),
          ],
        ),
      ),
    );
  }
}
