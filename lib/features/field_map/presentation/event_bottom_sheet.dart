import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/event.dart';
import '../state/gathering_providers.dart';
import '../state/waitlist_providers.dart';
import 'event_marker_icon.dart';
import 'package:dogsafield/i18n/strings.g.dart';

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
    final isPackWalk = event.type == EventType.packWalk;

    String dateStr;
    if (isPackWalk && event.scheduledDate != null) {
      dateStr = context.t.packWalk.scheduledDate(
        date: formatScheduleDate(event.scheduledDate!),
      );
    } else {
      dateStr = '${event.dateTime.month}/${event.dateTime.day}/${event.dateTime.year} '
          '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}';
    }

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
          if (isPackWalk) ...[
            const SizedBox(height: 12),
            _PackWalkStatusChip(waitlistStatus: event.waitlistStatus),
            const SizedBox(height: 12),
            _PackWalkProgressIndicator(event: event),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (isPackWalk) {
                context.push('/field/pack-walk/${event.id}');
              } else {
                context.push('/field/gathering/${event.id}');
              }
            },
            child: Text(context.t.fieldMap.viewDetails),
          ),
          if (showRsvpAction) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                messenger.showSnackBar(
                  SnackBar(content: Text(context.t.fieldMap.leavePackComingSoon)),
                );
              },
              child: Text(context.t.fieldMap.leavePack),
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

class _PackWalkStatusChip extends StatelessWidget {
  final String? waitlistStatus;

  const _PackWalkStatusChip({this.waitlistStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (waitlistStatus) {
      'unlocked' => (context.t.packWalk.unlocked, theme.colorScheme.primary),
      'full' => (context.t.packWalk.full, theme.colorScheme.error),
      _ => (context.t.packWalk.forming, theme.colorScheme.onSurfaceVariant),
    };

    return Chip(
      label: Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color),
      padding: EdgeInsets.zero,
    );
  }
}

class _PackWalkProgressIndicator extends ConsumerWidget {
  final DogEvent event;

  const _PackWalkProgressIndicator({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final countsAsync = ref.watch(waitlistCountsProvider(event.id));

    return countsAsync.when(
      data: (counts) {
        final joined = (counts['waiting'] ?? 0) + (counts['confirmed'] ?? 0);
        final progress = event.minThreshold > 0
            ? (joined / event.minThreshold).clamp(0.0, 1.0)
            : 0.0;
        final needed = (event.minThreshold - joined).clamp(0, event.minThreshold);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              event.waitlistStatus == 'forming'
                  ? context.t.packWalk.needsMore(
                      joined: joined.toString(),
                      max: event.maxAttendees.toString(),
                      needed: needed.toString(),
                    )
                  : '$joined/${event.maxAttendees}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
