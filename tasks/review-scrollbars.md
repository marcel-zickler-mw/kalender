# Task 2 - Review Scrollbars

We added a lot of scrollbar behaviour to the kalender fork which will probably never be accepted as PR since it fulfils
a very special use case

## Original repository

https://github.com/werner-scholtz/kalender
##PR in using project that is the reason for introduction of the scrollbar behaviour in this fork:
https://dev.azure.com/weigerstorfer-org/Weigerstorfer/_git/Weigerstorfer/pullrequest/1941

## Goal

Make sure this fork is ready to be merged into the original repository and being deployed as a new package version.
Therefore, the following requirements must be fulfilled:

- [ ] The added code MUST NOT break existing features and tests of the original repository/package
- [ ] The added code MUST be covered by tests and the tests MUST be passing
    - [ ] Unit tests MUST be added for the new code and the existing tests MUST be passing
    - [ ] Widget tests MUST be added for the new code and the existing tests MUST be passing
- [ ] The added code MUST be properly documented and the documentation MUST be up to date
- [ ] The added code MUST be following the coding style and guidelines of the original repository/package

## Review Goal

- [ ] Review whether the added scrollbar behaviour is really needed within the package or whether it could be
  implemented in the using project without changes to the package. If it is not needed, it should be removed from the
  package and implemented in the using project instead.
