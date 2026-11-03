import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voyara/features/home/presentation/widgets/category_chip.dart';
import 'package:voyara/features/home/presentation/widgets/category_icon.dart';

void main() {
  group('CategoryChip and CategoryIcon Widget Tests', () {
    final categories = [
      'Attraction',
      'Bird Sanctuary',
      'Cultural',
      'Fort',
      'Ghat',
      'Lake',
      'Beach',
      'Hill Station',
      'Wildlife',
      'Adventure',
      'Mall',
      'Market',
      'Mausoleum',
      'National Park',
      'Park',
      'Religious Site',
      'Stepwell',
      'Theme Park',
      'Village',
      'War Memorial',
      'Museum',
      'All',
    ];

    for (final cat in categories) {
      testWidgets('Renders $cat category chip without errors in dark mode', (
        WidgetTester tester,
      ) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: CategoryChip(
                label: cat,
                selected: false,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        expect(find.text(cat), findsOneWidget);
        expect(find.byType(CategoryIcon), findsOneWidget);

        await tester.tap(find.text(cat));
        await tester.pump();
        expect(tapped, isTrue);
      });

      testWidgets('Renders $cat category chip when selected in light mode', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: CategoryChip(label: cat, selected: true, onTap: () {}),
            ),
          ),
        );

        expect(find.text(cat), findsOneWidget);
        expect(find.byType(CategoryIcon), findsOneWidget);
      });
    }

    test('VoyaraCategoryType resolves distinct categories accurately', () {
      expect(VoyaraCategoryType.fromString('Mall'), VoyaraCategoryType.mall);
      expect(
        VoyaraCategoryType.fromString('Market'),
        VoyaraCategoryType.market,
      );
      expect(
        VoyaraCategoryType.fromString('Mausoleum'),
        VoyaraCategoryType.mausoleum,
      );
      expect(
        VoyaraCategoryType.fromString('National Park'),
        VoyaraCategoryType.nationalPark,
      );
      expect(VoyaraCategoryType.fromString('Park'), VoyaraCategoryType.park);
      expect(
        VoyaraCategoryType.fromString('Religious Site'),
        VoyaraCategoryType.religiousSite,
      );
      expect(
        VoyaraCategoryType.fromString('Stepwell'),
        VoyaraCategoryType.stepwell,
      );
      expect(
        VoyaraCategoryType.fromString('Theme Park'),
        VoyaraCategoryType.themePark,
      );
      expect(
        VoyaraCategoryType.fromString('Village'),
        VoyaraCategoryType.village,
      );
      expect(
        VoyaraCategoryType.fromString('War Memorial'),
        VoyaraCategoryType.warMemorial,
      );
      expect(
        VoyaraCategoryType.fromString('Attraction'),
        VoyaraCategoryType.attraction,
      );
      expect(
        VoyaraCategoryType.fromString('Bird Sanctuary'),
        VoyaraCategoryType.birdSanctuary,
      );
      expect(
        VoyaraCategoryType.fromString('Cultural'),
        VoyaraCategoryType.cultural,
      );
      expect(VoyaraCategoryType.fromString('Fort'), VoyaraCategoryType.fort);
      expect(VoyaraCategoryType.fromString('Ghat'), VoyaraCategoryType.ghat);
      expect(VoyaraCategoryType.fromString('Lake'), VoyaraCategoryType.lake);
      expect(VoyaraCategoryType.fromString('Beach'), VoyaraCategoryType.beach);
      expect(
        VoyaraCategoryType.fromString('Hill Station'),
        VoyaraCategoryType.hillStation,
      );
      expect(
        VoyaraCategoryType.fromString('Wildlife'),
        VoyaraCategoryType.wildlife,
      );
      expect(
        VoyaraCategoryType.fromString('Adventure'),
        VoyaraCategoryType.adventure,
      );
      expect(VoyaraCategoryType.fromString('All'), VoyaraCategoryType.all);
    });

    test('All 82 unique dataset categories map to meaningful non-compass icons', () {
      final file = File('assets/data/voyara_local.json');
      final data = jsonDecode(file.readAsStringSync()) as List<dynamic>;
      final categories = <String>{};
      for (final item in data) {
        if (item is Map && item['category'] != null) {
          categories.add(item['category'].toString());
        }
      }

      expect(categories.length, greaterThanOrEqualTo(80));

      for (final c in categories) {
        final type = VoyaraCategoryType.fromString(c);
        // None of the destination categories should fall back to compass icon (all/other)
        expect(
          type,
          isNot(VoyaraCategoryType.all),
          reason:
              'Category "$c" should have a dedicated icon rather than "All" compass',
        );
        expect(
          type,
          isNot(VoyaraCategoryType.other),
          reason:
              'Category "$c" should have a dedicated icon rather than "Other" compass',
        );
      }
    });
  });
}
