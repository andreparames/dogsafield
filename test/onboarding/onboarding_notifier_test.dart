import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/shared/models/dog.dart';
import 'package:dogsafield/shared/models/user_profile.dart';
import 'package:dogsafield/features/onboarding/state/onboarding_state.dart';

void main() {
  group('OnboardingNotifier', () {
    late OnboardingNotifier notifier;

    setUp(() {
      notifier = OnboardingNotifier();
    });

    test('starts at welcome step', () {
      expect(notifier.state.step, OnboardingStep.welcome);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
      expect(notifier.state.isSubmitting, false);
      expect(notifier.state.submissionError, isNull);
      expect(notifier.state.photoUrl, isNull);
      expect(notifier.state.dog, isNull);
    });

    test('setStep transitions to correct step', () {
      notifier.setStep(OnboardingStep.photoUpload);
      expect(notifier.state.step, OnboardingStep.photoUpload);

      notifier.setStep(OnboardingStep.profileForm);
      expect(notifier.state.step, OnboardingStep.profileForm);
    });

    test('setStep clears error', () {
      notifier.setError('something went wrong');
      expect(notifier.state.error, 'something went wrong');

      notifier.setStep(OnboardingStep.icebreaker);
      expect(notifier.state.error, isNull);
    });

    test('setLoading toggles loading state', () {
      notifier.setLoading(true);
      expect(notifier.state.isLoading, true);

      notifier.setLoading(false);
      expect(notifier.state.isLoading, false);
    });

    test('setSubmitting toggles submitting state and clears submissionError', () {
      notifier.setSubmissionError('previous error');
      notifier.setSubmitting(true);
      expect(notifier.state.isSubmitting, true);
      expect(notifier.state.submissionError, isNull);

      notifier.setSubmitting(false);
      expect(notifier.state.isSubmitting, false);
    });

    test('setSubmissionError stores error without affecting submitting', () {
      notifier.setSubmitting(true);
      notifier.setSubmissionError('upload failed');
      expect(notifier.state.submissionError, 'upload failed');
      expect(notifier.state.isSubmitting, true);
    });

    test('setPhotoUrl stores url', () {
      notifier.setPhotoUrl('https://example.com/photo.jpg');
      expect(notifier.state.photoUrl, 'https://example.com/photo.jpg');
    });

    test('setDog stores dog', () {
      final dog = Dog(id: '1', ownerId: 'u1', name: 'Buddy');
      notifier.setDog(dog);
      expect(notifier.state.dog, dog);
      expect(notifier.state.dog!.name, 'Buddy');
    });

    test('setUserProfile stores profile', () {
      notifier.setUserProfile(
        UserProfile(id: 'u1', email: 'a@b.com'),
      );
      expect(notifier.state.userProfile, isNotNull);
      expect(notifier.state.userProfile!.email, 'a@b.com');
    });

    test('reset returns to initial state', () {
      notifier.setStep(OnboardingStep.complete);
      notifier.setPhotoUrl('https://example.com/p.jpg');
      notifier.setDog(Dog(id: '1', ownerId: 'u1', name: 'Buddy'));
      notifier.setLoading(true);
      notifier.setSubmitting(true);
      notifier.setSubmissionError('some error');

      notifier.reset();

      expect(notifier.state.step, OnboardingStep.welcome);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.isSubmitting, false);
      expect(notifier.state.submissionError, isNull);
      expect(notifier.state.photoUrl, isNull);
      expect(notifier.state.dog, isNull);
    });

    test('setDog replaces previous dog', () {
      notifier.setDog(Dog(id: '1', ownerId: 'u1', name: 'Buddy'));
      notifier.setDog(Dog(id: '2', ownerId: 'u1', name: 'Max', age: 5));

      expect(notifier.state.dog!.id, '2');
      expect(notifier.state.dog!.name, 'Max');
      expect(notifier.state.dog!.age, 5);
    });
  });
}
