import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/notifications/providers.dart';
import '../../../shared/models/dog.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/user_profile.dart';
import '../../connections/presentation/report_dialog.dart';
import '../../connections/state/connection_providers.dart';
import '../../onboarding/state/auth_provider.dart';
import '../../verification_loop/state/verification_providers.dart';
import '../data/attendee_profile.dart';
import '../data/gathering_detail.dart';
import '../state/gathering_providers.dart';
import '../state/rsvp_providers.dart';
import 'event_marker_icon.dart';
import 'package:dogsafield/i18n/strings.g.dart';

class GatheringDetailsScreen extends ConsumerWidget {
  final String eventId;

  const GatheringDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(gatheringDetailProvider(eventId));
    final theme = Theme.of(context);

    ref.listen<ConnectionActionState>(connectionActionProvider, (prev, next) {
      if (next is ConnectionActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        ref.read(connectionActionProvider.notifier).reset();
      } else if (next is ConnectionActionSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.gathering.userBlocked)),
        );
        ref.read(connectionActionProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.gathering.title),
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

String _vibeShortLabel(SocialVibe v) {
  return switch (v) {
    SocialVibe.loungeLizard => t.vibe.loungeLizard,
    SocialVibe.zoomieKing => t.vibe.zoomieKing,
    SocialVibe.socialLearner => t.vibe.socialLearner,
  };
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
            text: event.locationName.isNotEmpty ? event.locationName : context.t.hosting.create.selectedLocation,
          ),
          if (event.description != null && event.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(event.description!, style: theme.textTheme.bodyLarge),
          ],
          const SizedBox(height: 24),
          _sectionHeader(theme, context.t.gathering.host),
          const SizedBox(height: 8),
          _HostCard(host: host, hostDog: hostDog),
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
          _sectionHeader(theme, context.t.gathering.attendance),
          const SizedBox(height: 8),
          Text(
            context.t.gathering.attending(count: detail.attendees.length, max: event.maxAttendees),
            style: theme.textTheme.bodyLarge,
          ),
          if (detail.attendees.isNotEmpty) ...[
            const SizedBox(height: 12),
            _AttendeeListSection(attendees: detail.attendees),
          ],
          const SizedBox(height: 12),
          _HostActions(event: event),
          if (event.dateTime.isBefore(DateTime.now())) ...[
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
class _AttendeeListSection extends StatelessWidget {
  final List<AttendeeProfile> attendees;

  const _AttendeeListSection({required this.attendees});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: attendees.map((a) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _AttendeeCard(attendee: a),
      )).toList(),
    );
  }
}

class _AttendeeCard extends ConsumerWidget {
  final AttendeeProfile attendee;

  const _AttendeeCard({required this.attendee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = attendee.profile;
    final dog = attendee.dog;
    final isCurrentUser =
        ref.read(authServiceProvider).currentUser?.id == attendee.profile.id;

    return Card(
      color: isCurrentUser ? theme.colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              child: profile.photoUrl != null
                  ? Image.network(
                      profile.photoUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 24),
                    )
                  : const Icon(Icons.person, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.displayName ?? 'Unknown',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      if (isCurrentUser)
                        Text(context.t.gathering.you,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            )),
                    ],
                  ),
                  if (dog != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '🐕 ${dog.name}${dog.breed != null ? ' · ${dog.breed}' : ''}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (dog.vibe != null)
                      Text(
                        '★ ${_vibeShortLabel(dog.vibe!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    if (dog.icebreakerAnswer != null && dog.icebreakerAnswer!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '“${dog.icebreakerAnswer}”',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            if (!isCurrentUser)
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showBlockBottomSheet(context, ref),
              ),
          ],
        ),
      ),
    );
  }

  void _showBlockBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(ctx.t.connections.blocked.tier1),
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(connectionActionProvider.notifier).blockUser(attendee.profile.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off),
              title: Text(ctx.t.connections.blocked.tier2),
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(connectionActionProvider.notifier).blockAndHide(attendee.profile.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: Text(ctx.t.connections.blocked.tier3),
              onTap: () async {
                Navigator.of(ctx).pop();
                final reason = await showDialog<String>(
                  context: context,
                  builder: (_) => const ReportDialog(),
                );
                if (reason != null && reason.isNotEmpty) {
                  ref.read(connectionActionProvider.notifier).blockHideAndReport(
                    attendee.profile.id,
                    reason,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HostActions extends ConsumerWidget {
  final DogEvent event;

  const _HostActions({required this.event});

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
    return _JoinPackSection(event: event);
  }
}

class _JoinPackSection extends ConsumerWidget {
  final DogEvent event;

  const _JoinPackSection({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rsvpAsync = ref.watch(hasRsvpProvider(event.id));
    final actionState = ref.watch(rsvpActionProvider(event.id));

    ref.listen<RsvpActionState>(rsvpActionProvider(event.id), (_, next) {
      if (next is RsvpActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        ref.read(rsvpActionProvider(event.id).notifier).reset();
      } else if (next is RsvpActionSuccess) {
        final notif = ref.read(notificationServiceProvider);
        notif.cancelRollCallReminder(event.id).then((_) {
          ref.invalidate(hasRsvpProvider(event.id));
          return ref.read(hasRsvpProvider(event.id).future);
        }).then((hasRsvp) {
          if (hasRsvp) {
            notif.scheduleRollCallReminder(
              eventId: event.id,
              eventDateTime: event.dateTime,
              eventTitle: event.title,
            );
          }
        });
      }
    });

    if (actionState is RsvpActionLoading) {
      return const Center(child: SizedBox(
        width: 24, height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ));
    }

    return rsvpAsync.when(
      data: (hasRsvp) {
        if (hasRsvp) {
          return OutlinedButton.icon(
            onPressed: () => ref.read(rsvpActionProvider(event.id).notifier).cancelRsvp(),
            icon: const Icon(Icons.bookmark_remove),
            label: Text(context.t.gathering.leavePack),
          );
        }
        return FilledButton.icon(
          onPressed: () => ref.read(rsvpActionProvider(event.id).notifier).joinPack(),
          icon: const Icon(Icons.group_add),
          label: Text(context.t.gathering.joinPack),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.t.gathering.couldNotLoadPackStatus, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ref.invalidate(hasRsvpProvider(event.id)),
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(context.t.common.retry),
          ),
        ],
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
