import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

void main() => runApp(const ResourcesExampleApp());

/// Width of the time-ruler gutter on the left of the calendar body. Fixed so
/// the [_ResourceHeaderStrip] above the body knows exactly how much horizontal
/// space to reserve before its first lane cell.
const double _kTimelineWidth = 56;

const double _kSidebarWidth = 260;

const _kDayWindowStartHour = 6;
const _kDayWindowEndHour = 20;

/// One resource lane. In a real scheduling app this would be an Employee, a
/// room, a vehicle, etc.
class Employee {
  const Employee({required this.id, required this.name, required this.color});
  final String id;
  final String name;
  final Color color;
}

const _employees = <Employee>[
  Employee(id: 'alice', name: 'Alice Reyes', color: Color(0xFF1976D2)),
  Employee(id: 'bob', name: 'Bob Schmidt', color: Color(0xFF388E3C)),
  Employee(id: 'carol', name: 'Carol Nguyen', color: Color(0xFFD32F2F)),
  Employee(id: 'dan', name: "Dan O'Connor", color: Color(0xFFF57C00)),
  Employee(id: 'eve', name: 'Eve Park', color: Color(0xFF7B1FA2)),
];

/// A booking pinned to one employee's lane. Mirrors the typical real-world
/// pattern: a typed subclass of [ResourceCalendarEvent] carrying the domain
/// payload (here just a [label]).
class Shift extends ResourceCalendarEvent {
  Shift({
    required super.dateTimeRange,
    required super.resourceId,
    required this.label,
    super.interaction,
  });

  final String label;

  @override
  Shift copyWith({
    DateTimeRange? dateTimeRange,
    EventInteraction? interaction,
    String? resourceId,
    String? label,
  }) {
    return Shift(
      dateTimeRange: dateTimeRange ?? this.dateTimeRange,
      interaction: interaction ?? this.interaction,
      resourceId: resourceId ?? this.resourceId,
      label: label ?? this.label,
    )..id = id;
  }
}

class ResourcesExampleApp extends StatelessWidget {
  const ResourcesExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalender Resources Example',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
      ),
      home: const ResourcesHomePage(),
    );
  }
}

/// Page-level shell. Owns the [DefaultEventsController], the [CalendarController]
/// and the per-resource visibility set. Navigation (prev/today/next + swipe)
/// happens via the calendar controller, so the toolbar's date label can mirror
/// whatever page the calendar is currently on by listening to
/// [CalendarController.visibleDateTimeRange].
class ResourcesHomePage extends StatefulWidget {
  const ResourcesHomePage({super.key});

  @override
  State<ResourcesHomePage> createState() => _ResourcesHomePageState();
}

class _ResourcesHomePageState extends State<ResourcesHomePage> {
  final _eventsController = DefaultEventsController();
  final _calendarController = CalendarController();

  Set<String> _hiddenIds = const {};

  /// Mirrors the calendar's currently-visible page. Updated by both the
  /// toolbar buttons (before they animate) and by [CalendarCallbacks.onPageChanged]
  /// when the user swipes the body horizontally.
  late DateTime _displayDate = _today();

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  List<Employee> get _visible => _employees.where((e) => !_hiddenIds.contains(e.id)).toList(growable: false);

  @override
  void initState() {
    super.initState();
    final today = _today();
    _eventsController.addEvents([
      Shift(
        dateTimeRange: DateTimeRange(
          start: today.add(const Duration(hours: 9)),
          end: today.add(const Duration(hours: 12)),
        ),
        resourceId: 'alice',
        label: 'Customer onboarding',
      ),
      Shift(
        dateTimeRange: DateTimeRange(
          start: today.add(const Duration(hours: 13)),
          end: today.add(const Duration(hours: 17)),
        ),
        resourceId: 'bob',
        label: 'Sprint review',
      ),
      Shift(
        dateTimeRange: DateTimeRange(
          start: today.add(const Duration(days: 1, hours: 10)),
          end: today.add(const Duration(days: 1, hours: 16)),
        ),
        resourceId: 'carol',
        label: 'Site visit',
      ),
      Shift(
        dateTimeRange: DateTimeRange(
          start: today.add(const Duration(hours: 14)),
          end: today.add(const Duration(hours: 15, minutes: 30)),
        ),
        resourceId: 'dan',
        label: 'Install Q-200',
      ),
    ]);
  }

