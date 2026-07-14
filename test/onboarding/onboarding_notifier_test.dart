import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/user_profile.dart';
import 'package:dogsafield/features/onboarding/state/onboarding_state.dart';

ProviderContainer createContainer() {
  return ProviderContainer();
}

void main() {
  group('OnboardingNotifier', () {
    test('starts at welcome step', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final state = container.read(onboardingProvider);

      expect(state.step, OnboardingStep.welcome);
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.isSubmitting, false);
      expect(state.submissionError, isNull);
      expect(state.photoUrl, isNull);
      expect(state.dog, isNull);
    });

    test('setStep transitions to correct step', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setStep(OnboardingStep.photoUpload);
      expect(container.read(onboardingProvider).step, OnboardingStep.photoUpload);

      notifier.setStep(OnboardingStep.profileForm);
      expect(container.read(onboardingProvider).step, OnboardingStep.profileForm);
    });

    test('setStep clears error', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setError('something went wrong');
      expect(container.read(onboardingProvider).error, 'something went wrong');

      notifier.setStep(OnboardingStep.icebreaker);
      expect(container.read(onboardingProvider).error, isNull);
    });

    test('setLoading toggles loading state', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setLoading(true);
      expect(container.read(onboardingProvider).isLoading, true);

      notifier.setLoading(false);
      expect(container.read(onboardingProvider).isLoading, false);
    });

    test('setSubmitting toggles submitting state and clears submissionError', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setSubmissionError('previous error');
      notifier.setSubmitting(true);
      expect(container.read(onboardingProvider).isSubmitting, true);
      expect(container.read(onboardingProvider).submissionError, isNull);

      notifier.setSubmitting(false);
      expect(container.read(onboardingProvider).isSubmitting, false);
    });

    test('setSubmissionError stores error without affecting submitting', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setSubmitting(true);
      notifier.setSubmissionError('upload failed');
      expect(container.read(onboardingProvider).submissionError, 'upload failed');
      expect(container.read(onboardingProvider).isSubmitting, true);
    });

    test('setPhotoUrl stores url', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setPhotoUrl('https://example.com/photo.jpg');
      expect(container.read(onboardingProvider).photoUrl, 'https://example.com/photo.jpg');
    });

    test('setDog stores dog', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      final dog = Dog(id: '1', ownerId: 'u1', name: 'Buddy');
      notifier.setDog(dog);
      expect(container.read(onboardingProvider).dog, dog);
      expect(container.read(onboardingProvider).dog!.name, 'Buddy');
    });

    test('setUserProfile stores profile', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setUserProfile(
        UserProfile(id: 'u1', email: 'a@b.com'),
      );
      expect(container.read(onboardingProvider).userProfile, isNotNull);
      expect(container.read(onboardingProvider).userProfile!.email, 'a@b.com');
    });

    test('reset returns to initial state', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setStep(OnboardingStep.complete);
      notifier.setPhotoUrl('https://example.com/p.jpg');
      notifier.setDog(Dog(id: '1', ownerId: 'u1', name: 'Buddy'));
      notifier.setLoading(true);
      notifier.setSubmitting(true);
      notifier.setSubmissionError('some error');

      notifier.reset();

      expect(container.read(onboardingProvider).step, OnboardingStep.welcome);
      expect(container.read(onboardingProvider).isLoading, false);
      expect(container.read(onboardingProvider).isSubmitting, false);
      expect(container.read(onboardingProvider).submissionError, isNull);
      expect(container.read(onboardingProvider).photoUrl, isNull);
      expect(container.read(onboardingProvider).dog, isNull);
    });

    test('setDog replaces previous dog', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setDog(Dog(id: '1', ownerId: 'u1', name: 'Buddy'));
      notifier.setDog(Dog(id: '2', ownerId: 'u1', name: 'Max', age: 5));

      expect(container.read(onboardingProvider).dog!.id, '2');
      expect(container.read(onboardingProvider).dog!.name, 'Max');
      expect(container.read(onboardingProvider).dog!.age, 5);
    });

    test('setHumanTargetFaceCoordinates stores coordinates', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      final coords = {'left': 10.0, 'top': 20.0, 'width': 100.0, 'height': 150.0};
      notifier.setHumanTargetFaceCoordinates(coords);

      expect(container.read(onboardingProvider).humanTargetFaceCoordinates, coords);
      expect(container.read(onboardingProvider).humanTargetFaceCoordinates!['left'], 10.0);
    });

    test('setHumanTargetFaceCoordinates replaces previous coords', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setHumanTargetFaceCoordinates({'left': 5.0, 'top': 5.0, 'width': 50.0, 'height': 50.0});
      notifier.setHumanTargetFaceCoordinates({'left': 10.0, 'top': 20.0, 'width': 100.0, 'height': 150.0});

      expect(container.read(onboardingProvider).humanTargetFaceCoordinates!['left'], 10.0);
      expect(container.read(onboardingProvider).humanTargetFaceCoordinates!['height'], 150.0);
    });

    test('setBiometricsVerified stores verification flag', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      expect(container.read(onboardingProvider).isBiometricsVerified, false);

      notifier.setBiometricsVerified(true);
      expect(container.read(onboardingProvider).isBiometricsVerified, true);

      notifier.setBiometricsVerified(false);
      expect(container.read(onboardingProvider).isBiometricsVerified, false);
    });

    test('step transitions include livenessVerification', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setStep(OnboardingStep.livenessVerification);
      expect(container.read(onboardingProvider).step, OnboardingStep.livenessVerification);
    });

    test('initial state has no coordinates and unverified biometrics', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final state = container.read(onboardingProvider);

      expect(state.humanTargetFaceCoordinates, isNull);
      expect(state.isBiometricsVerified, false);
    });

    test('reset clears biometrics fields', () {
      final container = createContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingProvider.notifier);

      notifier.setHumanTargetFaceCoordinates({'left': 10.0, 'top': 20.0, 'width': 100.0, 'height': 150.0});
      notifier.setBiometricsVerified(true);
      notifier.setStep(OnboardingStep.livenessVerification);

      notifier.reset();

      expect(container.read(onboardingProvider).humanTargetFaceCoordinates, isNull);
      expect(container.read(onboardingProvider).isBiometricsVerified, false);
      expect(container.read(onboardingProvider).step, OnboardingStep.welcome);
    });
  });
}
