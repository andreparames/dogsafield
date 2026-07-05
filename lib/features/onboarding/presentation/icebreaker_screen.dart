import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/onboarding_state.dart';

class IcebreakerScreen extends ConsumerStatefulWidget {
  const IcebreakerScreen({super.key});

  @override
  ConsumerState<IcebreakerScreen> createState() => _IcebreakerScreenState();
}

class _IcebreakerScreenState extends ConsumerState<IcebreakerScreen> {
  final _answerCtrl = TextEditingController();
  String? _selectedPrompt;

  static const _prompts = [
    'My dog\'s greatest criminal achievement to date...',
    'The weirdest thing my dog is afraid of...',
    'If my dog had a job, it would be...',
    'My dog\'s favorite snack that isn\'t dog food...',
  ];

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Icebreaker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Pick a prompt and share a story', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              'This helps other owners get to know you at the park.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            ..._prompts.map(
              (p) => RadioListTile<String>(
                title: Text(p),
                value: p,
                groupValue: _selectedPrompt,
                onChanged: (val) => setState(() => _selectedPrompt = val),
              ),
            ),
            if (_selectedPrompt != null) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _answerCtrl,
                decoration: const InputDecoration(
                  labelText: 'Your story',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_selectedPrompt == null || _answerCtrl.text.trim().isEmpty) return;
    final dog = ref.read(onboardingProvider).dog;
    if (dog != null) {
      ref.read(onboardingProvider.notifier).setDog(
        dog.copyWith(icebreakerAnswer: _answerCtrl.text.trim()),
      );
    }
    ref.read(onboardingProvider.notifier).setStep(OnboardingStep.safetyBoundaries);
    context.go('/onboarding/safety');
  }
}
