import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../../onboarding/state/auth_provider.dart';
import '../../onboarding/state/onboarding_state.dart';
import '../state/account_providers.dart';
import 'founding_pack_badge.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/models/dog.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(accountDetailProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.account.title),
        actions: [],
      ),
      body: detailAsync.when(
        data: (detail) => _AccountContent(detail: detail),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(context.t.account.couldNotLoad, style: theme.textTheme.titleMedium),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(accountDetailProvider),
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

class _AccountContent extends ConsumerWidget {
  final AccountDetail detail;

  const _AccountContent({required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = detail.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileHeader(profile: profile),
          const SizedBox(height: 24),
          _DogsSection(dogs: detail.dogs, profile: profile),
          const SizedBox(height: 24),
          _TrialSection(profile: profile),
          if (profile.isFoundingPack) ...[
            const SizedBox(height: 24),
            _FoundingSection(profile: profile),
          ],
          if (profile.treatPolicy != null) ...[
            const SizedBox(height: 24),
            _SafetySection(profile: profile),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/hosting/my-events'),
              icon: const Icon(Icons.event),
              label: Text(context.t.account.myEvents),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/connections/blocked'),
              icon: const Icon(Icons.block),
              label: Text(context.t.account.blockedUsers),
            ),
          ),
          const SizedBox(height: 32),
          _AccountActions(),
          const SizedBox(height: 24),
          _SignOutButton(),
        ],
      ),
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  final UserProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Row(
      children: [
        GestureDetector(
          onTap: () => _showEditProfileSheet(context, ref),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 40,
                child: profile.photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          profile.photoUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40),
                        ),
                      )
                    : const Icon(Icons.person, size: 40),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit, size: 16, color: theme.colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showEditProfileSheet(context, ref),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.displayName ?? context.t.common.unknown,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.edit, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
              Text(
                profile.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProfileSheet(BuildContext context, WidgetRef ref) {
    final repo = ref.read(accountRepositoryProvider);
    final nameCtrl = TextEditingController(text: profile.displayName ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.t.account.editProfile, style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: context.t.account.displayName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked == null) return;
                final user = ref.read(authServiceProvider).currentUser;
                if (user == null) return;
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.t.common.uploading)),
                );
                try {
                  final ext = picked.path.split('.').last;
                  final path = 'verification_photos/${user.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
                  await Supabase.instance.client.storage.from('photos').upload(path, File(picked.path));
                  final url = Supabase.instance.client.storage.from('photos').getPublicUrl(path);
                  await repo.updateProfile(user.id, {'photo_url': url});
                  ref.invalidate(accountDetailProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.t.common.saved)),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.t.errors.failedToSave)),
                    );
                  }
                }
              },
              icon: const Icon(Icons.photo),
              label: Text(context.t.account.changePhoto),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final user = ref.read(authServiceProvider).currentUser;
                if (user == null) return;
                try {
                  await repo.updateProfile(user.id, {'display_name': name});
                  ref.invalidate(accountDetailProvider);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (_) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text(context.t.errors.failedToSave)),
                    );
                  }
                }
              },
              child: Text(context.t.common.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _DogsSection extends ConsumerWidget {
  final List<Dog> dogs;
  final UserProfile profile;

  const _DogsSection({required this.dogs, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.t.account.myDogs, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (dogs.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: dogs.length,
            itemBuilder: (context, index) {
              final dog = dogs[index];
              return _DogPhotoTile(dog: dog, ownerId: profile.id);
            },
          ),
        if (dogs.isNotEmpty) const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showAddDogSheet(context, ref, profile.id),
          icon: const Icon(Icons.add),
          label: Text(context.t.account.addDog),
        ),
      ],
    );
  }

  void _showAddDogSheet(BuildContext context, WidgetRef ref, String ownerId) {
    _showDogEditSheet(context, ref, null, ownerId);
  }
}

class _DogPhotoTile extends ConsumerWidget {
  final Dog dog;
  final String ownerId;

  const _DogPhotoTile({required this.dog, required this.ownerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Semantics(
      label: dog.name,
      button: true,
      child: InkWell(
        onTap: () => _showDogEditSheet(context, ref, dog, ownerId),
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: dog.photoUrl != null
              ? Image.network(
                  dog.photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _namePlaceholder(theme),
                )
              : _namePlaceholder(theme),
        ),
      ),
    );
  }

