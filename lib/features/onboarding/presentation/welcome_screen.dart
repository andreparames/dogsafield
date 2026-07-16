import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../state/auth_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  int _tapCount = 0;

  void _onLogoTap() {
    _tapCount++;
    if (_tapCount >= 7) {
      _tapCount = 0;
      Navigator.of(context).pushNamed('reviewerLogin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSigningIn = ref.watch(signingInProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: _onLogoTap,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
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