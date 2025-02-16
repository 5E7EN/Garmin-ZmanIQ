# Notes

- `Gregorian.info` comverts the given `Moment` object into local time
- `Gregorian.utcInfo` comverts the given `Moment` object into UTC time
- Inform user that they must be in the same timezone as their assumed location to avoid miscalculations.
  - This can be particularly important when using "Last Activity" location pref
- Thanks to [@slipperybee](https://github.com/slipperybee) for the Monkey-C port of the zmanim calender and USNO algorithm. We've ported the more accurate and up-to-date NOAA (Jean Meeus) algorithm in addition. All has been adapted from [KosherJava](https://github.com/KosherJava/zmanim).
- I very much believe in transparency when it comes to solutions with Halachic implications. The code for this project is [available on GitHub](https://github.com/5E7EN/Garmin-Zmanim-Reminder) for analysis.
- Elevation based zmanim (even sunrise and sunset) should not be used lekula without the guidance of a posek.
  - In settings, you will be able to enable/disable "Use Elevation". [More Info](https://kosherjava.com/zmanim/docs/api/com/kosherjava/zmanim/ZmanimCalendar.html) (only changes sunrise/sunset).
  - Even when "Use Elevation" is enabled, only sunrise and sunset will use elevation. Other zmanim (such as Sof Zman Shema and Sof Zman Tefilla) will use sea level.
- There are places that consist of 0.00001% of the earth where zmanim may not be calculated properly, such as those across the antimeridian line. [More Info](https://github.com/KosherJava/zmanim/blob/d064715ebeaead29a01ec673f3885ee9bd9c78b4/src/main/java/com/kosherjava/zmanim/util/GeoLocation.java#L344)
- Due to atmospheric conditions (pressure, humidity and other conditions), calculating zmanim accurately is very complex. The calculation of zmanim is dependent on [atmospheric refraction](https://en.wikipedia.org/wiki/Atmospheric_refraction) (refraction of sunlight through the atmosphere), and zmanim can be off by up to 2 minutes based on atmospheric conditions.
- While we've tried our best to ensure a high level of accuracy, please double check before relying on these zmanim for halacha lemaaseh.

## Naming Conventions

- Module and type names are camel case with an initial uppercase letter.
- Local variables are camel case and start with an initial lowercase letter.
- Class member variables use a prefix and are camel case. Typically the prefix is `m`. (Not yet fully in effect).

## MonkeyC Quirks

- Tuple method return types cannot be defined without using a `typedef`.
  - `function getArray() as [String, Number]` throws `no viable alternative at input 'as['`
  - https://forums.garmin.com/developer/connect-iq/i/bug-reports/can-t-define-2-dimensional-array-in-strict-mode

## Memory

- Before migration, hebcal API: []
- During migration (on-device and hebcal API): https://i.5e7en.me/Iso369sOPsI6.png
- After migration, on-device only: []