  Widget _namePlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        dog.name,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

void _showDogEditSheet(BuildContext context, WidgetRef ref, Dog? existing, String ownerId) {
  final nameCtrl = TextEditingController(text: existing?.name ?? '');
  final ageCtrl = TextEditingController(
    text: existing?.age?.toString() ?? '',
  );
  final breedCtrl = TextEditingController(text: existing?.breed ?? '');
  final icebreakerCtrl = TextEditingController(text: existing?.icebreakerAnswer ?? '');
  SocialVibe? selectedVibe = existing?.vibe;
  String? currentPhotoUrl = existing?.photoUrl;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                existing == null ? context.t.account.addDog : context.t.account.editDog,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              if (existing != null) ...[
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: currentPhotoUrl != null
                          ? Image.network(currentPhotoUrl!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _photoPlaceholder(ctx),
                            )
                          : _photoPlaceholder(ctx),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked == null) return;
                        if (!ctx.mounted) return;
                        try {
                          final url = await ref.read(accountRepositoryProvider).uploadDogPhoto(existing.id, picked.path);
                          setSheetState(() => currentPhotoUrl = url);
                          ref.invalidate(accountDetailProvider);
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(context.t.common.saved)),
                            );
                          }
                        } catch (_) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(context.t.errors.failedToSave)),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.photo, size: 18),
                      label: Text(
                        currentPhotoUrl != null ? context.t.account.changePhoto : context.t.account.addPhoto,
                      ),
                    ),
                    if (currentPhotoUrl != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () async {
                          if (!ctx.mounted) return;
                          try {
                            await ref.read(accountRepositoryProvider).removeDogPhoto(existing.id);
                            setSheetState(() => currentPhotoUrl = null);
                            ref.invalidate(accountDetailProvider);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(context.t.common.saved)),
                              );
                            }
                          } catch (_) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(context.t.errors.failedToSave)),
                              );
                            }
                          }
                        },
                        icon: Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
                        label: Text(
                          context.t.account.deletePhoto,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: context.t.onboarding.profileForm.dogName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageCtrl,
                decoration: InputDecoration(
                  labelText: context.t.onboarding.profileForm.age,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: breedCtrl,
                decoration: InputDecoration(
                  labelText: context.t.onboarding.profileForm.breed,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: icebreakerCtrl,
                decoration: InputDecoration(
                  labelText: context.t.onboarding.icebreaker.title,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Text(context.t.onboarding.profileForm.socialVibe, style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 4),
              ...SocialVibe.values.map(
                (v) => RadioListTile<SocialVibe>(
                  title: Text(_vibeLabelFull(v, context)),
                  value: v,
                  groupValue: selectedVibe,
                  onChanged: (val) => setSheetState(() => selectedVibe = val),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) return;
                  final repo = ref.read(accountRepositoryProvider);
                  try {
                    final fields = {
                      'name': name,
                      if (ageCtrl.text.trim().isNotEmpty) 'age': int.tryParse(ageCtrl.text.trim()),
                      if (breedCtrl.text.trim().isNotEmpty) 'breed': breedCtrl.text.trim(),
                      if (icebreakerCtrl.text.trim().isNotEmpty) 'icebreaker_answer': icebreakerCtrl.text.trim(),
                      'vibe': selectedVibe?.name,
                    };
                    if (existing != null) {
                      await repo.updateDog(existing.id, fields);
                    } else {
                      await repo.addDog({
                        'id': const Uuid().v4(),
                        'owner_id': ownerId,
                        ...fields,
                      });
                    }
                    ref.invalidate(accountDetailProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (_) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(context.t.errors.failedToSave)),
                      );
                    }
                  }
                },
                child: Text(existing == null ? context.t.common.add : context.t.common.save),
              ),
              if (existing != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: ctx,
                        builder: (dlgCtx) => AlertDialog(
                          title: Text(context.t.account.removeDog),
                          content: Text(context.t.account.removeDogConfirm(dogName: existing.name)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dlgCtx, false), child: Text(context.t.common.cancel)),
                            FilledButton(
                              onPressed: () => Navigator.pop(dlgCtx, true),
                              style: FilledButton.styleFrom(backgroundColor: Theme.of(dlgCtx).colorScheme.error),
                              child: Text(context.t.common.remove),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      try {
                        await ref.read(accountRepositoryProvider).deleteDog(existing.id);
                        ref.invalidate(accountDetailProvider);
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (_) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text(context.t.errors.failedToSave)),
                          );
                        }
                      }
                    },
                    icon: Icon(Icons.delete_outline, color: Theme.of(ctx).colorScheme.error),
                    label: Text(
                      context.t.common.remove,
                      style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(ctx).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _photoPlaceholder(BuildContext context) {
  return Container(
    color: Theme.of(context).colorScheme.primaryContainer,
    alignment: Alignment.center,
    child: Icon(Icons.pets, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 40),
  );
}

String _vibeLabelFull(SocialVibe v, BuildContext context) {
  return switch (v) {
    SocialVibe.loungeLizard => context.t.vibe.loungeLizardFull,
    SocialVibe.zoomieKing => context.t.vibe.zoomieKingFull,
    SocialVibe.socialLearner => context.t.vibe.socialLearnerFull,
  };
}

class _TrialSection extends StatelessWidget {
  final UserProfile profile;

  const _TrialSection({required this.profile});

  void _showTrialInfo(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.t.account.aboutTrialTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              context.t.account.aboutTrialBody(max: 3),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final used = profile.trialRsvpsUsed;
    final maxFree = 3;
    final remaining = (maxFree - used).clamp(0, maxFree);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(context.t.account.trialRsvps, style: theme.textTheme.titleSmall),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showTrialInfo(context, theme),
                  child: Icon(Icons.info_outline, size: 20, color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              context.t.account.rsvpsRemaining(remaining: remaining, max: maxFree),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TrialStat(label: context.t.account.used, value: '$used'),
                const SizedBox(width: 24),
                _TrialStat(label: context.t.account.remaining, value: '$remaining'),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: maxFree > 0 ? (used / maxFree).clamp(0.0, 1.0) : 0.0,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            if (remaining <= 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.push('/account/upgrade'),
                  icon: const Icon(Icons.star),
                  label: Text(context.t.account.upgradeToKeepJoining),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrialStat extends StatelessWidget {
  final String label;
  final String value;

  const _TrialStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: theme.textTheme.titleLarge),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _FoundingSection extends StatelessWidget {
  final UserProfile profile;

  const _FoundingSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const FoundingPackBadge(),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                context.t.account.foundingDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetySection extends ConsumerWidget {
  final UserProfile profile;

  const _SafetySection({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () => _showTreatPolicySheet(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.t.account.safetyBoundaries, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(
                      profile.treatPolicy == TreatPolicy.okToShare
                          ? context.t.treatPolicy.okToShareDetail
                          : context.t.treatPolicy.askBeforeFeedingDetail,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit, size: 16, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  void _showTreatPolicySheet(BuildContext context, WidgetRef ref) {
    TreatPolicy? selected = profile.treatPolicy;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.t.account.safetyBoundaries, style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 16),
              RadioListTile<TreatPolicy>(
                title: Text(context.t.treatPolicy.okToShareDetail),
                value: TreatPolicy.okToShare,
                groupValue: selected,
                onChanged: (val) => setSheetState(() => selected = val),
              ),
              RadioListTile<TreatPolicy>(
                title: Text(context.t.treatPolicy.askBeforeFeedingDetail),
                value: TreatPolicy.askBeforeFeeding,
                groupValue: selected,
                onChanged: (val) => setSheetState(() => selected = val),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (selected == null) return;
                  final user = ref.read(authServiceProvider).currentUser;
                  if (user == null) return;
                  try {
                    await ref.read(accountRepositoryProvider).updateProfile(
                      user.id,
                      {'treat_policy': selected!.name},
                    );
                    ref.invalidate(accountDetailProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (_) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(context.t.errors.failedToSave)),
                      );
                    }
                  }
                },
                child: Text(context.t.common.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final actionState = ref.watch(accountActionProvider);

    ref.listen<AccountActionState>(accountActionProvider, (prev, next) {
      if (next is AccountActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
      if (next is AccountActionSuccess) {
        ref.read(onboardingProvider.notifier).reset();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.t.account.dangerZone, style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.error,
        )),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: actionState is AccountActionLoading
                ? null
                : () => _showSuspendDialog(context, ref),
            icon: const Icon(Icons.pause_circle_outline),
            label: Text(context.t.account.suspendAccount),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: actionState is AccountActionLoading
                ? null
                : () => _showDeleteDialog(context, ref),
            icon: const Icon(Icons.delete_forever),
            label: Text(context.t.account.deleteAccount),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }

  void _showSuspendDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.account.suspendTitle),
        content: Text(
          context.t.account.suspendBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.t.common.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(accountActionProvider.notifier).suspendAccount();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.t.account.suspendAccount),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            controller.dispose();
            Navigator.pop(ctx);
          }
        },
        child: AlertDialog(
          title: Text(context.t.account.deleteTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.t.account.deleteBody,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.t.account.deleteConfirmHint,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.dispose();
                Navigator.pop(ctx);
              },
              child: Text(context.t.common.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim() != 'DELETE') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.t.account.deleteConfirmError)),
                  );
                  return;
                }
                controller.dispose();
                Navigator.pop(ctx);
                ref.read(accountActionProvider.notifier).deleteAccount();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.t.account.deleteForever),
          ),
        ],
      ),
      ),
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          try {
            await ref.read(authServiceProvider).signOut();
            if (!context.mounted) return;
            ref.read(onboardingProvider.notifier).reset();
          } catch (_) {}
        },
        icon: const Icon(Icons.logout),
        label: Text(context.t.account.signOut),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
