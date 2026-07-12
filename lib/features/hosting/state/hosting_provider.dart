import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/event.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../../field_map/state/field_map_providers.dart';
import '../../messaging/state/messaging_providers.dart';
import '../data/hosting_repository.dart';

final hostingRepositoryProvider = Provider<HostingRepository>((ref) {
  return HostingRepository(Supabase.instance.client);
});

final myEventsProvider = FutureProvider<List<DogEvent>>((ref) async {
  final repo = ref.watch(hostingRepositoryProvider);
  return repo.fetchMyEvents();
});

final activeEventsProvider = Provider<AsyncValue<List<DogEvent>>>((ref) {
  final eventsAsync = ref.watch(myEventsProvider);
  return eventsAsync.whenData(
    (events) => events.where((e) => !e.isCancelled).toList(),
  );
});

final cancelledEventsProvider = Provider<AsyncValue<List<DogEvent>>>((ref) {
  final eventsAsync = ref.watch(myEventsProvider);
  return eventsAsync.whenData(
    (events) => events.where((e) => e.isCancelled).toList(),
  );
});

sealed class HostingActionState {
  const HostingActionState();
}

class HostingActionIdle extends HostingActionState {
  const HostingActionIdle();
}

class HostingActionLoading extends HostingActionState {
  const HostingActionLoading();
}

class HostingActionSuccess extends HostingActionState {
  const HostingActionSuccess();
}

class HostingActionError extends HostingActionState {
  final String message;
  const HostingActionError(this.message);
}

class HostingActionNotifier extends Notifier<HostingActionState> {
  @override
  HostingActionState build() => const HostingActionIdle();

  Future<void> createEvent(DogEvent event) async {
    if (state is HostingActionLoading) return;
    state = const HostingActionLoading();
    try {
      final repo = ref.read(hostingRepositoryProvider);
      await repo.createEvent(event);
      ref.invalidate(myEventsProvider);
      ref.invalidate(allEventsProvider);
      state = const HostingActionSuccess();
    } catch (e) {
      state = HostingActionError(t.errors.failedToCreateEvent);
    }
  }

  Future<void> updateEvent(DogEvent event) async {
    if (state is HostingActionLoading) return;
    state = const HostingActionLoading();
    try {
      final repo = ref.read(hostingRepositoryProvider);
      await repo.updateEvent(event);
      ref.invalidate(myEventsProvider);
      ref.invalidate(allEventsProvider);
      _notifyAttendeesOnEdit(event);
      state = const HostingActionSuccess();
    } catch (e) {
      state = HostingActionError(t.errors.failedToUpdateEvent);
    }
  }

  Future<void> _notifyAttendeesOnEdit(DogEvent event) async {
    try {
      final msgRepo = ref.read(messagingRepositoryProvider);
      final attendeeRows = await Supabase.instance.client
          .from('attendance')
          .select('user_id')
          .eq('event_id', event.id)
          .eq('status', 'confirmed');
      final attendeeIds = attendeeRows.map((r) => r['user_id'] as String).toList();
      await msgRepo.sendEventEditedNotification(
        event.hostId,
        event.id,
        event.title,
        attendeeIds,
      );
    } catch (_) {
      // notification is best-effort, event update already succeeded
    }
  }

  Future<void> cancelEvent(String eventId) async {
    if (state is HostingActionLoading) return;
    state = const HostingActionLoading();
    try {
      final repo = ref.read(hostingRepositoryProvider);
      await repo.cancelEvent(eventId);
      ref.invalidate(myEventsProvider);
      ref.invalidate(allEventsProvider);
      state = const HostingActionSuccess();
    } catch (e) {
      state = HostingActionError(t.errors.failedToCancelEvent);
    }
  }

  void reset() => state = const HostingActionIdle();
}

final hostingActionProvider =
    NotifierProvider<HostingActionNotifier, HostingActionState>(
        HostingActionNotifier.new);
