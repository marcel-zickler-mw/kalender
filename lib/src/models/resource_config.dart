/// Identifies a single resource lane rendered alongside the date columns of a
/// [MultiDayViewConfiguration].
///
/// When [MultiDayViewConfiguration.resources] is non-null and non-empty, the
/// MultiDayBody renders `dates × resources` columns instead of just one column
/// per date. Events are filtered to a column when [CalendarEvent.resourceId]
/// matches the column's [ResourceConfig.id].
///
/// The minimal shape carries just an [id]; consumers map id → labels in their
/// own header widgets.
class ResourceConfig {
  const ResourceConfig({required this.id});

  /// Stable identifier matched against [CalendarEvent.resourceId].
  final String id;

  @override
  bool operator ==(Object other) => other is ResourceConfig && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ResourceConfig($id)';
}
