import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/dog.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/user_profile.dart';
import '../data/gathering_detail.dart';
import '../state/gathering_providers.dart';
import '../state/rsvp_providers.dart';
import 'event_marker_icon.dart';

class GatheringDetailsScreen extends ConsumerWidget {
  final String eventId;

  const GatheringDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(gatheringDetailProvider(eventId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gathering Details'),
      ),
      body: detailAsync.when(
        data: (detail) => _GatheringContent(detail: detail),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Failed to load event',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(gatheringDetailProvider(eventId)),
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

String _vibeShortLabel(SocialVibe v) {
  switch (v) {
    case SocialVibe.loungeLizard:
      return 'Lounge Lizard';
    case SocialVibe.zoomieKing:
      return 'Zoomie King';
    case SocialVibe.socialLearner:
      return 'Social Learner';
  }
}

class _GatheringContent extends StatelessWidget {
  final GatheringDetail detail;

  const _GatheringContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = detail.event;
    final host = detail.host;
    final hostDog = detail.hostDog;

    final dateStr = '${event.dateTime.month}/${event.dateTime.day}/${event.dateTime.year}'
        ' · ${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(eventTypeIcon(event.type),
                  color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(event.title,
                    style: theme.textTheme.headlineSmall),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(eventTypeLabel(event.type),
                style: theme.textTheme.labelMedium),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.calendar_today,
            text: dateStr,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.location_on,
            text: event.locationName,
          ),
          if (event.description != null && event.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(event.description!, style: theme.textTheme.bodyLarge),
          ],
          const SizedBox(height: 24),
          _sectionHeader(theme, 'Host'),
          const SizedBox(height: 8),
          _HostCard(host: host, hostDog: hostDog),
          if (event.amenityTags.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionHeader(theme, 'Amenities'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: event.amenityTags.map((tag) {
                return Chip(
                  label: Text(tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
          if (event.whatToBring.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionHeader(theme, 'What to Bring'),
            const SizedBox(height: 8),
            ...event.whatToBring.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_box_outline_blank,
                        size: 20, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(item, style: theme.textTheme.bodyLarge),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 24),
          _sectionHeader(theme, 'Attendance'),
          const SizedBox(height: 8),
          Text(
            '${event.attendeeIds.length} / ${event.maxAttendees} attending',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          _JoinPackSection(event: event),
        ],
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Text(title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: theme.textTheme.bodyLarge),
        ),
      ],
    );
  }
}

class _HostCard extends StatelessWidget {
  final UserProfile host;
  final Dog? hostDog;

  const _HostCard({required this.host, this.hostDog});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: host.photoUrl != null
                  ? NetworkImage(host.photoUrl!)
                  : null,
              child: host.photoUrl == null
                  ? Icon(Icons.person, size: 28)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    host.displayName ?? 'Unknown',
                    style: theme.textTheme.titleMedium,
                  ),
                  if (hostDog != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '🐕 ${hostDog!.name}${hostDog!.breed != null ? ' · ${hostDog!.breed}' : ''}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (hostDog!.vibe != null)
                      Text(
                        '★ ${_vibeShortLabel(hostDog!.vibe!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinPackSection extends ConsumerWidget {
  final DogEvent event;

  const _JoinPackSection({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rsvpAsync = ref.watch(hasRsvpProvider(event.id));
    final actionState = ref.watch(rsvpActionProvider(event.id));

    if (actionState == RsvpActionState.loading) {
      return const Center(child: SizedBox(
        width: 24, height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ));
    }

    return rsvpAsync.when(
      data: (hasRsvp) {
        if (hasRsvp) {
          return OutlinedButton.icon(
            onPressed: actionState == RsvpActionState.loading
                ? null
                : () => ref.read(rsvpActionProvider(event.id).notifier).cancelRsvp(),
            icon: const Icon(Icons.bookmark_remove),
            label: const Text('Cancel RSVP'),
          );
        }
        return FilledButton.icon(
          onPressed: actionState == RsvpActionState.loading
              ? null
              : () => ref.read(rsvpActionProvider(event.id).notifier).joinPack(),
          icon: const Icon(Icons.group_add),
          label: const Text('Join Pack'),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => FilledButton.icon(
        onPressed: () => ref.read(rsvpActionProvider(event.id).notifier).joinPack(),
        icon: const Icon(Icons.group_add),
        label: const Text('Join Pack'),
      ),
    );
  }
}
