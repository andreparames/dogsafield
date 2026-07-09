import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
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
      appBar: AppBar(title: const Text('Pup Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Dog\'s Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageCtrl,
              decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _breedCtrl,
              decoration: const InputDecoration(labelText: 'Breed', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Text('Social Vibe', style: theme.textTheme.titleSmall),
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
              child: const Text('Next'),
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
        const SnackBar(content: Text('Please enter your dog\'s name')),
      );
      return;
    }
    final userId = ref.read(onboardingProvider).userProfile?.id ?? '';
    final dog = Dog(
      id: const Uuid().v4(),
      ownerId: userId,
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
    switch (v) {
      case SocialVibe.loungeLizard: return 'Lounge Lizard \u2014 calm and chill';
      case SocialVibe.zoomieKing: return 'Zoomie King \u2014 high energy';
      case SocialVibe.socialLearner: return 'Social Learner \u2014 still learning the ropes';
    }
  }
}
