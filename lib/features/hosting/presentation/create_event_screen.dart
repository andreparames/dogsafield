import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../../../core/services/location_provider.dart';
import '../../../shared/models/event.dart';
import '../state/hosting_provider.dart';
import 'location_picker_screen.dart';

List<String> _bringOptions(BuildContext context) => context.t.hosting.create.bringOptions;

class CreateEventScreen extends ConsumerStatefulWidget {
  final double initialLatitude;
  final double initialLongitude;
  final DogEvent? existingEvent;

  const CreateEventScreen({
    super.key,
    this.initialLatitude = 0,
    this.initialLongitude = 0,
    this.existingEvent,
  });

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

  bool get _isEditing => widget.existingEvent != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingEvent;
    if (existing != null) {
      _titleCtrl.text = existing.title;
      _descCtrl.text = existing.description ?? '';
      _locationNameCtrl.text = existing.locationName;
      _type = existing.type;
      _latitude = existing.latitude;
      _longitude = existing.longitude;
      final localDt = existing.dateTime.toLocal();
      _dateTime = localDt;
      _time = TimeOfDay.fromDateTime(localDt);
      _maxAttendees = existing.maxAttendees;
      _whatToBring.addAll(existing.whatToBring);
    } else if (widget.initialLatitude != 0 || widget.initialLongitude != 0) {
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
        SnackBar(content: Text(context.t.hosting.create.selectEventType)),
      );
      return;
    }
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.hosting.create.selectLocation)),
      );
      return;
    }

    final notifier = ref.read(hostingActionProvider.notifier);
    final dt = DateTime(_dateTime.year, _dateTime.month, _dateTime.day, _time.hour, _time.minute);
    final event = DogEvent(
      id: _isEditing ? widget.existingEvent!.id : '',
      hostId: _isEditing ? widget.existingEvent!.hostId : '',
      type: _type!,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      locationName: _locationNameCtrl.text.trim().isEmpty ? '' : _locationNameCtrl.text.trim(),
      latitude: _latitude!,
      longitude: _longitude!,
      dateTime: dt,
      maxAttendees: _maxAttendees,
      whatToBring: _whatToBring.toList(),
      amenityTags: _isEditing ? widget.existingEvent!.amenityTags : [],
    );

    if (_isEditing) {
      await notifier.updateEvent(event);
    } else {
      await notifier.createEvent(event);
    }

    if (!mounted) return;

    final state = ref.read(hostingActionProvider);
    if (state is HostingActionError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    } else if (state is HostingActionSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? context.t.hosting.create.eventUpdated : context.t.hosting.create.eventCreated)),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actionState = ref.watch(hostingActionProvider);
    final isLoading = actionState is HostingActionLoading;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? context.t.hosting.create.titleEdit : context.t.hosting.create.titleCreate)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(context.t.hosting.create.eventType, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<EventType>(
              emptySelectionAllowed: true,
              segments: [
                ButtonSegment(value: EventType.dogPicnic, label: Text(context.t.hosting.create.dogPicnic), icon: const Icon(Icons.weekend)),
                ButtonSegment(value: EventType.packWalk, label: Text(context.t.hosting.create.packWalk), icon: const Icon(Icons.directions_walk)),
                ButtonSegment(value: EventType.fieldGames, label: Text(context.t.hosting.create.fieldGames), icon: const Icon(Icons.sports)),
              ],
              selected: _type != null ? {_type!} : {},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: const Key('eventTitle'),
              controller: _titleCtrl,
              decoration: InputDecoration(labelText: context.t.hosting.create.title, border: const OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? context.t.hosting.create.enterTitle : null,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickLocation,
              child: InputDecorator(
                decoration: InputDecoration(labelText: context.t.hosting.create.location, border: const OutlineInputBorder(), suffixIcon: const Icon(Icons.map)),
                child: _latitude != null
                    ? Text('${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}')
                    : Text(context.t.hosting.create.tapToSelect, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(labelText: context.t.hosting.create.description, border: const OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDateTime,
              child: InputDecorator(
                decoration: InputDecoration(labelText: context.t.hosting.create.dateTime, border: const OutlineInputBorder()),
                child: Text('${_dateTime.year}-${_dateTime.month.toString().padLeft(2, '0')}-${_dateTime.day.toString().padLeft(2, '0')}  ${_time.format(context)}'),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _maxAttendees.toString(),
              decoration: InputDecoration(labelText: context.t.hosting.create.maxAttendees, border: const OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (v) => _maxAttendees = int.tryParse(v) ?? 20,
            ),
            const SizedBox(height: 24),
            Text(context.t.hosting.create.whatToBring, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _bringOptions(context).map((item) => FilterChip(
                label: Text(item),
                selected: _whatToBring.contains(item),
                onSelected: (v) => setState(() => v ? _whatToBring.add(item) : _whatToBring.remove(item)),
              )).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEditing ? context.t.hosting.create.saveChanges : context.t.hosting.create.publish),
            ),
          ],
        ),
      ),
    );
  }
}
