import 'package:flutter/material.dart';
import 'package:dogsafield/i18n/strings.g.dart';

class FeedbackDialog extends StatefulWidget {
  const FeedbackDialog({required this.onSubmit, super.key});

  final Future<void> Function(String message) onSubmit;

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.t.feedback.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: context.t.feedback.hint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.t.feedback.cancel),
        ),
        FilledButton(
          onPressed: () async {
            final message = _controller.text.trim();
            if (message.isEmpty) return;
            try {
              await widget.onSubmit(message);
              if (!context.mounted) return;
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              messenger.showSnackBar(
                SnackBar(content: Text(context.t.feedback.success)),
              );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.t.feedback.failed)),
              );
            }
          },
          child: Text(context.t.feedback.send),
        ),
      ],
    );
  }
}
