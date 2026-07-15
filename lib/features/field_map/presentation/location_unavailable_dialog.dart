import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../../../shared/models/region.dart';
import '../state/region_providers.dart';

class LocationUnavailableDialog extends ConsumerStatefulWidget {
  final VoidCallback onEnableLocation;
  final ValueChanged<Region> onRegionSelected;

  const LocationUnavailableDialog({
    super.key,
    required this.onEnableLocation,
    required this.onRegionSelected,
  });

  @override
  ConsumerState<LocationUnavailableDialog> createState() => _LocationUnavailableDialogState();
}

class _LocationUnavailableDialogState extends ConsumerState<LocationUnavailableDialog> {
  Region? _selectedRegion;

  @override
  Widget build(BuildContext context) {
    final regionsAsync = ref.watch(enabledRegionsProvider);

    return AlertDialog(
      icon: Icon(Icons.location_off, size: 48, color: Theme.of(context).colorScheme.error),
      title: Text(context.t.fieldMap.locationUnavailable.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.t.fieldMap.locationUnavailable.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.onEnableLocation,
            icon: const Icon(Icons.location_on),
            label: Text(context.t.fieldMap.locationUnavailable.enableLocation),
          ),
          const SizedBox(height: 16),
          Text(
            context.t.fieldMap.locationUnavailable.orSelectRegion,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          regionsAsync.when(
            data: (regions) {
              if (regions.isEmpty) {
                return const SizedBox.shrink();
              }
              return DropdownButtonFormField<Region>(
                value: _selectedRegion,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: context.t.fieldMap.locationUnavailable.selectRegion,
                ),
                items: regions
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                    .toList(),
                onChanged: (region) {
                  setState(() => _selectedRegion = region);
                  if (region != null) {
                    widget.onRegionSelected(region);
                    Navigator.of(context).pop();
                  }
                },
              );
            },
            loading: () => const SizedBox(
              height: 48,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => Text(
              context.t.fieldMap.locationUnavailable.failedToLoadRegions,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
