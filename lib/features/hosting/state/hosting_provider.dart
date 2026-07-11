import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/event.dart';
import '../../field_map/state/field_map_providers.dart';
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
      state = const HostingActionError('Failed to create event. Please try again.');
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
      state = const HostingActionSuccess();
    } catch (e) {
      state = const HostingActionError('Failed to update event. Please try again.');
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
      state = const HostingActionError('Failed to cancel event. Please try again.');
    }
  }

  void reset() => state = const HostingActionIdle();
}

final hostingActionProvider =
    NotifierProvider<HostingActionNotifier, HostingActionState>(
        HostingActionNotifier.new);
