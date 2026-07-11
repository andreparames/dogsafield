import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../../../shared/models/event.dart';
import '../state/hosting_provider.dart';

class ManageAttendeesScreen extends ConsumerStatefulWidget {
  final DogEvent event;

  const ManageAttendeesScreen({super.key, required this.event});

  @override
  ConsumerState<ManageAttendeesScreen> createState() => _ManageAttendeesScreenState();
}

class _ManageAttendeesScreenState extends ConsumerState<ManageAttendeesScreen> {
  late Future<List<Map<String, dynamic>>> _attendeesFuture;

  @override
  void initState() {
    super.initState();
    _attendeesFuture = ref.read(hostingRepositoryProvider).fetchAttendees(widget.event.id);
  }

  Future<void> _removeAttendee(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.hosting.manageAttendees.removeTitle),
        content: Text(context.t.hosting.manageAttendees.removeBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.t.common.keep)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(context.t.common.remove),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(hostingRepositoryProvider);
      await repo.removeAttendee(widget.event.id, userId);
      if (!mounted) return;
      setState(() {
        _attendeesFuture = repo.fetchAttendees(widget.event.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.hosting.manageAttendees.removed)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.hosting.manageAttendees.failedRemove)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.t.hosting.manageAttendees.title(title: widget.event.title))),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _attendeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(context.t.hosting.manageAttendees.couldNotLoad, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _attendeesFuture = ref.read(hostingRepositoryProvider).fetchAttendees(widget.event.id);
                      }),
                    icon: const Icon(Icons.refresh),
                    label: Text(context.t.common.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final attendees = snapshot.data ?? [];
          if (attendees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(context.t.hosting.manageAttendees.noAttendees, style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.people, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(context.t.hosting.manageAttendees.rsvpCount(count: attendees.length),
                        style: theme.textTheme.titleSmall),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: attendees.length,
                  itemBuilder: (context, index) {
                    final row = attendees[index];
                    final profile = row['profiles'] as Map<String, dynamic>?;
                    final dogsList = profile?['dogs'] as List<dynamic>?;
                    final firstDog = (dogsList?.isNotEmpty == true) ? dogsList!.first as Map<String, dynamic>? : null;
                    final displayName = profile?['display_name'] as String? ?? context.t.common.unknown;
                    final photoUrl = profile?['photo_url'] as String?;
                    final dogName = firstDog?['name'] as String?;
                    final userId = row['user_id'] as String;

                    return ListTile(
                      leading: CircleAvatar(
                        child: photoUrl != null
                            ? Image.network(photoUrl, width: 40, height: 40, fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 24))
                            : const Icon(Icons.person, size: 24),
                      ),
                      title: Text(displayName),
                      subtitle: dogName != null ? Text(dogName) : null,
                      trailing: IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.error),
                        tooltip: context.t.hosting.manageAttendees.removeTooltip,
                        onPressed: () => _removeAttendee(userId),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
