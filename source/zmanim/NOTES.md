# Porting Notes

Points recorded while porting KosherJava library.

## Points (as promised)

- Java `Date.getTime()` returns milliseconds since epoch, Monkey-C `Moment.value()` returns seconds
- Port only supports using astronomical chatzos (`useAstronomicalChatzos` boolean) (more accurate, so no problem)
- The following methods in `ZmanimCalender` are sus. Why use sea level sunrise/sunset? Review if times are off:
  - `getSofZmanShmaGRA`
  - `getTzait72`
  - `getSofZmanTfilaGRA`
  - `getMinchaGedola`
  - `getMinchaKetana`
  - `getPlagHamincha`
- Skipped `isAssurBemlacha` method port
- Found machlokes between (MyZmanim)[https://i.5e7en.me/3uc0mOvB8Cc5.png] and (KosherJava)[https://github.com/KosherJava/zmanim/blob/04dc83975db43582414d8639e0e204d9681aa6f0/src/main/java/com/kosherjava/zmanim/ComplexZmanimCalendar.java#L191] whether 11.5° zenith translates to 60 or 52 minutes before sunrise. Ayin Sham.
- ~~SunTimesCalculator doesn't implement `[AstronomicalCalculator].getUTCNoon()` and `[AstronomicalCalculator].getUTCMidnight()` for `SunTimesCalculator`. This may have implications on accuracy since `AstronomicalCalendar.getSunTransit()` should be using this.~~ Implemented!
  - USNO algorithm uses halfway time between sunrise and sunset to determine solar noon. NOAACalculator calculates true solar noon.
    - Chatzos before change (USNO): 11:53:30
    - Chatzos after change (USNO): 11:53:35
    <!-- - Chatzos after true solar noon (NOAACalculator): 11:53:17 -->
- Port does not implement antimeridian adjustment. Unsure of the implications of this as of yet.
  - Seems to require knowledge of current timezone
  - This affects anything that invokes `AstronomicalCalendar.getDateFromTime()` ([since it should be using adjusted cal](https://github.com/KosherJava/zmanim/blob/04dc83975db43582414d8639e0e204d9681aa6f0/src/main/java/com/kosherjava/zmanim/AstronomicalCalendar.java#L627))
