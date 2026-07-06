import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/models/user_profile.dart';
import '../state/onboarding_state.dart';

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
              onChanged: (val) => setState(() => _selected = val),
            ),
            RadioListTile<TreatPolicy>(
              title: const Text('Ask before feeding \u2014 allergies or diet'),
              value: TreatPolicy.askBeforeFeeding,
              groupValue: _selected,
              onChanged: (val) => setState(() => _selected = val),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _submit,
              child: const Text('Complete Profile'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a treat policy')),
      );
      return;
    }
    ref.read(onboardingProvider.notifier).setStep(OnboardingStep.complete);
    context.push('/');
  }
}
