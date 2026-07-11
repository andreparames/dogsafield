import 'package:flutter/material.dart';
import 'package:dogsafield/i18n/strings.g.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.t.account.upgrade.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, size: 80, color: Colors.amber.shade400),
              const SizedBox(height: 24),
              Text(
                context.t.account.upgrade.heading,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                context.t.account.upgrade.description,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.t.account.upgrade.comingSoon)),
                    );
                  },
                  icon: const Icon(Icons.lock_open),
                  label: Text(context.t.common.subscribe),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
