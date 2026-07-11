import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../state/auth_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSigningIn = ref.watch(signingInProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.pets, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(context.t.onboarding.appTitle, style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                context.t.onboarding.tagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: isSigningIn ? null : () {
                  ref.read(signingInProvider.notifier).set(true);
                  ref.read(authServiceProvider).signInWithGoogle().catchError((e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.t.onboarding.googleSignInFailed(error: e))),
                      );
                    }
                  }).whenComplete(() {
                    ref.read(signingInProvider.notifier).set(false);
                  });
                },
                icon: const Icon(Icons.flutter_dash),
                label: Text(context.t.onboarding.continueWithGoogle),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isSigningIn ? null : () {
                  ref.read(signingInProvider.notifier).set(true);
                  ref.read(authServiceProvider).signInWithApple().catchError((e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.t.onboarding.appleSignInFailed(error: e))),
                      );
                    }
                  }).whenComplete(() {
                    ref.read(signingInProvider.notifier).set(false);
                  });
                },
                icon: const Icon(Icons.apple),
                label: Text(context.t.onboarding.continueWithApple),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
