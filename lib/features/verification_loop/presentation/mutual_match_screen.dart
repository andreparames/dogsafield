import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../field_map/data/gathering_detail.dart';
import '../../field_map/state/gathering_providers.dart';
import '../state/verification_providers.dart';

class MutualMatchScreen extends ConsumerWidget {
  final String eventId;

  const MutualMatchScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchAsync = ref.watch(matchViewDataProvider(eventId));
    final detailAsync = ref.watch(gatheringDetailProvider(eventId));
    final theme = Theme.of(context);

    ref.listen<AsyncValue<MatchViewData>>(matchViewDataProvider(eventId), (_, next) {
      next.whenOrNull(data: (data) {
        if (data.syncErrorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data.syncErrorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Who you met')),
      body: matchAsync.when(
        data: (matchData) {
          return detailAsync.when(
            data: (detail) => _buildContent(matchData, detail, theme, context),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(MatchViewData matchData, GatheringDetail detail, ThemeData theme, BuildContext context) {
    final allAttendees = {
      for (final a in detail.attendees)
        a.profile.id: a
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (matchData.mutualMatchIds.isNotEmpty) ...[
          Text('Mutual meets', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...matchData.mutualMatchIds.map((id) {
            final attendee = allAttendees[id];
            return Card(
              color: theme.colorScheme.primaryContainer,
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.pink),
                title: Text(attendee?.profile.displayName ?? 'Unknown'),
                subtitle: const Text('You both confirmed meeting. You\'re now packmates!'),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
        if (matchData.pendingOutgoingIds.isNotEmpty) ...[
          Text('You confirmed', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...matchData.pendingOutgoingIds.map((id) {
            final attendee = allAttendees[id];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.hourglass_empty),
                title: Text(attendee?.profile.displayName ?? 'Unknown'),
                subtitle: const Text('You said you met them, waiting for them to confirm.'),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
        if (matchData.pendingIncomingIds.isNotEmpty) ...[
          Text('They confirmed', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...matchData.pendingIncomingIds.map((id) {
            final attendee = allAttendees[id];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.person_add),
                title: Text(attendee?.profile.displayName ?? 'Unknown'),
                subtitle: const Text('They said they met you. Confirm back!'),
                trailing: TextButton(
                  onPressed: () => context.push('/verification/roll-call/$eventId'),
                  child: const Text('Check in'),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
        if (matchData.mutualMatchIds.isEmpty &&
            matchData.pendingOutgoingIds.isEmpty &&
            matchData.pendingIncomingIds.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No one has checked in yet. Ask other attendees to check in too!',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
      ],
    );
  }
}
