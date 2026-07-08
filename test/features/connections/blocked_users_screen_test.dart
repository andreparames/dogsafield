import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/connections/presentation/blocked_users_screen.dart';
import '../../helpers/test_utils.dart';

void main() {
  testWidgets('blocked users screen shows empty state', (tester) async {
    fakeConnectionRepository.blockedUsers = [];

    await tester.pumpWidget(createTestApp(const BlockedUsersScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No blocked users'), findsOneWidget);
  });

  testWidgets('blocked users screen shows list of blocked users', (tester) async {
    fakeConnectionRepository.blockedUsers = [
      {'user_id_a': 'me', 'user_id_b': 'target1', 'block_tier': 1, 'are_packmates': false},
    ];

    await tester.pumpWidget(createTestApp(const BlockedUsersScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No blocked users'), findsNothing);
    expect(find.text('Unblock'), findsOneWidget);
  });
}