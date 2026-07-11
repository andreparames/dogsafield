import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../state/onboarding_state.dart';

final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());

class PhotoUploadScreen extends ConsumerWidget {
  const PhotoUploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(onboardingProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.t.onboarding.photoUpload.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(Icons.camera_alt, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              context.t.onboarding.photoUpload.subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              context.t.onboarding.photoUpload.hint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            if (state.localPhotoPath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(state.localPhotoPath!), height: 200, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 200)),
              ),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              onPressed: () => _pickImage(ref, context, ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: Text(context.t.onboarding.photoUpload.takePhoto),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _pickImage(ref, context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: Text(context.t.onboarding.photoUpload.chooseGallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(WidgetRef ref, BuildContext context, ImageSource source) async {
    final picker = ref.read(imagePickerProvider);
    final picked = await picker.pickImage(source: source, maxWidth: 1024);
    if (picked == null) return;
    ref.read(onboardingProvider.notifier).setLocalPhotoPath(picked.path);
    ref.read(onboardingProvider.notifier).setStep(OnboardingStep.profileForm);
    if (context.mounted) {
      context.push('/onboarding/profile');
    }
  }
}
