import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../field_map/data/attendee_profile.dart';
import '../../field_map/data/gathering_detail.dart';
import '../../field_map/state/gathering_providers.dart';
import '../../onboarding/state/auth_provider.dart';
import '../state/verification_providers.dart';

class RollCallScreen extends ConsumerStatefulWidget {
  final String eventId;

  const RollCallScreen({super.key, required this.eventId});

  @override
  ConsumerState<RollCallScreen> createState() => _RollCallScreenState();
}

class _RollCallScreenState extends ConsumerState<RollCallScreen> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(gatheringDetailProvider(widget.eventId));
    final actionState = ref.watch(rollCallActionProvider(widget.eventId));
    final theme = Theme.of(context);

    ref.listen<RollCallActionState>(rollCallActionProvider(widget.eventId), (_, next) {
      if (next is RollCallActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        ref.read(rollCallActionProvider(widget.eventId).notifier).reset();
      } else if (next is RollCallActionSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved! See who you met on the event page.')),
        );
        ref.read(rollCallActionProvider(widget.eventId).notifier).reset();
        context.pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Who\'d you meet?')),
      body: detailAsync.when(
        data: (detail) => _buildContent(detail, theme, actionState),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load attendees: $error')),
      ),
    );
  }

  Widget _buildContent(GatheringDetail detail, ThemeData theme, RollCallActionState actionState) {
    final currentUserId = ref.read(authServiceProvider).currentUser?.id;
    final others = detail.attendees.where((a) => a.profile.id != currentUserId).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Check who you met at this gathering:',
            style: theme.textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: others.isEmpty
              ? Center(
                  child: Text(
                    'No other attendees to confirm.',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  itemCount: others.length,
                  itemBuilder: (context, index) {
                    final attendee = others[index];
                    return _AttendeeCheckTile(
                      attendee: attendee,
                      isSelected: _selectedIds.contains(attendee.profile.id),
                      onToggle: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedIds.add(attendee.profile.id);
                          } else {
                            _selectedIds.remove(attendee.profile.id);
                          }
                        });
                      },
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: actionState is RollCallActionLoading || others.isEmpty
                  ? null
                  : () => ref.read(rollCallActionProvider(widget.eventId).notifier)
                      .submit(_selectedIds.toList()),
              icon: actionState is RollCallActionLoading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(actionState is RollCallActionLoading
                  ? 'Saving...'
                  : 'Save'),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttendeeCheckTile extends StatelessWidget {
  final AttendeeProfile attendee;
  final bool isSelected;
  final ValueChanged<bool?> onToggle;

  const _AttendeeCheckTile({
    required this.attendee,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = attendee.profile;
    final dog = attendee.dog;

    return CheckboxListTile(
      value: isSelected,
      onChanged: onToggle,
      secondary: CircleAvatar(
        radius: 20,
        child: profile.photoUrl != null
            ? Image.network(
                profile.photoUrl!,
                width: 40, height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 20),
              )
            : const Icon(Icons.person, size: 20),
      ),
      title: Text(profile.displayName ?? 'Unknown'),
      subtitle: dog != null
          ? Text('🐕 ${dog.name}${dog.breed != null ? ' · ${dog.breed}' : ''}',
              style: theme.textTheme.bodySmall)
          : null,
    );
  }
}
