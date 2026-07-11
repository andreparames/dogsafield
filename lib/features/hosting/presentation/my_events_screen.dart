import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/database/providers.dart';
import '../../../shared/models/event.dart';
import '../../field_map/presentation/event_marker_icon.dart';
import '../state/hosting_provider.dart';

class MyEventsScreen extends ConsumerWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    ref.listen<HostingActionState>(hostingActionProvider, (prev, next) {
      if (next is HostingActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    final eventsAsync = ref.watch(myEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: eventsAsync.when(
        data: (events) {
          final active = events.where((e) => !e.isCancelled).toList();
          final cancelled = events.where((e) => e.isCancelled).toList();
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No events yet', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + on the map to create one.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (active.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('Active Events', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ),
                ...active.map((e) => _EventCard(event: e)),
              ],
              if (cancelled.isNotEmpty) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text('Cancelled', style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.error)),
                ),
                ...cancelled.map((e) => _EventCard(event: e)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Could not load events', style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(myEventsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventCard extends ConsumerWidget {
  final DogEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCancelled = event.isCancelled;
    final isOnline = ref.watch(connectivityProvider).value ?? true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(eventTypeIcon(event.type), size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    style: (isCancelled ? theme.textTheme.titleMedium?.copyWith(decoration: TextDecoration.lineThrough) : theme.textTheme.titleMedium),
                  ),
                ),
                if (isCancelled)
                  Chip(
                    label: Text('Cancelled', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: theme.colorScheme.errorContainer,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${eventTypeLabel(event.type)} \u00B7 ${event.locationName}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              '${event.dateTime.month}/${event.dateTime.day}/${event.dateTime.year}',
              style: theme.textTheme.bodySmall,
            ),
            if (!isCancelled) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.push('/hosting/manage-attendees', extra: event),
                    icon: const Icon(Icons.people, size: 18),
                    label: const Text('Attendees'),
                  ),
                  isOnline
                      ? OutlinedButton.icon(
                          onPressed: () => context.push('/hosting/edit', extra: event),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                        )
                      : Tooltip(
                          message: "Can't edit while offline",
                          triggerMode: TooltipTriggerMode.tap,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                          ),
                        ),
                  OutlinedButton.icon(
                    onPressed: () => _confirmCancel(context, ref),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Event'),
        content: const Text('This will mark the event as cancelled. Attendees will no longer see it on the map.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(hostingActionProvider.notifier).cancelEvent(event.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Cancel Event'),
          ),
        ],
      ),
    );
  }
}
