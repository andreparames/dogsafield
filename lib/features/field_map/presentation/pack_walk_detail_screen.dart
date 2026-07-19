import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/dog.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/user_profile.dart';
import '../../onboarding/state/auth_provider.dart';
import '../../verification_loop/state/verification_providers.dart';
import '../data/gathering_detail.dart';
import '../state/gathering_providers.dart';
import '../state/waitlist_providers.dart';
import 'event_marker_icon.dart';
import 'package:dogsafield/i18n/strings.g.dart';

class PackWalkDetailScreen extends ConsumerWidget {
  final String eventId;

  const PackWalkDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(gatheringDetailProvider(eventId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.gathering.title),
      ),
      body: detailAsync.when(
        data: (detail) => _PackWalkContent(detail: detail),
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
                  context.t.gathering.failedToLoad,
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
                  label: Text(context.t.common.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PackWalkContent extends ConsumerWidget {
  final GatheringDetail detail;

  const _PackWalkContent({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final event = detail.event;
    final host = detail.host;
    final hostDogs = detail.hostDogs;

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
          _WaitlistStatusBadge(waitlistStatus: event.waitlistStatus),
          const SizedBox(height: 16),
          if (event.scheduledDate != null) ...[
            _InfoRow(
              icon: Icons.calendar_today,
              text: context.t.packWalk.scheduledDate(
                date: formatScheduleDate(event.scheduledDate!),
              ),
            ),
            const SizedBox(height: 8),
          ],
          _InfoRow(
            icon: Icons.location_on,
            text: event.locationName.isNotEmpty
                ? event.locationName
                : context.t.hosting.create.selectedLocation,
          ),
          if (event.description != null && event.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(event.description!, style: theme.textTheme.bodyLarge),
          ],
          const SizedBox(height: 24),
          _WaitlistProgressSection(event: event),
          const SizedBox(height: 24),
          _sectionHeader(theme, context.t.gathering.host),
          const SizedBox(height: 8),
          _HostCard(host: host, hostDogs: hostDogs),
          if (event.amenityTags.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionHeader(theme, context.t.gathering.amenities),
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
            _sectionHeader(theme, context.t.gathering.whatToBring),
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
          _WaitlistActions(event: event),
          if (event.scheduledDate != null &&
              event.scheduledDate!.isBefore(DateTime.now())) ...[
            const SizedBox(height: 16),
            _RollCallSection(event: event),
          ],
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

class _WaitlistStatusBadge extends StatelessWidget {
  final String? waitlistStatus;

  const _WaitlistStatusBadge({this.waitlistStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color) = switch (waitlistStatus) {
      'unlocked' => (context.t.packWalk.unlocked, theme.colorScheme.primary),
      'full' => (context.t.packWalk.full, theme.colorScheme.error),
      _ => (context.t.packWalk.forming, theme.colorScheme.onSurfaceVariant),
    };

    return Chip(
      label: Text(label,
          style: theme.textTheme.labelMedium?.copyWith(color: color)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color),
    );
  }
}

class _WaitlistProgressSection extends ConsumerWidget {
  final DogEvent event;

  const _WaitlistProgressSection({required this.event});

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
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  event.waitlistStatus == 'unlocked'
                      ? theme.colorScheme.primary
                      : theme.colorScheme.tertiary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.waitlistStatus == 'forming'
                  ? context.t.packWalk.needsMore(
                      joined: joined.toString(),
                      max: event.maxAttendees.toString(),
                      needed: needed.toString(),
                    )
                  : '$joined/${event.maxAttendees}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.t.packWalk.confirmedCount(
                  count: (counts['confirmed'] ?? 0).toString()),
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

class _WaitlistActions extends ConsumerWidget {
  final DogEvent event;

  const _WaitlistActions({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(authServiceProvider).currentUser?.id;
    if (userId == event.hostId) {
      return FilledButton.icon(
        onPressed: () => context.push('/hosting/edit', extra: event),
        icon: const Icon(Icons.edit),
        label: Text(context.t.gathering.editEvent),
      );
    }

    return _JoinWaitlistSection(event: event);
  }
}

class _JoinWaitlistSection extends ConsumerWidget {
  final DogEvent event;

  const _JoinWaitlistSection({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myStatusAsync = ref.watch(myWaitlistStatusProvider(event.id));
    final actionState = ref.watch(waitlistActionProvider(event.id));

    ref.listen<WaitlistActionState>(waitlistActionProvider(event.id), (_, next) {
      if (next is WaitlistActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        ref.read(waitlistActionProvider(event.id).notifier).reset();
      } else if (next is WaitlistActionSuccess) {
        ref.read(waitlistActionProvider(event.id).notifier).reset();
      }
    });

    if (actionState is WaitlistActionLoading) {
      return const Center(child: SizedBox(
        width: 24, height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ));
    }

    return myStatusAsync.when(
      data: (myStatus) {
        if (myStatus == null) {
          return _buildJoinButtons(context, ref);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SpotStatusCard(status: myStatus.status),
            const SizedBox(height: 12),
            if (myStatus.status == 'waiting' && event.waitlistStatus == 'unlocked')
              FilledButton.icon(
                onPressed: () {
                  ref.read(waitlistActionProvider(event.id).notifier).confirmSpot();
                },
                icon: const Icon(Icons.check_circle),
                label: Text(context.t.packWalk.confirmSpot),
              ),
            if (myStatus.status == 'waiting')
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(waitlistActionProvider(event.id).notifier).leaveWaitlist();
                },
                icon: const Icon(Icons.bookmark_remove),
                label: Text(context.t.packWalk.leaveWaitlist),
              ),
            if (myStatus.status == 'confirmed')
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(waitlistActionProvider(event.id).notifier).leaveWaitlist();
                },
                icon: const Icon(Icons.bookmark_remove),
                label: Text(context.t.packWalk.leaveWaitlist),
              ),
            if (myStatus.status == 'released' || myStatus.status == 'declined')
              FilledButton.icon(
                onPressed: () {
                  ref.read(waitlistActionProvider(event.id).notifier).joinWaitlist();
                },
                icon: const Icon(Icons.group_add),
                label: Text(context.t.packWalk.joinWaitlist),
              ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.t.gathering.couldNotLoadPackStatus,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ref.invalidate(myWaitlistStatusProvider(event.id)),
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(context.t.common.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinButtons(BuildContext context, WidgetRef ref) {
    if (event.waitlistStatus == 'full') {
      return Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.group_off, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(context.t.packWalk.packFullMessage),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.waitlistStatus == 'unlocked') ...[
          Text(
            context.t.packWalk.confirmYourSpot,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        FilledButton.icon(
          onPressed: () async {
            final notifier = ref.read(waitlistActionProvider(event.id).notifier);
            await notifier.joinWaitlist();
            if (!context.mounted) return;
            if (event.waitlistStatus == 'unlocked') {
              final state = ref.read(waitlistActionProvider(event.id));
              if (state is WaitlistActionSuccess) {
                await notifier.confirmSpot();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.t.packWalk.spotConfirmedSnackbar)),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.t.packWalk.joinedWaitlist)),
              );
            }
          },
          icon: Icon(
            event.waitlistStatus == 'unlocked'
                ? Icons.check_circle
                : Icons.group_add,
          ),
          label: Text(
            event.waitlistStatus == 'unlocked'
                ? context.t.packWalk.confirmSpot
                : context.t.packWalk.joinWaitlist,
          ),
        ),
      ],
    );
  }
}

class _SpotStatusCard extends StatelessWidget {
  final String status;

  const _SpotStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, icon, color) = switch (status) {
      'confirmed' => (
        context.t.packWalk.spotConfirmed,
        Icons.check_circle,
        theme.colorScheme.primary,
      ),
      'released' => (
        context.t.packWalk.spotReleased,
        Icons.cancel,
        theme.colorScheme.error,
      ),
      'declined' => (
        context.t.packWalk.spotDeclined,
        Icons.block,
        theme.colorScheme.error,
      ),
      _ => (
        context.t.packWalk.spotWaiting,
        Icons.hourglass_empty,
        theme.colorScheme.onSurfaceVariant,
      ),
    };

    return Card(
      color: color.withAlpha(25),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: theme.textTheme.bodyLarge?.copyWith(color: color)),
            ),
          ],
        ),
      ),
    );
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
  final List<Dog> hostDogs;

  const _HostCard({required this.host, this.hostDogs = const []});

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
              child: host.photoUrl != null
                  ? Image.network(
                      host.photoUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 28),
                    )
                  : const Icon(Icons.person, size: 28),
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
                  if (hostDogs.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _describeDogs(hostDogs),
                      style: theme.textTheme.bodyMedium,
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

class _RollCallSection extends ConsumerWidget {
  final DogEvent event;

  const _RollCallSection({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myEntries = ref.watch(myRollCallEntriesProvider(event.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Who\'d you meet?', style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 8),
        myEntries.when(
          data: (entries) {
            if (entries.isNotEmpty) {
              return Column(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.push('/verification/matches/${event.id}'),
                    icon: const Icon(Icons.people),
                    label: const Text('Who you met'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => context.push('/verification/roll-call/${event.id}'),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit who you met'),
                  ),
                ],
              );
            }
            return FilledButton.icon(
              onPressed: () => context.push('/verification/roll-call/${event.id}'),
              icon: const Icon(Icons.rate_review),
              label: const Text('Who\'d you meet?'),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => FilledButton.icon(
            onPressed: () => context.push('/verification/roll-call/${event.id}'),
            icon: const Icon(Icons.rate_review),
            label: const Text('Who\'d you meet?'),
          ),
        ),
      ],
    );
  }
}

String _describeDogs(List<Dog> dogs) {
  if (dogs.isEmpty) return '';
  if (dogs.length == 1) {
    final d = dogs.first;
    if (d.breed != null) return 'has a ${d.breed} (${d.name})';
    return 'has ${d.name}';
  }
  final byBreed = <String, List<Dog>>{};
  for (final d in dogs) {
    final key = d.breed ?? '';
    byBreed.putIfAbsent(key, () => []).add(d);
  }
  final parts = <String>[];
  for (final entry in byBreed.entries) {
    final names = entry.value.map((d) => d.name).join(', ');
    if (entry.key.isEmpty) {
      parts.add(names);
    } else if (entry.value.length == 1) {
      parts.add('a ${entry.key} ($names)');
    } else {
      final count = entry.value.length;
      parts.add('$count ${entry.key}s ($names)');
    }
  }
  if (parts.length == 1) return 'has ${parts.first}';
  return 'has ${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
}
