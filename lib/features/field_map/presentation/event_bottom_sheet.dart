import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/event.dart';
import '../state/gathering_providers.dart';
import 'event_marker_icon.dart';

class EventBottomSheet extends ConsumerWidget {
  final DogEvent event;
  final bool showRsvpAction;

  const EventBottomSheet({
    super.key,
    required this.event,
    this.showRsvpAction = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateStr = '${event.dateTime.month}/${event.dateTime.day}/${event.dateTime.year} '
        '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(eventTypeIcon(event.type),
                  color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(event.title,
                    style: theme.textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.label,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(eventTypeLabel(event.type),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(dateStr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(event.locationName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.push('/field/gathering/${event.id}'),
            child: const Text('View Details'),
          ),
          if (showRsvpAction) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Cancel RSVP — coming soon')),
                );
              },
              child: const Text('Cancel RSVP'),
            ),
          ],
          if (event.amenityTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: event.amenityTags.map((tag) {
                return Chip(
                  label: Text(tag,
                      style: theme.textTheme.labelSmall),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people,
                  size: 16, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              ref.watch(attendanceCountProvider(event.id)).when(
                data: (count) => Text('$count / ${event.maxAttendees}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                loading: () => Text('... / ${event.maxAttendees}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                error: (_, __) => Text('? / ${event.maxAttendees}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
