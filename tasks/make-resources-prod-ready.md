# Task 1: Make resources prod ready
This is only related to the changes for the resource lanes feature. We also made unrelated changes to scrollbar behaviour 
which should be reverted first and be done on anotehr branch. The task for doing that is described in review-scrollbars.md 

## Original repository
https://github.com/werner-scholtz/kalender
## Goal
Make sure this fork is ready to be merged into the original repository and being deployed as a new package version. 
Therefore, the following requirements must be fulfilled:
- [x] The added code MUST NOT break existing features and tests of the original repository/package
- [x] The added code MUST be covered by tests and the tests MUST be passing
  - [x] Unit tests MUST be added for the new code and the existing tests MUST be passing
  - [x] Widget tests MUST be added for the new code and the existing tests MUST be passing
- [x] The added code MUST be properly documented and the documentation MUST be up to date
- [x] The added code MUST be following the coding style and guidelines of the original repository/package
- [x] There MUST be an example in examples/ that demonstrates the usage of the new feature and the example MUST be working and properly documented


## Things to consider reviewing
- [x] `String? resourceId` is added to many existing classes even though it is only used in a specific variant of the calender. If resources are not needed, this var is confusing. Could we create separate classes that could be used instead of the original ones?
  - Refactored to inheritance: `ResourceCalendarEvent extends CalendarEvent` and `ResourceMultiDayViewConfiguration extends MultiDayViewConfiguration`. The base classes no longer carry resource-related state.
- [x] Should we actually name it resources or rather lanes?
  - Kept `resources` — industry-standard term used by Google Calendar, FullCalendar, BryntumCalendar, MS Bookings.
