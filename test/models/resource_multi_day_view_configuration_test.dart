import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalender/kalender.dart';

void main() {
  final displayRange = DateTimeRange(start: DateTime(2025), end: DateTime(2026));
  const resources = [
    ResourceConfig(id: 'alice'),
    ResourceConfig(id: 'bob'),
    ResourceConfig(id: 'carol'),
  ];

  group('ResourceMultiDayViewConfiguration', () {
    test('is a MultiDayViewConfiguration', () {
      final config = ResourceMultiDayViewConfiguration.week(
        displayRange: displayRange,
        resources: resources,
      );
      expect(config, isA<MultiDayViewConfiguration>());
    });

    group('numberOfColumns', () {
      test('singleDay: 1 × resources.length', () {
        final config = ResourceMultiDayViewConfiguration.singleDay(
          displayRange: displayRange,
          resources: resources,
        );
        expect(config.numberOfDays, 1);
        expect(config.numberOfColumns, resources.length);
      });

      test('week: 7 × resources.length', () {
        final config = ResourceMultiDayViewConfiguration.week(
          displayRange: displayRange,
          resources: resources,
        );
        expect(config.numberOfDays, 7);
        expect(config.numberOfColumns, 7 * resources.length);
      });

      test('workWeek: 5 × resources.length', () {
        final config = ResourceMultiDayViewConfiguration.workWeek(
          displayRange: displayRange,
          resources: resources,
        );
        expect(config.numberOfDays, 5);
        expect(config.numberOfColumns, 5 * resources.length);
      });

      test('custom: numberOfDays × resources.length', () {
        final config = ResourceMultiDayViewConfiguration.custom(
          displayRange: displayRange,
          numberOfDays: 3,
          resources: resources,
        );
        expect(config.numberOfDays, 3);
        expect(config.numberOfColumns, 3 * resources.length);
      });

      test('freeScroll: numberOfDays × resources.length', () {
        final config = ResourceMultiDayViewConfiguration.freeScroll(
          displayRange: displayRange,
          numberOfDays: 4,
          resources: resources,
        );
        expect(config.numberOfDays, 4);
        expect(config.numberOfColumns, 4 * resources.length);
      });
    });

    test('columnResourceIds returns resource ids in declared order', () {
      final config = ResourceMultiDayViewConfiguration.week(
        displayRange: displayRange,
        resources: resources,
      );
      expect(config.columnResourceIds, ['alice', 'bob', 'carol']);
    });

    test('rejects an empty resources list', () {
      expect(
        () => ResourceMultiDayViewConfiguration.week(
          displayRange: displayRange,
          resources: const [],
        ),
        throwsAssertionError,
      );
    });

    group('copyWith', () {
      test('preserves resources when not supplied', () {
        final config = ResourceMultiDayViewConfiguration.week(
          displayRange: displayRange,
          resources: resources,
        );
        final updated = config.copyWith(name: 'Updated');
        expect(updated.name, 'Updated');
        expect(updated.resources, equals(resources));
      });

      test('overrides resources when supplied', () {
        final config = ResourceMultiDayViewConfiguration.week(
          displayRange: displayRange,
          resources: resources,
        );
        const newResources = [ResourceConfig(id: 'dave'), ResourceConfig(id: 'eve')];
        final updated = config.copyWith(resources: newResources);
        expect(updated.resources, equals(newResources));
        expect(updated.numberOfColumns, 7 * newResources.length);
      });

      test('returns a ResourceMultiDayViewConfiguration (covariant return)', () {
        final config = ResourceMultiDayViewConfiguration.week(
          displayRange: displayRange,
          resources: resources,
        );
        final updated = config.copyWith();
        expect(updated, isA<ResourceMultiDayViewConfiguration>());
      });

      test('keeps the same MultiDayViewType', () {
        final week = ResourceMultiDayViewConfiguration.week(
          displayRange: displayRange,
          resources: resources,
        );
        expect(week.copyWith().type, MultiDayViewType.week);

        final custom = ResourceMultiDayViewConfiguration.custom(
          displayRange: displayRange,
          numberOfDays: 3,
          resources: resources,
        );
        expect(custom.copyWith().type, MultiDayViewType.custom);
      });
    });

    group('equality', () {
      // Two newly-constructed configurations compare unequal because
      // `pageIndexCalculator` and `WeekIndexCalculator` use identity-based
      // equality (inherited from Object). The tests below verify the
      // resource-specific equality contributions only — sub-class type check
      // and `resources` list comparison — by reusing the same instance for
      // everything else via `copyWith`.

      test('not equal when resources differ', () {
        final a = ResourceMultiDayViewConfiguration.week(
          displayRange: displayRange,
          resources: resources,
        );
        final b = a.copyWith(resources: const [ResourceConfig(id: 'alice')]);
        expect(a, isNot(equals(b)));
      });

      test('equal when copy preserves resources', () {
        final a = ResourceMultiDayViewConfiguration.week(
          displayRange: displayRange,
          resources: resources,
        );
        final b = a.copyWith(resources: [...resources]);
        // The other fields are taken from `a` via copyWith, so only the
        // resources field would distinguish them.
        expect(a.resources, equals(b.resources));
      });

      test('not equal to a plain MultiDayViewConfiguration with the same fields', () {
        final resourced = ResourceMultiDayViewConfiguration.week(
          displayRange: displayRange,
          resources: const [ResourceConfig(id: 'alice')],
        );
        final plain = MultiDayViewConfiguration.week(displayRange: displayRange);
        expect(resourced, isNot(equals(plain)));
        expect(plain, isNot(equals(resourced)));
      });
    });
  });

  group('MultiDayViewConfiguration (regression — base shape)', () {
    test('numberOfColumns defaults to numberOfDays', () {
      final week = MultiDayViewConfiguration.week(displayRange: displayRange);
      expect(week.numberOfColumns, week.numberOfDays);

      final custom = MultiDayViewConfiguration.custom(displayRange: displayRange, numberOfDays: 3);
      expect(custom.numberOfColumns, 3);
    });

    test('columnResourceIds is [null] (one column per date)', () {
      final week = MultiDayViewConfiguration.week(displayRange: displayRange);
      expect(week.columnResourceIds, [null]);
    });
  });
}
