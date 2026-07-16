import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../state/auth_provider.dart';

class ReviewerLoginScreen extends ConsumerStatefulWidget {
  const ReviewerLoginScreen({super.key});

  @override
  ConsumerState<ReviewerLoginScreen> createState() => _ReviewerLoginScreenState();
}

class _ReviewerLoginScreenState extends ConsumerState<ReviewerLoginScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authServiceProvider);
      final email = await auth.validateReviewerCode(code);

      if (email == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.t.onboarding.invalidReviewerCode)),
          );
        }
        return;
      }

      await auth.signInWithEmailPassword(email, code);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.t.onboarding.reviewerSignInFailed(error: e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(
                context.t.onboarding.reviewerAccess,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                context.t.onboarding.reviewerSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: context.t.onboarding.reviewerCodeLabel,
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.t.onboarding.reviewerSignIn),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}