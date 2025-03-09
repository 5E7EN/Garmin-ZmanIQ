# TODO

- [x] Fix bug that breaks displayed time when in another timezone. Always show time relative to the user's timezone.
- [x] Fix bug that doesn't fetch the zmanim for the user's current location if it changes
- [ ] Generate usage docs for the user using Gemini with the help of code logic/comments (GPTIJATP - GPT-is-just-a-tool-paradigm)
- [x] Provide ability to choose method of location retrieval (GPS, weather, activity)
  - If choosing GPS, tell user to start an outdoor activity to get a GPS lock
  - If choosing weather, ensure user is connected to their phone/or was recently connected
  - If choosing Activity, ensure user is aware that the location will be based on the last activity they recorded
- [x] Replace all `//!` comments with `//*` instead (too much red)
- [x] Use strings within pushed views for multilingual support
- [ ] Add more supported devices
- [-] ~~Use XML resources for menus instead of code - [See More](https://dev.to/jenhsuan/day-10-of-100daysofcode-learn-monkey-c-create-a-menu-for-ciq-application-2dc9) (as seen in project below)~~ Too little customizability with XML (e.g. cannot set focused menu item)
- [x] Use `Properties` w/ XML for storing settings instead of `Storage` (as seen in project below)
  - This enables easily defining defaults
- [x] Adapt best practices and menus from [this project](https://github.com/cedric-dufour/connectiq-app-rawlogger)
  - See also: https://github.com/myneur/late
- [x] Improve location handling. See [this great project](https://github.com/dagstuan/skredvarselGarmin).
- [x] Make constants of Storage key names for cached data (e.g. constants/storage.mc, see `SkredvarselStorage.mc` in project above)
- [-] ~~Show user where we assume he his based on coords (use some API) to prevent confusion. See NOTES.md.~~ Not feasible due to memory constraints.
- [ ] Migrate to widget instead of app
  - Implications: https://developer.garmin.com/connect-iq/connect-iq-basics/app-types/
  - None affect us, other than loss of location fetching via Last Activity.
- [x] ~~Initial view, if no zmanim yet cached, should be "fetching GPS coords, go outside". SELECT button opens menu to choose between Weather location or last fetched GPS coords.~~ Did better :)
- [-] ~~Zmanim display should be a scrollable View instead of Menu (for onMenu support)~~ No need. Using custom wrapping menu instead.
- [x] Use device clock settings (12/24hr) for time display
- [x] Support on-device zmanim calculations
  - See: https://github.com/KosherJava/zmanim
  - See: https://github.com/hebcal/hebcal-es6
  - Then, change "Reload Zmanim" button in menu to "Select Date"
  - Also, get next day's zmanim that may be relevant for today (e.g. chatzos night, sunrise)
  - Only use altitude when location source is GPS to prevent inaccuracies.
- [x] Improve view/menu animations (see elegance in Menu2Custom sample)
- [ ] Select zman from list to Set Reminder
  - Main reminder settings (time before, etc.) should be in main menu
- [x] Add pref to choose between Gra and Magen Avraham
  - Only currently relevant for sofZmanShma, sofZmanTfilla, minchaGedola, minchaKetana
  - Once on-device calculations are used, may also support sunrise/sunset differences in opinion
- [x] Move `zmanim` folder to `utils/` in source
- [ ] Determine how to allow user to choose between zman opinions (zenith differences, etc.)
  - Add pref to toggle for showing Rabbeinu Tam (72 minute) times
- [ ] Based on chosen zman opinion, determine how to differ results based on user's location (e.g. tzeis offset will be different in Israel vs Diaspora)
- [ ] Add "Expert Mode"
  - Shows more zmanim
  - Adds explanations of zmanim when selected
- [ ] Add "Airplane Mode" setting
  - If enabled, use pass `Position.POSITIONING_MODE_AVIATION` as PositioningMode when invoking `enableLocationEvents()` to support higher altitudes. Warning: This may not be supported on all devices (requires API Level 3.2.0).
- [ ] Clean up code comments
- [x] Improve memory usage
  - Clear existing view stack before calling `switchToZmanimMenu` to reload zmanim.
- [ ] Create map view to show user's current detected location.
  - See NOTES.md
  - See MapSample SDK sample
  - Only supported on some devices.
- [x] Add "last updated" for location info
- [ ] Add "Misheyakir" zman
  - Zenith to use is dependant on location. [Read More](https://www.myzmanim.com/read/sources.aspx)
- [ ] Add hebrew translation
- [ ] Add setting to enable/disable reminders entirely
- [x] Remove all `// TODO: Add some kind of line separator here (between title and menu items)` comments

## Priority Items

- [x] On-board zmanim
  - [x] Add algorithms (calculators & calenders)
  - [x] Replace hebcal API request with on-board implementation
  - [x] [HIGH-PRI] Compared to [KosherJava](https://kosherjava.com/maps/zmanim.html)
  - [ ] [LOW-PRI] Figure out what's causing a few seconds of difference compared to KosherJava map (see [NOTES](source/zmanim/NOTES.md#L32)). Maybe it's floating point differences? Create java example and compare output of functions (start with `AstronomicalCalendar.getSpecificTemporalHour()` or `AstronomicalCalendar.getDateFromTime()`).
  - [ ] [LOW-PRI] Detect and support Israeli location and use 40min candle lighting offset instead of 18min where applicable
- [ ] Reminders
  - Add menu option to enable/disable reminders
  - If enabled, on zmanim list view show, registerForTemporalEvent() for NEXT zman that has ENABLED reminder (use `Moment` to bypass 5 minute restriction)
  - Create `ReminderEnabledZmanim` storage array and check if it contains zman name (to be added/removed by zman selection menu in zmanim list)
  - [---]
  - Select a zman from the list to open a menu to enable/disable reminder for that zman
  - Alert time will be configurable via the Settings menu
  - Not all devices support Attention alerts. Hide option if device doesn't support it.
  - Notify users which devices actually vibrate/beep/both/none to avoid surprises
- [x] GPS-based location fetching
  - Instruct user to go outside for a signal, wait for signal, and set in Storage.
  - Save coords for easy re-use. Add menu item to "Reset Location" - clearing existing value.
  - Use elevation (when using GPS location source only). Important: Add pref to switch to sea level too.
  - [LOW-PRI] After successfully getting coords, prompt to save coordinates by name for future use. stored zmanim
    - With this, selecting "Reset Location" should just clear location as currently in use (with ability to re-triangulate position or select from existing list)

## Based on others

Implement features as seen in the Reviews

- [ ] https://apps.garmin.com/apps/5588a19d-ee0a-4445-8604-4b51d37f03a2?tid=2
