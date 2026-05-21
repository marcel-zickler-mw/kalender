import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/widgets/event_tiles/tiles/day_tile.dart' show DayEventTile;
import 'package:kalender/src/widgets/events_widgets/day_events_widget.dart';

import '../utilities.dart';

/// Widget tests covering the resource lanes feature.
///
/// These tests exercise the `ResourceMultiDayViewConfiguration` end-to-end:
/// column fan-out, per-lane event filtering, drag-target lane gating, and the
/// `dates × resources` day-separator count.
void main() {
  late DefaultEventsController eventsController;
  late CalendarController calendarController;
  late CalendarCallbacks callbacks;

  final start = DateTime(2025, 3, 24);
  final displayRange = DateTimeRange(start: start, end: start.add(const Duration(days: 7)));
  const resources = [
    ResourceConfig(id: 'alice'),
    ResourceConfig(id: 'bob'),
  ];

  final tileComponents = TileComponents(
    tileBuilder: (event, tileRange) => Container(
      key: ValueKey(event.id),
      color: Colors.red,
    ),
  );
  final scheduleComponents = ScheduleTileComponents(
    tileBuilder: (event, tileRange) => Container(
      key: ValueKey(event.id),
      color: Colors.blue,
    ),
  );

  setUp(() {
    eventsController = DefaultEventsController();
    calendarController = CalendarController();
    callbacks = CalendarCallbacks(
      onEventCreated: eventsController.addEvent,
      onEventChanged: (event, updatedEvent) => eventsController.updateEvent(event: event, updatedEvent: updatedEvent),
    );
  });

  Future<void> pumpResourceCalendar(WidgetTester tester, MultiDayViewConfiguration viewConfiguration) {
    return pumpAndSettleWithMaterialApp(
      tester,
      CalendarView(
        eventsController: eventsController,
        calendarController: calendarController,
        viewConfiguration: viewConfiguration,
        callbacks: callbacks,
        body: CalendarBody(
          multiDayTileComponents: tileComponents,
          monthTileComponents: tileComponents,
          scheduleTileComponents: scheduleComponents,
        ),
      ),
    );
  }

  /// Returns the [DayEventsColumn] widget for [resourceId] on the visible page.
  ///
  /// Asserts that exactly one such column exists.
  Finder columnFor(WidgetTester tester, String resourceId) {
    final matches = find.byWidgetPredicate(
      (w) => w is DayEventsColumn && w.resourceId == resourceId,
    );
    expect(matches, findsOneWidget, reason: 'should find exactly one column for resource $resourceId');
    return matches;
  }

  group('ResourceMultiDayBody - column layout', () {
    testWidgets('singleDay × 2 resources renders 2 columns', (tester) async {
      await pumpResourceCalendar(
        tester,
        ResourceMultiDayViewConfiguration.singleDay(
          displayRange: displayRange,
          initialDateTime: start,
          resources: resources,
        ),
      );

      final columns = tester.widgetList<DayEventsColumn>(find.byType(DayEventsColumn));
      expect(columns.length, 2);
      expect(columns.map((c) => c.resourceId).toSet(), {'alice', 'bob'});
    });

    testWidgets('week × 2 resources renders 14 columns', (tester) async {
      await pumpResourceCalendar(
        tester,
        ResourceMultiDayViewConfiguration.week(
          displayRange: displayRange,
          initialDateTime: start,
          resources: resources,
        ),
      );

      final columns = tester.widgetList<DayEventsColumn>(find.byType(DayEventsColumn));
      expect(columns.length, 14, reason: '7 days * 2 resources');
      // Each resource appears 7 times (one per date).
      final ids = columns.map((c) => c.resourceId).toList();
      expect(ids.where((r) => r == 'alice').length, 7);
      expect(ids.where((r) => r == 'bob').length, 7);
    });

    testWidgets('day separators are drawn between every resource column', (tester) async {
      await pumpResourceCalendar(
        tester,
        ResourceMultiDayViewConfiguration.week(
          displayRange: displayRange,
          initialDateTime: start,
          resources: resources,
        ),
      );

      // The body draws `numberOfColumns + 1` separators for non-freeScroll views.
      const expectedColumns = 7 * 2;
      expect(find.byType(DaySeparator), findsNWidgets(expectedColumns + 1));
    });

    testWidgets('non-resource MultiDayViewConfiguration still renders one column per date', (tester) async {
      await pumpResourceCalendar(
        tester,
        MultiDayViewConfiguration.week(displayRange: displayRange, initialDateTime: start),
      );

      final columns = tester.widgetList<DayEventsColumn>(find.byType(DayEventsColumn));
      expect(columns.length, 7);
      // None are bound to a resource.
      expect(columns.every((c) => c.resourceId == null), isTrue);
      // 7 day separators + 1 trailing.
      expect(find.byType(DaySeparator), findsNWidgets(8));
    });
  });

  group('ResourceMultiDayBody - event filtering', () {
    testWidgets('a resource-bound event renders only in its lane', (tester) async {
      final shift = ResourceCalendarEvent(
        dateTimeRange: DateTimeRange(
          start: start.copyWith(hour: 9),
          end: start.copyWith(hour: 10),
        ),
        resourceId: 'alice',
      );
      eventsController.addEvent(shift);

      await pumpResourceCalendar(
        tester,
        ResourceMultiDayViewConfiguration.singleDay(
          displayRange: displayRange,
          initialDateTime: start,
          resources: resources,
        ),
      );

      // Exactly one tile rendered overall.
      expect(find.byKey(DayEventTile.tileKey(shift.id)), findsOneWidget);

      final aliceColumn = columnFor(tester, 'alice');
      final bobColumn = columnFor(tester, 'bob');
      expect(
        find.descendant(of: aliceColumn, matching: find.byKey(DayEventTile.tileKey(shift.id))),
        findsOneWidget,
        reason: "Alice-bound shift should appear in Alice's lane",
      );
      expect(
        find.descendant(of: bobColumn, matching: find.byKey(DayEventTile.tileKey(shift.id))),
        findsNothing,
        reason: "Alice-bound shift should not appear in Bob's lane",
      );
    });

    testWidgets('a resource-agnostic event renders in every lane', (tester) async {
      final holiday = CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: start.copyWith(hour: 9),
          end: start.copyWith(hour: 17),
        ),
      );
      eventsController.addEvent(holiday);

      await pumpResourceCalendar(
        tester,
        ResourceMultiDayViewConfiguration.singleDay(
          displayRange: displayRange,
          initialDateTime: start,
          resources: resources,
        ),
      );

      // The same event renders once per lane.
      expect(find.byKey(DayEventTile.tileKey(holiday.id)), findsNWidgets(2));
    });

    testWidgets('events with unknown resourceIds are hidden', (tester) async {
      final orphan = ResourceCalendarEvent(
        dateTimeRange: DateTimeRange(
          start: start.copyWith(hour: 9),
          end: start.copyWith(hour: 10),
        ),
        resourceId: 'mallory',
      );
      eventsController.addEvent(orphan);

      await pumpResourceCalendar(
        tester,
        ResourceMultiDayViewConfiguration.singleDay(
          displayRange: displayRange,
          initialDateTime: start,
          resources: resources,
        ),
      );

      // No lane matches the resourceId; the event is hidden everywhere.
      expect(find.byKey(DayEventTile.tileKey(orphan.id)), findsNothing);
    });

    testWidgets('mixed events: bound + agnostic together render correctly', (tester) async {
      final shift = ResourceCalendarEvent(
        dateTimeRange: DateTimeRange(
          start: start.copyWith(hour: 9),
          end: start.copyWith(hour: 10),
        ),
        resourceId: 'bob',
      );
      final holiday = CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: start.copyWith(hour: 12),
          end: start.copyWith(hour: 13),
        ),
      );
      eventsController.addEvents([shift, holiday]);

      await pumpResourceCalendar(
        tester,
        ResourceMultiDayViewConfiguration.singleDay(
          displayRange: displayRange,
          initialDateTime: start,
          resources: resources,
        ),
      );

      // Bob-bound shift: 1 tile total.
      expect(find.byKey(DayEventTile.tileKey(shift.id)), findsOneWidget);
      // Holiday: 1 per lane = 2.
      expect(find.byKey(DayEventTile.tileKey(holiday.id)), findsNWidgets(2));
    });
  });

  group('ResourceMultiDayBody - dynamic updates', () {
    testWidgets('moving an event across lanes via copyWith updates rendering', (tester) async {
      final shift = ResourceCalendarEvent(
        dateTimeRange: DateTimeRange(
          start: start.copyWith(hour: 9),
          end: start.copyWith(hour: 10),
        ),
        resourceId: 'alice',
      );
      eventsController.addEvent(shift);

      await pumpResourceCalendar(
        tester,
        ResourceMultiDayViewConfiguration.singleDay(
          displayRange: displayRange,
          initialDateTime: start,
          resources: resources,
        ),
      );

      expect(
        find.descendant(of: columnFor(tester, 'alice'), matching: find.byKey(DayEventTile.tileKey(shift.id))),
        findsOneWidget,
      );

      // Move shift to Bob's lane.
      final moved = shift.copyWith(resourceId: 'bob');
      eventsController.updateEvent(event: shift, updatedEvent: moved);
      await tester.pump();

      expect(
        find.descendant(of: columnFor(tester, 'alice'), matching: find.byKey(DayEventTile.tileKey(shift.id))),
        findsNothing,
        reason: "After move, shift should no longer appear in Alice's lane",
      );
      expect(
        find.descendant(of: columnFor(tester, 'bob'), matching: find.byKey(DayEventTile.tileKey(shift.id))),
        findsOneWidget,
        reason: "After move, shift should appear in Bob's lane",
      );
    });

    testWidgets('adding a resource event after layout updates the correct lane', (tester) async {
      await pumpResourceCalendar(
        tester,
        ResourceMultiDayViewConfiguration.singleDay(
          displayRange: displayRange,
          initialDateTime: start,
          resources: resources,
        ),
      );

      expect(
        find.descendant(of: columnFor(tester, 'alice'), matching: find.byType(DayEventTile)),
        findsNothing,
      );

      final shift = ResourceCalendarEvent(
        dateTimeRange: DateTimeRange(
          start: start.copyWith(hour: 9),
          end: start.copyWith(hour: 10),
        ),
        resourceId: 'alice',
      );
      eventsController.addEvent(shift);
      await tester.pump();

      expect(
        find.descendant(of: columnFor(tester, 'alice'), matching: find.byKey(DayEventTile.tileKey(shift.id))),
        findsOneWidget,
      );
    });
  });

  group('ResourceMultiDayBody - new event creation', () {
    final preciseInteraction = CalendarInteraction(
      inputMode: InputMode.precise,
      createEventGesture: CreateEventGesture.tap,
      modifyEventGesture: CreateEventGesture.tap,
    );

    testWidgets('drag-created event in a lane is tagged with that lane', (tester) async {
      await pumpAndSettleWithMaterialApp(
        tester,
        CalendarView(
          eventsController: eventsController,
          calendarController: calendarController,
          viewConfiguration: ResourceMultiDayViewConfiguration.singleDay(
            displayRange: displayRange,
            initialDateTime: start,
            initialTimeOfDay: const TimeOfDay(hour: 5, minute: 0),
            initialHeightPerMinute: 1,
            resources: resources,
          ),
          callbacks: callbacks,
          body: CalendarBody(
            interaction: preciseInteraction,
            multiDayTileComponents: tileComponents,
            monthTileComponents: tileComponents,
            scheduleTileComponents: scheduleComponents,
          ),
        ),
      );

      // Drag inside Bob's column to create a new event.
      final bobColumn = columnFor(tester, 'bob');
      final centre = tester.getCenter(bobColumn);
      await tester.dragFrom(centre, const Offset(0, 80));
      await tester.pumpAndSettle();

      expect(eventsController.events.length, 1, reason: 'A new event should have been created');
      final created = eventsController.events.single;
      expect(created, isA<ResourceCalendarEvent>(), reason: 'Lane-created events should be ResourceCalendarEvent');
      expect((created as ResourceCalendarEvent).resourceId, 'bob');
    });
  });
}
