import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../../../core/database/providers.dart';
import '../../../shared/models/user_profile.dart';
import '../state/onboarding_state.dart';
import '../state/auth_provider.dart';

class SafetyBoundariesScreen extends ConsumerStatefulWidget {
  const SafetyBoundariesScreen({super.key});

  @override
  ConsumerState<SafetyBoundariesScreen> createState() => _SafetyBoundariesScreenState();
}

class _SafetyBoundariesScreenState extends ConsumerState<SafetyBoundariesScreen> {
  TreatPolicy? _selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.t.onboarding.safety.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.t.onboarding.safety.treatPolicy, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              context.t.onboarding.safety.treatPolicySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            RadioListTile<TreatPolicy>(
              title: Text(context.t.onboarding.safety.okToShare),
              value: TreatPolicy.okToShare,
              groupValue: _selected,
              onChanged: state.isSubmitting ? null : (val) => setState(() => _selected = val),
            ),
            RadioListTile<TreatPolicy>(
              title: Text(context.t.onboarding.safety.askBeforeFeeding),
              value: TreatPolicy.askBeforeFeeding,
              groupValue: _selected,
              onChanged: state.isSubmitting ? null : (val) => setState(() => _selected = val),
            ),
            const Spacer(),
            if (state.submissionError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  state.submissionError!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            FilledButton(
              onPressed: state.isSubmitting ? null : _submit,
              child: state.isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(context.t.onboarding.safety.completeProfile),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.onboarding.safety.policyRequired)),
      );
      return;
    }

    final onboarding = ref.read(onboardingProvider);
    final repo = ref.read(onboardingRepositoryProvider);
    final cache = ref.read(localCacheServiceProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setSubmitting(true);

    try {
      String? photoUrl;
      if (onboarding.localPhotoPath != null) {
        photoUrl = await repo.uploadPhoto(onboarding.localPhotoPath!).timeout(const Duration(seconds: 15));
        notifier.setPhotoUrl(photoUrl);
      }

      final updatedProfile = onboarding.userProfile!.copyWith(
        photoUrl: photoUrl,
        treatPolicy: _selected,
      );
      await repo.createProfile(updatedProfile).timeout(const Duration(seconds: 15));

      if (onboarding.dog != null) {
        await repo.createDogProfile(onboarding.dog!).timeout(const Duration(seconds: 15));
      }

      await cache.upsertProfiles([updatedProfile]);
      if (onboarding.dog != null) {
        await cache.upsertDogs([onboarding.dog!]);
      }

      notifier.setStep(OnboardingStep.complete);
      if (!mounted) return;
      context.push('/');
    } catch (e) {
      notifier.setSubmissionError(t.onboarding.safety.error);
    } finally {
      notifier.setSubmitting(false);
    }
  }
}
