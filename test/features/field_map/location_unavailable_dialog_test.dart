import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogsafield/features/field_map/presentation/location_unavailable_dialog.dart';
import 'package:dogsafield/features/field_map/state/region_providers.dart';
import 'package:dogsafield/shared/models/region.dart';
import 'package:dogsafield/i18n/strings.g.dart';

import '../../helpers/test_utils.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
  });

  Widget buildDialog({
    required VoidCallback onEnableLocation,
    required ValueChanged<Region> onRegionSelected,
    List<Region> regions = const [],
    bool shouldFail = false,
  }) {
    fakeRegionRepository.regions = regions;
    fakeRegionRepository.shouldFail = shouldFail;

    return ProviderScope(
      overrides: [
        regionRepositoryProvider.overrideWithValue(fakeRegionRepository),
      ],
      child: TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => LocationUnavailableDialog(
                    onEnableLocation: onEnableLocation,
                    onRegionSelected: onRegionSelected,
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows title and body text', (tester) async {
    await tester.pumpWidget(buildDialog(
      onEnableLocation: () {},
      onRegionSelected: (_) {},
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Location Unavailable'), findsOneWidget);
    expect(find.text("We can't access your device location. You can enable it in settings, or pick a region to browse."), findsOneWidget);
  });

  testWidgets('shows Enable Location button', (tester) async {
    var tapped = false;
    await tester.pumpWidget(buildDialog(
      onEnableLocation: () => tapped = true,
      onRegionSelected: (_) {},
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Enable Location'), findsOneWidget);
    await tester.tap(find.text('Enable Location'));
    expect(tapped, isTrue);
  });

  testWidgets('shows dropdown when regions are available', (tester) async {
    final regions = [
      Region(id: '1', name: 'Lisbon', centerLatitude: 38.7, centerLongitude: -9.1, radiusKm: 20),
      Region(id: '2', name: 'Porto', centerLatitude: 41.1, centerLongitude: -8.6, radiusKm: 15),
    ];

    await tester.pumpWidget(buildDialog(
      onEnableLocation: () {},
      onRegionSelected: (_) {},
      regions: regions,
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Select Region'), findsOneWidget);
  });

  testWidgets('calls onRegionSelected when region is selected', (tester) async {
    Region? selected;
    final regions = [
      Region(id: '1', name: 'Lisbon', centerLatitude: 38.7, centerLongitude: -9.1, radiusKm: 20),
    ];

    await tester.pumpWidget(buildDialog(
      onEnableLocation: () {},
      onRegionSelected: (r) => selected = r,
      regions: regions,
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<Region>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lisbon'));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected!.name, 'Lisbon');
    expect(selected!.centerLatitude, 38.7);
  });

  testWidgets('hides dropdown when no regions', (tester) async {
    await tester.pumpWidget(buildDialog(
      onEnableLocation: () {},
      onRegionSelected: (_) {},
      regions: const [],
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(DropdownButtonFormField<Region>), findsNothing);
  });

  testWidgets('shows error when regions fail to load', (tester) async {
    await tester.pumpWidget(buildDialog(
      onEnableLocation: () {},
      onRegionSelected: (_) {},
      shouldFail: true,
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load regions'), findsOneWidget);
  });
}
