import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/models/providers/calendar_provider.dart';

mixin NewDraggableWidget {
  CalendarController get controller;
  CalendarCallbacks? get callbacks;

  /// Calculate the initial dateTimeRange of a new event.
  ///
  /// [date] is the date the draggable is located at.
  /// [localPosition] is the last known position of the cursor.
  InternalDateTimeRange calculateDateTimeRange(InternalDateTime date, Offset localPosition);

  /// Create a TapDetail for the new event.
  ///
  /// [range] is the dateTimeRange of the new event.
  /// [localPosition] is the last known position of the cursor.
  TapDetail createTapDetail(BuildContext context, InternalDateTimeRange range, Offset localPosition);

  /// Create the new event and select it where needed.
  ///
  /// When [resourceId] is non-null, a [ResourceCalendarEvent] is created so
  /// resource-aware views render the preview in the matching column. When it
  /// is null, a plain [CalendarEvent] is used.
  void createNewEvent(
    BuildContext context,
    InternalDateTime date,
    Offset localPosition, {
    String? resourceId,
  }) {
    final dateTimeRange = calculateDateTimeRange(date, localPosition);
    final localRange = dateTimeRange.forLocation(location: context.location);
    final newEvent = resourceId == null
        ? CalendarEvent(dateTimeRange: localRange)
        : ResourceCalendarEvent(dateTimeRange: localRange, resourceId: resourceId);

    CalendarEvent? event;
    if (callbacks?.onEventCreateWithDetail != null) {
      final detail = createTapDetail(context, dateTimeRange, localPosition);
      event = callbacks?.onEventCreateWithDetail?.call(newEvent, detail);
    } else if (callbacks?.onEventCreate != null) {
      event = callbacks?.onEventCreate?.call(newEvent);
    }

    event ??= newEvent;
    controller.setNewEvent(event);
    controller.selectEvent(event);
  }

  /// Deselect the new event.
  // ignore: strict_top_level_inference
  void onDragFinished([_, __]) => controller.clearNewEvent();
}
