import 'package:flutter/material.dart';
import 'package:kalender/src/models/initial_date_selection_strategy.dart';
import 'package:kalender/src/models/resource_config.dart';
import 'package:kalender/src/models/time_of_day_range.dart';
import 'package:kalender/src/models/view_configurations/multi_day_view_configuration.dart';
import 'package:kalender/src/models/view_configurations/view_configuration.dart';

/// A [MultiDayViewConfiguration] that renders one or more resource lanes
/// within each date column.
///
/// When this configuration is active, the [MultiDayBody] renders
/// `numberOfDays × resources.length` columns. Events extending
/// `ResourceCalendarEvent` are rendered only in the column whose
/// [ResourceConfig.id] matches their `resourceId`. Events that extend
/// `CalendarEvent` directly (i.e. carry no resource binding) are rendered in
/// every lane for their date range.
///
/// Use a plain [MultiDayViewConfiguration] when you do not need resource
/// lanes — the body falls back to one column per date.
///
/// ```dart
/// ResourceMultiDayViewConfiguration.week(
///   displayRange: range,
///   resources: const [
///     ResourceConfig(id: 'alice'),
///     ResourceConfig(id: 'bob'),
///   ],
/// )
/// ```
class ResourceMultiDayViewConfiguration extends MultiDayViewConfiguration {
  /// The resource lanes rendered within each date column.
  ///
  /// Must contain at least one entry. The list determines column order
  /// (left-to-right) within each date.
  final List<ResourceConfig> resources;

  /// Total physical columns: `numberOfDays * resources.length`.
  @override
  int get numberOfColumns => numberOfDays * resources.length;

  /// IDs of the resource lanes, in left-to-right order.
  @override
  List<String?> get columnResourceIds => resources.map((r) => r.id).toList(growable: false);

  /// Creates a [ResourceMultiDayViewConfiguration] for a single day with one
  /// column per resource.
  ResourceMultiDayViewConfiguration.singleDay({
    required this.resources,
    super.name = 'Day',
    super.initialDateTime,
    super.initialDateSelectionStrategy = kDefaultToDaily,
    super.nowCallback,
    super.displayRange,
    super.timeOfDayRange,
    super.firstDayOfWeek = defaultFirstDayOfWeek,
    super.initialTimeOfDay = defaultInitialTimeOfDay,
    super.initialHeightPerMinute = defaultHeightPerMinute,
  })  : assert(resources.isNotEmpty, 'resources must not be empty'),
        super.singleDay();

  /// Creates a [ResourceMultiDayViewConfiguration] for a week.
  ResourceMultiDayViewConfiguration.week({
    required this.resources,
    super.name = 'Week',
    super.initialDateTime,
    super.initialDateSelectionStrategy = kDefaultToWeekly,
    super.nowCallback,
    super.displayRange,
    super.timeOfDayRange,
    super.firstDayOfWeek = defaultFirstDayOfWeek,
    super.numberOfDays = 7,
    super.initialTimeOfDay = defaultInitialTimeOfDay,
    super.initialHeightPerMinute = defaultHeightPerMinute,
  })  : assert(resources.isNotEmpty, 'resources must not be empty'),
        super.week();

  /// Creates a [ResourceMultiDayViewConfiguration] for a work week.
  ResourceMultiDayViewConfiguration.workWeek({
    required this.resources,
    super.name = 'Work Week',
    super.initialDateTime,
    super.initialDateSelectionStrategy = kDefaultToWeekly,
    super.nowCallback,
    super.displayRange,
    super.timeOfDayRange,
    super.numberOfDays = 5,
    super.initialTimeOfDay = defaultInitialTimeOfDay,
    super.initialHeightPerMinute = defaultHeightPerMinute,
  })  : assert(resources.isNotEmpty, 'resources must not be empty'),
        super.workWeek();

  /// Creates a [ResourceMultiDayViewConfiguration] for a custom number of days.
  ResourceMultiDayViewConfiguration.custom({
    required this.resources,
    super.name = 'Custom',
    super.initialDateTime,
    super.initialDateSelectionStrategy = kDefaultToWeekly,
    super.nowCallback,
    super.displayRange,
    super.timeOfDayRange,
    required super.numberOfDays,
    super.firstDayOfWeek = defaultFirstDayOfWeek,
    super.initialTimeOfDay = defaultInitialTimeOfDay,
    super.initialHeightPerMinute = defaultHeightPerMinute,
  })  : assert(resources.isNotEmpty, 'resources must not be empty'),
        super.custom();

