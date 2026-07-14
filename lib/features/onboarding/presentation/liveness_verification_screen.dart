import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dogsafield/i18n/strings.g.dart';
import '../data/biometrics_repository.dart';
import '../state/onboarding_state.dart';

const _kLivenessChannel = MethodChannel('com.dogsafield.dogsafield/azure_liveness');

final _supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class LivenessVerificationScreen extends ConsumerStatefulWidget {
  const LivenessVerificationScreen({super.key});

  @override
  ConsumerState<LivenessVerificationScreen> createState() => _LivenessVerificationScreenState();
}

class _LivenessVerificationScreenState extends ConsumerState<LivenessVerificationScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.t;

    return PopScope(
      canPop: !_isProcessing,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.onboarding.liveness.title),
          leading: _isProcessing
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _cancel,
                ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isProcessing ? Icons.fingerprint : Icons.face_retouching_natural,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  _isProcessing
                      ? t.onboarding.liveness.processing
                      : t.onboarding.liveness.subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  t.onboarding.liveness.hint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                if (_isProcessing)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      FilledButton.icon(
                        onPressed: _startVerification,
                        icon: const Icon(Icons.play_arrow),
                        label: Text(t.common.next),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _cancel,
                        child: Text(t.common.cancel),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startVerification() async {
    final notifier = ref.read(onboardingProvider.notifier);
    final t = context.t;

    setState(() => _isProcessing = true);

    try {
      final client = ref.read(_supabaseClientProvider);
      final repo = BiometricsRepository(client);

      final session = await repo.createLivenessSession();
      final sessionId = await _invokeNativeLiveness(session.authToken ?? session.sessionId);

      if (sessionId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.onboarding.liveness.cancelled)),
        );
        _cancel();
        return;
      }

      final state = ref.read(onboardingProvider);
      final imagePath = state.localPhotoPath;
      final coords = state.humanTargetFaceCoordinates;

      if (imagePath == null || coords == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.onboarding.liveness.failed)),
        );
        _cancel();
        return;
      }

      final verifyResult = await repo.verifyBiometrics(
        imagePath: imagePath,
        humanTargetFaceCoordinates: coords,
        verifySessionId: sessionId,
      );

      if (verifyResult.isMatch && verifyResult.livenessDecision == 'realface') {
        notifier.setBiometricsVerified(true);
        notifier.setStep(OnboardingStep.profileForm);
        if (mounted) {
          context.pushReplacement('/onboarding/profile');
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.onboarding.liveness.failed)),
        );
        _resetToPhoto();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t.onboarding.liveness.sessionError}: $e')),
      );
      _resetToPhoto();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<String?> _invokeNativeLiveness(String authToken) async {
    try {
      final sessionId = await _kLivenessChannel.invokeMethod<String>(
        'startLivenessSession',
        {'authToken': authToken},
      );
      return sessionId;
    } on MissingPluginException {
      return authToken;
    }
  }

  void _resetToPhoto() {
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.setStep(OnboardingStep.photoUpload);
    if (mounted) {
      context.pushReplacement('/onboarding/photo', extra: {'retry': true});
    }
  }

  void _cancel() {
    final notifier = ref.read(onboardingProvider.notifier);
    notifier.reset();
    if (mounted) {
      context.pushReplacement('/onboarding/welcome');
    }
  }
}
