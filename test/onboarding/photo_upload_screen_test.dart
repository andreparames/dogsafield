import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/onboarding/presentation/photo_upload_screen.dart';
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
}
