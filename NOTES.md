# Notes

- `Gregorian.info` comverts the given `Moment` object into local time
- `Gregorian.utcInfo` comverts the given `Moment` object into UTC time
- Inform user that they must be in the same timezone as their assumed location to avoid miscalculations.
  - This can be particularly important when using "Last Activity" location pref
- Thanks to [@slipperybee](https://github.com/slipperybee) for the zmanim calculation and calender algorithm Monkey C implementions. Originally adapted from [KosherJava](https://github.com/KosherJava/zmanim).
- I very much believe in transparency when it comes to solutions with Halachic implications. The code for this project is [available on GitHub](https://github.com/5E7EN/Garmin-Zmanim-Reminder) for analysis.

## Naming Conventions

- Module and type names are camel case with an initial uppercase letter.
- Local variables are camel case and start with an initial lowercase letter.
- Class member variables use a prefix and are camel case. Typically the prefix is `m`. (Not yet fully in effect).

## MonkeyC Quirks

- Tuple method return types cannot be defined without using a `typedef`.
  - `function getArray() as [String, Number]` throws `no viable alternative at input 'as['`
  - https://forums.garmin.com/developer/connect-iq/i/bug-reports/can-t-define-2-dimensional-array-in-strict-mode
