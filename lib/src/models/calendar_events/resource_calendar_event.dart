import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart' show EventInteraction;
import 'package:kalender/src/models/calendar_events/calendar_event.dart';

/// A [CalendarEvent] that is bound to a single resource lane.
///
/// Used by views configured with `ResourceMultiDayViewConfiguration`. The
/// event is rendered only in columns whose `ResourceConfig.id` matches
/// [resourceId].
///
/// Events that should appear in every lane for their date range (holidays,
/// company-wide meetings, etc.) should extend [CalendarEvent] directly rather
/// than this class.
///
/// ```dart
/// class Shift extends ResourceCalendarEvent {
///   Shift({
///     required super.dateTimeRange,
///     required super.resourceId,
///     required this.employeeName,
///     super.interaction,
///   });
///
///   final String employeeName;
///
///   @override
///   Shift copyWith({
///     DateTimeRange? dateTimeRange,
///     EventInteraction? interaction,
///     String? resourceId,
///     String? employeeName,
///   }) {
///     return Shift(
///       dateTimeRange: dateTimeRange ?? this.dateTimeRange,
///       interaction: interaction ?? this.interaction,
///       resourceId: resourceId ?? this.resourceId,
///       employeeName: employeeName ?? this.employeeName,
///     )..id = id;
///   }
/// }
/// ```
class ResourceCalendarEvent extends CalendarEvent {
  /// Identifier of the resource lane this event belongs to.
  ///
  /// Must match the `ResourceConfig.id` of one of the lanes declared on the
  /// active view configuration. Events whose [resourceId] doesn't match any
  /// declared lane are filtered out of the body.
  final String resourceId;

  /// Creates a [ResourceCalendarEvent].
  ///
  /// [resourceId] must be a non-empty string identifying the target lane.
  ResourceCalendarEvent({
    required this.resourceId,
    super.id,
    required super.dateTimeRange,
    super.interaction,
  }) : assert(resourceId != '', 'resourceId must not be empty');

  @override
  ResourceCalendarEvent copyWith({
    DateTimeRange? dateTimeRange,
    EventInteraction? interaction,
    String? resourceId,
  }) {
    return ResourceCalendarEvent(
      dateTimeRange: dateTimeRange ?? DateTimeRange(start: start, end: end),
      interaction: interaction ?? this.interaction,
      resourceId: resourceId ?? this.resourceId,
    )..id = id;
  }

  @override
  String toString() {
    return 'ResourceCalendarEvent ($id):'
        '\nstart:  $start'
        '\nend: $end'
        '\nresourceId: $resourceId';
  }
}
