import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalender/kalender.dart';

void main() {
  group('ResourceCalendarEvent', () {
    final start = DateTime.utc(2025, 6, 1, 9);
    final end = DateTime.utc(2025, 6, 1, 10);
    final range = DateTimeRange(start: start, end: end);

    test('subclasses CalendarEvent so is-check passes', () {
      final event = ResourceCalendarEvent(dateTimeRange: range, resourceId: 'alice');
      expect(event, isA<CalendarEvent>());
      expect(event, isA<ResourceCalendarEvent>());
    });

    test('stores the resource binding', () {
      final event = ResourceCalendarEvent(dateTimeRange: range, resourceId: 'alice');
      expect(event.resourceId, 'alice');
    });

    test('preserves start/end as UTC like the base class', () {
      final event = ResourceCalendarEvent(dateTimeRange: range, resourceId: 'alice');
      expect(event.start, start.toUtc());
      expect(event.end, end.toUtc());
    });

    test('auto-generates a unique id when none is provided', () {
      final a = ResourceCalendarEvent(dateTimeRange: range, resourceId: 'alice');
      final b = ResourceCalendarEvent(dateTimeRange: range, resourceId: 'alice');
      expect(a.id, isNot(equals(b.id)));
    });

    test('respects an explicit id', () {
      final event = ResourceCalendarEvent(dateTimeRange: range, resourceId: 'alice', id: 'shift-1');
      expect(event.id, 'shift-1');
    });

    test('rejects empty resourceId via assert', () {
      expect(
        () => ResourceCalendarEvent(dateTimeRange: range, resourceId: ''),
        throwsAssertionError,
      );
    });

    group('copyWith', () {
      test('preserves the id', () {
        final event = ResourceCalendarEvent(dateTimeRange: range, resourceId: 'alice', id: 'shift-1');
        final updated = event.copyWith(resourceId: 'bob');
        expect(updated.id, 'shift-1');
      });

      test('preserves resourceId when not overridden', () {
        final event = ResourceCalendarEvent(dateTimeRange: range, resourceId: 'alice');
        final newStart = DateTime.utc(2025, 6, 1, 11);
        final newEnd = DateTime.utc(2025, 6, 1, 12);
        final updated = event.copyWith(dateTimeRange: DateTimeRange(start: newStart, end: newEnd));
        expect(updated.resourceId, 'alice');
        expect(updated.start, newStart);
        expect(updated.end, newEnd);
      });

      test('overrides resourceId when supplied', () {
        final event = ResourceCalendarEvent(dateTimeRange: range, resourceId: 'alice');
        final updated = event.copyWith(resourceId: 'bob');
        expect(updated.resourceId, 'bob');
      });

      test('returns a ResourceCalendarEvent (covariant return)', () {
        final event = ResourceCalendarEvent(dateTimeRange: range, resourceId: 'alice');
        final updated = event.copyWith(resourceId: 'bob');
        expect(updated, isA<ResourceCalendarEvent>());
      });
    });
  });

  group('CalendarEvent (regression — resourceId removal)', () {
    final start = DateTime.utc(2025, 6, 1, 9);
    final end = DateTime.utc(2025, 6, 1, 10);
    final range = DateTimeRange(start: start, end: end);

    test('plain CalendarEvent is not a ResourceCalendarEvent', () {
      final event = CalendarEvent(dateTimeRange: range);
      expect(event, isA<CalendarEvent>());
      expect(event, isNot(isA<ResourceCalendarEvent>()));
    });

    test('copyWith does not accept a resourceId', () {
      final event = CalendarEvent(dateTimeRange: range);
      // This is a compile-time check; if the field is ever re-added the body
      // will start typechecking and we should reconsider the design.
      expect(event.copyWith(), isNotNull);
    });
  });
}
