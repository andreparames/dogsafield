import 'package:flutter/material.dart';

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
            try {
              await widget.onSubmit(message);
              if (!context.mounted) return;
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              messenger.showSnackBar(
                const SnackBar(content: Text('Thanks for your feedback!')),
              );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to send feedback. Please try again.')),
              );
            }
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}