  @override
  void dispose() {
    _eventsController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _goPrevious() {
    _calendarController.animateToPreviousPage();
  }

  void _goNext() {
    _calendarController.animateToNextPage();
  }

  void _goToday() {
    _calendarController.animateToDate(_today());
  }

  void _onPageChanged(DateTimeRange range) {
    final start = range.start.toLocal();
    final next = DateTime(start.year, start.month, start.day);
    if (next == _displayDate) return;
    setState(() => _displayDate = next);
  }

  void _toggleEmployee(String id) {
    setState(() {
      final next = Set<String>.from(_hiddenIds);
      if (!next.remove(id)) next.add(id);
      _hiddenIds = next;
    });
  }

  void _onEventCreated(CalendarEvent event) {
    final messenger = ScaffoldMessenger.of(context);

    Employee? lane;
    if (event is ResourceCalendarEvent) {
      lane = _employees.where((e) => e.id == event.resourceId).firstOrNull;
    }

    final shift = Shift(
      dateTimeRange: event.dateTimeRange,
      resourceId: lane?.id ?? _employees.first.id,
      label: 'New shift',
    );
    _eventsController.addEvent(shift);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          lane == null
              ? 'Created shift ${_formatTime(event.dateTimeRange.start)} – ${_formatTime(event.dateTimeRange.end)}'
              : '${lane.name}: ${_formatTime(event.dateTimeRange.start)} – ${_formatTime(event.dateTimeRange.end)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onEventChanged(CalendarEvent event, CalendarEvent updated) {
    _eventsController.updateEvent(event: event, updatedEvent: updated);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Toolbar(
              displayDate: _displayDate,
              onPrevious: _goPrevious,
              onNext: _goNext,
              onToday: _goToday,
            ),
            const Divider(height: 1),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: visible.isEmpty
                        ? const Center(
                            child: Text('No visible employees — toggle one on in the panel on the right.'),
                          )
                        : _DayCalendar(
                            employees: visible,
                            eventsController: _eventsController,
                            calendarController: _calendarController,
                            onEventCreated: _onEventCreated,
                            onEventChanged: _onEventChanged,
                            onPageChanged: _onPageChanged,
                          ),
                  ),
                  const VerticalDivider(width: 1),
                  _EmployeePanel(
                    employees: _employees,
                    hiddenIds: _hiddenIds,
                    onToggle: _toggleEmployee,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top navigation bar: prev / today / next + date label.
///
/// The label is driven by the parent's [displayDate], which is kept in sync
/// with the calendar both ways: toolbar buttons update it before animating
/// the calendar, and [CalendarCallbacks.onPageChanged] updates it when the
/// user swipes the body horizontally.
class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.displayDate,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime displayDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous day',
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          OutlinedButton(onPressed: onToday, child: const Text('Today')),
          IconButton(
            tooltip: 'Next day',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
          const SizedBox(width: 16),
          Text(_formatDate(displayDate), style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

/// The day-view calendar plus a resource header strip aligned to its lanes.
///
/// Note the configuration deliberately omits `initialDateTime`: when the user
/// toggles a resource the [ResourceMultiDayViewConfiguration] inequality
/// triggers kalender to recreate the view controller, and the default
/// `kDefaultToDaily` strategy preserves the currently-visible date.
class _DayCalendar extends StatelessWidget {
  const _DayCalendar({
    required this.employees,
    required this.eventsController,
    required this.calendarController,
    required this.onEventCreated,
    required this.onEventChanged,
    required this.onPageChanged,
  });

  final List<Employee> employees;
  final EventsController eventsController;
  final CalendarController calendarController;
  final ValueChanged<CalendarEvent> onEventCreated;
  final void Function(CalendarEvent, CalendarEvent) onEventChanged;
  final ValueChanged<DateTimeRange> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final viewConfig = ResourceMultiDayViewConfiguration.singleDay(
      displayRange: _displayRange(),
      timeOfDayRange: const _DayWindow().toRange(),
      initialTimeOfDay: const TimeOfDay(hour: _kDayWindowStartHour, minute: 0),
      initialHeightPerMinute: 0.7,
      resources: [for (final e in employees) ResourceConfig(id: e.id)],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final laneWidth = ((constraints.maxWidth - _kTimelineWidth) / employees.length).clamp(40.0, double.infinity);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ResourceHeaderStrip(
              employees: employees,
              laneWidth: laneWidth,
              leadingGutter: _kTimelineWidth,
            ),
            Expanded(
              child: CalendarView(
                eventsController: eventsController,
                calendarController: calendarController,
                viewConfiguration: viewConfig,
                components: _components(),
                callbacks: CalendarCallbacks(
                  onEventCreated: onEventCreated,
                  onEventChanged: onEventChanged,
                  onPageChanged: onPageChanged,
                ),
                body: CalendarBody(
                  multiDayTileComponents: _tileComponents(context, employees),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One cell per visible employee with a [leadingGutter] spacer so the cells
/// line up with the body's resource columns below.
class _ResourceHeaderStrip extends StatelessWidget {
  const _ResourceHeaderStrip({
    required this.employees,
    required this.laneWidth,
    required this.leadingGutter,
  });

  final List<Employee> employees;
  final double laneWidth;
  final double leadingGutter;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          SizedBox(width: leadingGutter, height: 40),
          for (final e in employees)
            Container(
              width: laneWidth,
              height: 40,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: scheme.outlineVariant)),
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  e.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: e.color),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Sidebar panel listing every loaded employee with a checkbox to toggle their
/// lane on/off. State lives on the parent so toggling rebuilds the calendar
/// with a smaller [ResourceMultiDayViewConfiguration.resources] list.
class _EmployeePanel extends StatelessWidget {
  const _EmployeePanel({
    required this.employees,
    required this.hiddenIds,
    required this.onToggle,
  });

  final List<Employee> employees;
  final Set<String> hiddenIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleCount = employees.where((e) => !hiddenIds.contains(e.id)).length;
    return SizedBox(
      width: _kSidebarWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Employees', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '$visibleCount of ${employees.length} visible',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                for (final e in employees)
                  CheckboxListTile(
                    value: !hiddenIds.contains(e.id),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(e.name),
                    secondary: CircleAvatar(radius: 6, backgroundColor: e.color),
                    onChanged: (_) => onToggle(e.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared kalender configuration helpers
// ---------------------------------------------------------------------------

/// Calendar component overrides. The only customization is a fixed-width
/// timeline so the [_ResourceHeaderStrip] above the body can line up its lane
/// cells with the columns underneath.
CalendarComponents _components() => CalendarComponents(
      multiDayComponents: const MultiDayComponents(
        bodyComponents: MultiDayBodyComponents(
          timeline: _fixedWidthTimeline,
          prototypeTimeLine: _fixedWidthPrototypeTimeline,
        ),
      ),
    );

Widget _fixedWidthTimeline(
  double heightPerMinute,
  TimeOfDayRange timeOfDayRange,
  TimelineStyle? style,
  ValueNotifier<CalendarEvent?> eventBeingDragged,
  ValueNotifier<DateTimeRange<DateTime>?> visibleDateTimeRange,
) {
  return SizedBox(
    width: _kTimelineWidth,
    child: TimeLine(
      heightPerMinute: heightPerMinute,
      timeOfDayRange: timeOfDayRange,
      style: style,
      eventBeingDragged: eventBeingDragged,
      visibleDateTimeRange: visibleDateTimeRange,
    ),
  );
}

Widget _fixedWidthPrototypeTimeline(
  double heightPerMinute,
  TimeOfDayRange timeOfDayRange,
  TimelineStyle? style,
) {
  return const SizedBox(width: _kTimelineWidth);
}

TileComponents _tileComponents(BuildContext context, List<Employee> employees) {
  final radius = BorderRadius.circular(6);
  Color colorFor(CalendarEvent event) {
    if (event is Shift) {
      return employees.firstWhere((e) => e.id == event.resourceId, orElse: () => _employees.first).color;
    }
    return Theme.of(context).colorScheme.primary;
  }

  String labelFor(CalendarEvent event) => event is Shift ? event.label : 'Event';

  return TileComponents(
    tileBuilder: (event, tileRange) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      child: DecoratedBox(
        decoration: BoxDecoration(color: colorFor(event), borderRadius: radius),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Text(
            labelFor(event),
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ),
    dropTargetTile: (event) => DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withAlpha(80), width: 2),
        borderRadius: radius,
      ),
    ),
    feedbackTileBuilder: (event, size) => Container(
      width: size.width * 0.8,
      height: size.height,
      decoration: BoxDecoration(color: colorFor(event).withAlpha(140), borderRadius: radius),
    ),
    tileWhenDraggingBuilder: (event) => Container(
      decoration: BoxDecoration(color: colorFor(event).withAlpha(60), borderRadius: radius),
    ),
    dragAnchorStrategy: pointerDragAnchorStrategy,
  );
}

/// A year-wide display range centred on today. The calendar uses this to bound
/// how far the user can page in either direction.
DateTimeRange _displayRange() {
  final now = DateTime.now();
  return DateTimeRange(
    start: DateTime(now.year - 1, now.month, now.day),
    end: DateTime(now.year + 1, now.month, now.day),
  );
}

class _DayWindow {
  const _DayWindow();
  TimeOfDayRange toRange() => TimeOfDayRange(
        start: const TimeOfDay(hour: _kDayWindowStartHour, minute: 0),
        end: const TimeOfDay(hour: _kDayWindowEndHour - 1, minute: 59),
      );
}

// ---------------------------------------------------------------------------
// Formatting helpers
// ---------------------------------------------------------------------------

const _weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime d) => '${_weekdayNames[d.weekday - 1]} ${d.day} ${_monthNames[d.month - 1]} ${d.year}';

String _formatTime(DateTime d) {
  final local = d.toLocal();
  return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}
