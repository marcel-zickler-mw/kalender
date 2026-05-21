# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

`AGENTS.md` contains the full project guide (layout, code style, architecture conventions). Read it when you need detail beyond the summary below.

## Commands

```bash
flutter pub get                              # install deps
dart analyze && flutter analyze              # both must pass — CI runs both
flutter test                                 # run all tests
flutter test test/path/to/file_test.dart     # run a single test file
flutter test --name 'pattern'                # run a single test by name
TZ=America/New_York flutter test             # run in a specific timezone
dart tools/test_timezones_linux.dart         # full 6-timezone matrix (Linux only, mirrors CI)
dart tools/test_timezones_linux.dart test/extensions/internal_date_time_test.dart
```

Note: the path is `tools/` (not `tool/` as AGENTS.md states).

The example apps under `examples/` (`example/`, `demo/`, `advanced_example/`, `riverpod/`, `recurrence/`, `testing/`, `web_demo/`) each have their own `pubspec.yaml` — run `flutter pub get` inside the example you want to launch.

## Architecture — the parts that span multiple files

**Three views, one orchestrator.** `CalendarView` (`lib/src/calendar_view.dart`) is the entry widget; `CalendarBody` and `CalendarHeader` `switch` on the active `ViewController` subtype (`MultiDayViewController` / `MonthViewController` / `ScheduleViewController`) to pick the right body/header widget. Adding a view means adding all four pieces: `ViewController`, `ViewConfiguration`, body widget, header widget.

**State flows exclusively through InheritedWidgets** in `lib/src/models/providers/calendar_provider.dart` — no Provider, Riverpod, or BLoC. Key providers: `CalendarControllerProvider`, `EventsControllerProvider`, `Components`, `TileComponentProvider`, `Callbacks`, `Interaction`, `Snapping`, `HeightPerMinute`, `LocaleProvider`, `LocationProvider`. Widget tests use `TestProvider` from `test/utilities.dart` to wire all of these up at once.

**UTC storage + wall-clock arithmetic.** `CalendarEvent.start`/`.end` are always UTC. DST-safe day/hour math goes through `InternalDateTime` / `InternalDateTimeRange` (`lib/src/extensions/`), which take a `Location` from the `timezone` package. Don't do `DateTime` arithmetic directly on event timestamps — use the internal extensions, or you will break across DST transitions.

**Timezone-sensitive tests must use `testWithTimeZones()`** from `test/utilities.dart`, plus the shared `datesToTest` / `locationsToTest` lists. CI runs the matrix across 6 timezones (America/New_York, Europe/London, Asia/Tokyo, Australia/Sydney, Africa/Johannesburg, UTC) — a test that passes locally in one TZ can fail in another.

**Events extend `CalendarEvent` by subclassing** (no generic type parameter since v0.16.0). Subclasses must override `copyWith()`, `==`, `hashCode`, and `layoutEquals()` (the last is used to skip re-layout when an event's visual footprint hasn't changed).

**Event layout is pluggable** via `EventLayoutStrategy` typedef on `VerticalConfiguration`. Built-ins: `overlapLayoutStrategy`, `sideBySideLayoutStrategy`. Layouts are cached per (date, heightPerMinute, timeRange) by `EventLayoutDelegateCache`.

**Drag & drop** uses native `Draggable`/`LongPressDraggable` for existing events and the `NewDraggable` mixin for creation. Gestures are platform-aware (`CreateEventGesture`): desktop = tap, mobile = long-press. Drag targets are split per view: `VerticalDragTarget`, `HorizontalDragTarget`, `ScheduleDragTarget`.

## Code style enforced by lints

`flutter_lints` + strict-inference/strict-raw-types. Formatter page width is **120**. Hard rules that get tripped most often:
- `always_use_package_imports` — never use relative imports
- `require_trailing_commas` on multi-line args
- `prefer_single_quotes`, `prefer_const_constructors`, `prefer_final_locals`, `prefer_final_fields`
- `omit_local_variable_types` and `avoid_types_on_closure_parameters` — let inference work
- `sort_child_properties_last` — `child:` goes last in widget constructors
- `avoid_print` — use no logging in library code

## Pre-1.0 conventions

This is v0.18.x — breaking changes land in minor versions; every breaking release adds a section to `MIGRATION.md`. Error handling is **assert-based**, not exception-based (no custom exception classes). Provider lookups assert "No XyzProvider found" as a development-time check.
