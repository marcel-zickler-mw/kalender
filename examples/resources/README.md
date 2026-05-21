# Resource Lanes

End-to-end example of building a workforce-scheduling UI on top of Kalender's
resource lanes. The structure mirrors what an actual app integration looks
like: a top toolbar for navigation, a main calendar area with a resource
header strip aligned to its lanes, and a sidebar panel for toggling which
resources are visible.

A typical use case: scheduling employees, vehicles, meeting rooms, hospital
beds, or any other entity that owns a column of bookable time.

## What this example demonstrates

- **`ResourceMultiDayViewConfiguration.singleDay`** rendering one lane per
  resource and a `dates × resources` grid that scales with the visible set.
- **Two-way navigation** — the prev/today/next buttons drive the calendar via
  `CalendarController.jumpToDate`, and horizontal swipe-paging in the body
  pushes back through `CalendarController.visibleDateTimeRange`. The toolbar
  label uses a `ValueListenableBuilder` on that notifier so swiping a page
  updates the label automatically.
- **Dynamic resource visibility** — toggling a checkbox in the sidebar
  removes that resource from the `resources:` list passed to the view
  configuration. The configuration omits `initialDateTime`, so kalender's
  default `kDefaultToDaily` strategy preserves the visible date across the
  controller recreation.
- **Custom resource header strip** rendered outside the `CalendarView` and
  aligned to the lanes via a fixed-width timeline gutter.
- **`ResourceCalendarEvent` subclass** (`Shift`) — events bound to a single
  lane. The framework hands back a `ResourceCalendarEvent` from drag-create
  inside a lane; the example promotes it to a typed `Shift` in
  `onEventCreated`.
- **Drag-create feedback** — a snackbar shows which resource the new event
  landed on and its time range.

## Running

From the repository root:

```bash
cd examples/resources
flutter pub get
flutter run
```

The example expects the kalender package to live at `../../../kalender-fork/`
(matching the other `examples/*` apps). If you've cloned this fork into a
folder with a different name, update the path in `pubspec.yaml`.

## Key snippets

Bind the toolbar label to the calendar's current page so it stays in sync
with horizontal swipe-paging:

```dart
ValueListenableBuilder<DateTimeRange<DateTime>?>(
  valueListenable: calendarController.visibleDateTimeRange,
  builder: (context, range, _) {
    final date = range?.start.toLocal();
    return Text(date == null ? '' : formatDate(date));
  },
);
```

Pass the visible resources to the view configuration. Re-pass a smaller list
to hide a lane:

```dart
ResourceMultiDayViewConfiguration.singleDay(
  displayRange: yearAround(now),
  initialHeightPerMinute: 0.7,
  resources: [for (final e in visibleEmployees) ResourceConfig(id: e.id)],
);
```

Bind an event to a lane by extending `ResourceCalendarEvent`:

```dart
class Shift extends ResourceCalendarEvent {
  Shift({
    required super.dateTimeRange,
    required super.resourceId,
    required this.label,
  });
  final String label;
}
```

Align a custom header strip with the lanes by overriding the timeline with a
known width:

```dart
CalendarComponents(
  multiDayComponents: MultiDayComponents(
    bodyComponents: MultiDayBodyComponents(
      timeline: _fixedWidthTimeline,
      prototypeTimeLine: _fixedWidthPrototypeTimeline,
    ),
  ),
);
```

Promote a drag-created event to your typed subclass in `onEventCreated`:

```dart
onEventCreated: (event) {
  if (event is ResourceCalendarEvent) {
    eventsController.addEvent(Shift(
      dateTimeRange: event.dateTimeRange,
      resourceId: event.resourceId,
      label: 'New shift',
    ));
  }
}
```
