import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mirrors the fixed _FeedbackDialog StatefulWidget from FieldMapScreen.
class _FeedbackDialog extends StatefulWidget {
  const _FeedbackDialog({required this.onSubmit});

  final Future<void> Function(String message) onSubmit;

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Feedback'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Share your thoughts, suggestions, or report an issue...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            final message = _controller.text.trim();
            if (message.isEmpty) return;
            await widget.onSubmit(message);
            if (!context.mounted) return;
            Navigator.pop(context);
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class FeedbackDialogHost extends StatefulWidget {
  const FeedbackDialogHost({super.key});

  @override
  State<FeedbackDialogHost> createState() => _FeedbackDialogHostState();
}

class _FeedbackDialogHostState extends State<FeedbackDialogHost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _FeedbackDialog(onSubmit: _dummySubmit),
        ),
        child: const Text('Open Feedback'),
      ),
    );
  }

  static Future<void> _dummySubmit(String message) async {}
}

void main() {
  testWidgets('does not crash when dismissed after typing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FeedbackDialogHost()),
    );
    await tester.tap(find.text('Open Feedback'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('does not crash when submitted after typing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FeedbackDialogHost()),
    );
    await tester.tap(find.text('Open Feedback'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pump();

    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
  });
}
