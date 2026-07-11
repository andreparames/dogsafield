import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../state/onboarding_state.dart';

class IcebreakerScreen extends ConsumerStatefulWidget {
  const IcebreakerScreen({super.key});

  @override
  ConsumerState<IcebreakerScreen> createState() => _IcebreakerScreenState();
}

class _IcebreakerScreenState extends ConsumerState<IcebreakerScreen> {
  final _answerCtrl = TextEditingController();
  String? _selectedPrompt;

  static final _prompts = [
    t.onboarding.icebreaker.prompts.criminalAchievement,
    t.onboarding.icebreaker.prompts.weirdestFear,
    t.onboarding.icebreaker.prompts.job,
    t.onboarding.icebreaker.prompts.favoriteSnack,
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
      appBar: AppBar(title: Text(context.t.onboarding.icebreaker.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.t.onboarding.icebreaker.subtitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              context.t.onboarding.icebreaker.hint,
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
                decoration: InputDecoration(
                  labelText: context.t.onboarding.icebreaker.yourStory,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(context.t.common.next),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_selectedPrompt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.onboarding.icebreaker.promptRequired)),
      );
      return;
    }
    final answer = _answerCtrl.text.trim();
    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.onboarding.icebreaker.storyRequired)),
      );
      return;
    }
    final dog = ref.read(onboardingProvider).dog;
    if (dog != null) {
      ref.read(onboardingProvider.notifier).setDog(
        dog.copyWith(icebreakerAnswer: answer),
      );
    }
    ref.read(onboardingProvider.notifier).setStep(OnboardingStep.safetyBoundaries);
    context.push('/onboarding/safety');
  }
}
