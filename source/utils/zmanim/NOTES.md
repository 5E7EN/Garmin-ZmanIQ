# Porting Notes

Points recorded while porting KosherJava library.

## Points (as promised)

- Java `Date.getTime()` returns milliseconds since epoch, Monkey-C `Moment.value()` returns seconds
- Port only supports using astronomical chatzos (`useAstronomicalChatzos` boolean) (more accurate, so no problem)
- ~~The following methods in `ZmanimCalender` are sus. Why use sea level sunrise/sunset? Review if times are off.~~ See [here](<https://kosherjava.com/zmanim/docs/api/com/kosherjava/zmanim/ZmanimCalendar.html#isUseElevation()>) - it's intended al-pi halacha.
  - `getAlos72`
  - `getSofZmanShmaGRA`
  - `getTzait72`
  - `getSofZmanTfilaGRA`
  - `getMinchaGedola`
  - `getMinchaKetana`
  - `getPlagHamincha`
- Skipped `isAssurBemlacha` method port
- Skipped `useAstronomicalChatzosForOtherZmanim` and related logic in port
- Found machlokes between (MyZmanim)[https://i.5e7en.me/3uc0mOvB8Cc5.png] and (KosherJava)[https://github.com/KosherJava/zmanim/blob/04dc83975db43582414d8639e0e204d9681aa6f0/src/main/java/com/kosherjava/zmanim/ComplexZmanimCalendar.java#L191] whether 11.5° zenith translates to 60 or 52 minutes before sunrise. Ayin Sham.
- ~~SunTimesCalculator doesn't implement `[AstronomicalCalculator].getUTCNoon()` and `[AstronomicalCalculator].getUTCMidnight()` for `SunTimesCalculator`. This may have implications on accuracy since `AstronomicalCalendar.getSunTransit()` should be using this.~~ Implemented!
  - USNO algorithm uses halfway time between sunrise and sunset to determine solar noon. NOAACalculator calculates true solar noon.
    - Chatzos before change (USNO): 11:53:30
    - Chatzos after change (USNO): 11:53:35
    - Chatzos after true solar noon (NOAACalculator): 11:53:17
- Port does not implement antimeridian adjustment. Unsure of the implications of this as of yet.
  - Seems to require knowledge of current timezone
  - ~~This affects anything that invokes `AstronomicalCalendar.getDateFromTime()` ([since it should be using adjusted cal](https://github.com/KosherJava/zmanim/blob/04dc83975db43582414d8639e0e204d9681aa6f0/src/main/java/com/kosherjava/zmanim/AstronomicalCalendar.java#L627))~~ After review, it looks like `AstronomicalCalendar.getDateFromTime()` does in fact implement some variation of date transitioning (as seen [here](https://github.com/5E7EN/Garmin-Zmanim-Reminder/blob/e4acdff6a226f795783720455c9baabd9e0b9868/source/zmanim/ZmanimCalendars.mc#L106) here and [here](https://github.com/KosherJava/zmanim/blob/5dd0df5bbf2799e690cf651a9ea9415d0c0d16ab/src/main/java/com/kosherjava/zmanim/AstronomicalCalendar.java#L641) there)
- Why are alos, szks, szt, and more not the same as KosherJava map result?
  - Result doesn't seem to be changing based on elevation... Review implementation.
  - Only occurs significantly with SunTimesCalculator (USNO algo)
  - See below regarding NOAA algo
- [NOAACalculator] Seems like szks, szt, mincha gedola (and maybe more) zmanim differ by a few seconds compared to KosherJava map. Figure out why.
- [Note] Alos uses 16.1 degree zenith (find out why that's not default on KosherJava map, and as such, we're 1 minute behind the map's default result)
- Here's how zmanim at sea level currently compare to KosherJava map (NOAA!):
  - Alos 16.1°: exact
  - Sunrise (elevated): exact
  - Sunrise (sea level): exact
  - SZKS GR"A: behind by 2 seconds (9:06:41 vs 9:06:43)
  - SZT GR"A: behind by 3 seconds (10:02:13 vs 10:02:16)
  - Chatzos: exact
  - Mincha Gedola: behind by 5 seconds (12:21:03 vs 12:21:08)
  - Sunset (elevated): exact
  - Sunset (sea level): exact
  - Tzais 8.5°: exact
  - Same differences with HebCal API... Need to figure out what's causing it. May be floating point related?
