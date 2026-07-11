import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../../../shared/models/dog.dart';
import '../state/onboarding_state.dart';

class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({super.key});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  SocialVibe? _selectedVibe;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _breedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.t.onboarding.profileForm.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: context.t.onboarding.profileForm.dogName, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageCtrl,
              decoration: InputDecoration(labelText: context.t.onboarding.profileForm.age, border: const OutlineInputBorder()),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _breedCtrl,
              decoration: InputDecoration(labelText: context.t.onboarding.profileForm.breed, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Text(context.t.onboarding.profileForm.socialVibe, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            ...SocialVibe.values.map(
              (v) => RadioListTile<SocialVibe>(
                title: Text(_vibeLabel(v)),
                value: v,
                groupValue: _selectedVibe,
                onChanged: (val) => setState(() => _selectedVibe = val),
              ),
            ),
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
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.onboarding.profileForm.nameRequired)),
      );
      return;
    }
    final userProfile = ref.read(onboardingProvider).userProfile;
    if (userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.t.onboarding.profileForm.profileNotReady)),
      );
      return;
    }
    final dog = Dog(
      id: const Uuid().v4(),
      ownerId: userProfile.id,
      name: name,
      age: int.tryParse(_ageCtrl.text.trim()),
      breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
      vibe: _selectedVibe,
    );
    ref.read(onboardingProvider.notifier).setDog(dog);
    ref.read(onboardingProvider.notifier).setStep(OnboardingStep.icebreaker);
    context.push('/onboarding/icebreaker');
  }

  String _vibeLabel(SocialVibe v) {
    return switch (v) {
      SocialVibe.loungeLizard => context.t.vibe.loungeLizardFull,
      SocialVibe.zoomieKing => context.t.vibe.zoomieKingFull,
      SocialVibe.socialLearner => context.t.vibe.socialLearnerFull,
    };
  }
}
