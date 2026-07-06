import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      appBar: AppBar(title: const Text('Safety Boundaries')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Treat Policy', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Let other owners know how you handle treats.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            RadioListTile<TreatPolicy>(
              title: const Text('Okay to share \u2014 friendly dogs welcome'),
              value: TreatPolicy.okToShare,
              groupValue: _selected,
              onChanged: state.isSubmitting ? null : (val) => setState(() => _selected = val),
            ),
            RadioListTile<TreatPolicy>(
              title: const Text('Ask before feeding \u2014 allergies or diet'),
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
                  : const Text('Complete Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a treat policy')),
      );
      return;
    }

    final onboarding = ref.read(onboardingProvider);
    final repo = ref.read(onboardingRepositoryProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setSubmitting(true);

    try {
      String? photoUrl;
      if (onboarding.photoUrl != null) {
        photoUrl = await repo.uploadPhoto(onboarding.photoUrl!);
        notifier.setPhotoUrl(photoUrl);
      }

      await repo.createProfile(
        onboarding.userProfile!.copyWith(
          photoUrl: photoUrl,
          treatPolicy: _selected,
        ),
      );

      if (onboarding.dog != null) {
        await repo.createDogProfile(onboarding.dog!);
      }

      notifier.setStep(OnboardingStep.complete);
      if (!mounted) return;
      context.push('/');
    } catch (e) {
      notifier.setSubmissionError('Something went wrong. Please try again.');
    } finally {
      notifier.setSubmitting(false);
    }
  }
}
