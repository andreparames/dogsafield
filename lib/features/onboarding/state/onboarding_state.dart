import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/dog.dart';
import '../../../shared/models/user_profile.dart';

enum OnboardingStep {
  welcome,
  photoUpload,
  profileForm,
  icebreaker,
  safetyBoundaries,
  complete,
}

const _unset = Object();

class OnboardingState {
  final OnboardingStep step;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;
  final String? submissionError;
  final String? photoUrl;
  final UserProfile? userProfile;
  final Dog? dog;

  const OnboardingState({
    this.step = OnboardingStep.welcome,
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
    this.submissionError,
    this.photoUrl,
    this.userProfile,
    this.dog,
  });

  OnboardingState copyWith({
    OnboardingStep? step,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
    Object? submissionError = _unset,
    String? photoUrl,
    UserProfile? userProfile,
    Dog? dog,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionError: identical(submissionError, _unset)
          ? this.submissionError
          : submissionError as String?,
      photoUrl: photoUrl ?? this.photoUrl,
      userProfile: userProfile ?? this.userProfile,
      dog: dog ?? this.dog,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setStep(OnboardingStep step) => state = state.copyWith(step: step, error: null);
  void setLoading(bool v) => state = state.copyWith(isLoading: v);
  void setError(String e) => state = state.copyWith(error: e);
  void setSubmitting(bool v) => state = state.copyWith(isSubmitting: v, submissionError: v ? null : _unset);
  void setSubmissionError(String e) => state = state.copyWith(submissionError: e);
  void setPhotoUrl(String url) => state = state.copyWith(photoUrl: url);

  void setUserProfile(UserProfile profile) {
    state = state.copyWith(userProfile: profile);
  }

  void setDog(Dog dog) {
    state = state.copyWith(dog: dog);
  }

  void initFromAuth(String id, String email, String? displayName) {
    if (state.userProfile != null) return;
    state = state.copyWith(
      userProfile: UserProfile(id: id, email: email, displayName: displayName),
    );
  }

  void reset() => state = const OnboardingState();
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});
