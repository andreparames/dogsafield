import 'package:flutter/material.dart';
import 'package:dogsafield/i18n/strings.g.dart';

class TrialLimitSheet extends StatelessWidget {
  final int used;
  final int maxFree;

  const TrialLimitSheet({
    super.key,
    required this.used,
    this.maxFree = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = (maxFree - used).clamp(0, maxFree);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.t.account.trialRsvps,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(label: context.t.account.used, value: '$used'),
              const SizedBox(width: 24),
              _Stat(label: context.t.account.remaining, value: '$remaining'),
              const SizedBox(width: 24),
              _Stat(label: context.t.account.total, value: '$maxFree'),
            ],
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: maxFree > 0 ? (used / maxFree).clamp(0.0, 1.0) : 0.0,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 24),
          Text(
            remaining > 0
                ? context.t.account.rsvpLimit.remaining(remaining: remaining)
                : context.t.account.rsvpLimit.exhausted,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          if (remaining <= 0)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.star),
                label: Text(context.t.common.upgrade),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: theme.textTheme.headlineMedium),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