  /// Creates a [ResourceMultiDayViewConfiguration] for a free scrolling view.
  ResourceMultiDayViewConfiguration.freeScroll({
    required this.resources,
    super.name = 'Free Scroll',
    super.initialDateTime,
    super.initialDateSelectionStrategy = kDefaultToWeekly,
    super.nowCallback,
    super.displayRange,
    super.timeOfDayRange,
    required super.numberOfDays,
    super.initialTimeOfDay = defaultInitialTimeOfDay,
    super.initialHeightPerMinute = defaultHeightPerMinute,
  })  : assert(resources.isNotEmpty, 'resources must not be empty'),
        super.freeScroll();

  @override
  ResourceMultiDayViewConfiguration copyWith({
    String? name,
    DateTime? initialDateTime,
    InitialDateSelectionStrategy? initialDateSelectionStrategy,
    NowCallback? nowCallback,
    TimeOfDayRange? timeOfDayRange,
    DateTimeRange? displayRange,
    int? numberOfDays,
    int? firstDayOfWeek,
    TimeOfDay? initialTimeOfDay,
    List<ResourceConfig>? resources,
  }) {
    final name0 = name ?? this.name;
    final selectedDate0 = initialDateTime ?? this.initialDateTime;
    final initialDateSelectionStrategy0 = initialDateSelectionStrategy ?? this.initialDateSelectionStrategy;
    final nowCallback0 = nowCallback ?? this.nowCallback;
    final timeOfDayRange0 = timeOfDayRange ?? this.timeOfDayRange;
    final displayRange0 = displayRange ?? dateTimeRange;
    final firstDayOfWeek0 = firstDayOfWeek ?? this.firstDayOfWeek;
    final initialTimeOfDay0 = initialTimeOfDay ?? this.initialTimeOfDay;
    final resources0 = resources ?? this.resources;

    return switch (type) {
      MultiDayViewType.singleDay => ResourceMultiDayViewConfiguration.singleDay(
          name: name0,
          initialDateTime: selectedDate0,
          initialDateSelectionStrategy: initialDateSelectionStrategy0,
          nowCallback: nowCallback0,
          timeOfDayRange: timeOfDayRange0,
          displayRange: displayRange0,
          firstDayOfWeek: firstDayOfWeek0,
          initialTimeOfDay: initialTimeOfDay0,
          resources: resources0,
        ),
      MultiDayViewType.week => ResourceMultiDayViewConfiguration.week(
          name: name0,
          initialDateTime: selectedDate0,
          initialDateSelectionStrategy: initialDateSelectionStrategy0,
          nowCallback: nowCallback0,
          timeOfDayRange: timeOfDayRange0,
          displayRange: displayRange0,
          firstDayOfWeek: firstDayOfWeek0,
          initialTimeOfDay: initialTimeOfDay0,
          resources: resources0,
        ),
      MultiDayViewType.workWeek => ResourceMultiDayViewConfiguration.workWeek(
          name: name0,
          initialDateTime: selectedDate0,
          initialDateSelectionStrategy: initialDateSelectionStrategy0,
          nowCallback: nowCallback0,
          timeOfDayRange: timeOfDayRange0,
          displayRange: displayRange0,
          initialTimeOfDay: initialTimeOfDay0,
          resources: resources0,
        ),
      MultiDayViewType.custom => ResourceMultiDayViewConfiguration.custom(
          name: name0,
          initialDateTime: selectedDate0,
          initialDateSelectionStrategy: initialDateSelectionStrategy0,
          nowCallback: nowCallback0,
          timeOfDayRange: timeOfDayRange0,
          displayRange: displayRange0,
          firstDayOfWeek: firstDayOfWeek0,
          numberOfDays: numberOfDays ?? this.numberOfDays,
          initialTimeOfDay: initialTimeOfDay0,
          resources: resources0,
        ),
      MultiDayViewType.freeScroll => ResourceMultiDayViewConfiguration.freeScroll(
          name: name0,
          initialDateTime: selectedDate0,
          initialDateSelectionStrategy: initialDateSelectionStrategy0,
          nowCallback: nowCallback0,
          timeOfDayRange: timeOfDayRange0,
          displayRange: displayRange0,
          numberOfDays: numberOfDays ?? this.numberOfDays,
          initialTimeOfDay: initialTimeOfDay0,
          resources: resources0,
        ),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    if (!(super == other)) return false;
    return other is ResourceMultiDayViewConfiguration && _resourcesEqual(other.resources, resources);
  }

  @override
  int get hashCode => Object.hash(super.hashCode, Object.hashAll(resources));

  static bool _resourcesEqual(List<ResourceConfig> a, List<ResourceConfig> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() => '${super.toString()}\n    resources: $resources';
}
