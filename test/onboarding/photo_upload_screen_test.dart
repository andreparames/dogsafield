import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/onboarding/presentation/photo_upload_screen.dart';
import 'package:dogsafield/features/onboarding/state/onboarding_state.dart';
import '../helpers/test_utils.dart';

void main() {
  testWidgets('renders upload screen with camera and gallery buttons', (WidgetTester tester) async {
    await tester.pumpWidget(createTestApp(const PhotoUploadScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Verification Photo'), findsOneWidget);
    expect(find.text('Upload a photo of you and your dog together'), findsOneWidget);
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Choose from Gallery'), findsOneWidget);
  });

  testWidgets('saves humanTargetFaceCoordinates and transitions to liveness on valid detection',
      (WidgetTester tester) async {
    final container = await createContainerWithCache(additionalOverrides: [
      // default overrides from createContainerWithCache handle auth etc.
    ]);
    addTearDown(container.dispose);
    final notifier = container.read(onboardingProvider.notifier);

    notifier.setLocalPhotoPath('/tmp/photo.jpg');
    notifier.setHumanTargetFaceCoordinates({
      'left': 10.0,
      'top': 20.0,
      'width': 100.0,
      'height': 150.0,
    });
    notifier.setStep(OnboardingStep.livenessVerification);

    final state = container.read(onboardingProvider);
    expect(state.localPhotoPath, '/tmp/photo.jpg');
    expect(state.humanTargetFaceCoordinates, isNotNull);
    expect(state.humanTargetFaceCoordinates!['left'], 10.0);
    expect(state.humanTargetFaceCoordinates!['top'], 20.0);
    expect(state.humanTargetFaceCoordinates!['width'], 100.0);
    expect(state.humanTargetFaceCoordinates!['height'], 150.0);
    expect(state.step, OnboardingStep.livenessVerification);
  });
}
