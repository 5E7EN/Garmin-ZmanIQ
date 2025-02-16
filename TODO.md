# TODO

- [x] Fix bug that breaks displayed time when in another timezone. Always show time relative to the user's timezone.
- [ ] Fix bug that doesn't fetch the zmanim for the user's current location if it changes
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
- [ ] Improve location handling. See [this great project](https://github.com/dagstuan/skredvarselGarmin).
- [x] Make constants of Storage key names for cached data (e.g. constants/storage.mc, see `SkredvarselStorage.mc` in project above)
- [ ] Show user where we assume he his based on coords (use some API) to prevent confusion. See NOTES.md.
- [ ] Migrate to widget instead of app
  - Implications: https://developer.garmin.com/connect-iq/connect-iq-basics/app-types/
  - None affect us, other than loss of location fetching via Last Activity.
- [ ] Initial view, if no zmanim yet cached, should be "fetching GPS coords, go outside". SELECT button opens menu to choose between Weather location or last fetched GPS coords.
- [-] ~~Zmanim display should be a scrollable View instead of Menu (for onMenu support)~~ No need. Using custom wrapping menu instead.
- [x] Use device clock settings (12/24hr) for time display
- [ ] Support on-device zmanim calculations
  - See: https://github.com/KosherJava/zmanim
  - See: https://github.com/hebcal/hebcal-es6
  - Then, change "Reload Zmanim" button in menu to "Select Date"
  - Also, get next day's zmanim that may be relevant for today (e.g. chatzos night, sunrise)
  - Only use altitude when location source is GPS to prevent inaccuracies.
- [ ] Improve view/menu animations (see elegance in Menu2Custom sample)
- [ ] Select zman for Menu to Set Reminder
  - Main reminder settings (time before, etc.) should be in main menu
- [ ] Add pref to choose between Gra and Magen Avraham
  - Only currently relevant for sofZmanShma, sofZmanTfilla, minchaGedola, minchaKetana
  - Once on-device calculations are used, may also support sunrise/sunset differences in opinion
- [ ] Move `zmanim` folder to `utils/` in source
- [ ] Determine how to allow user to choose between zman opinions (zenith differences, etc.)
  - Add pref to toggle for showing Rabbeinu Tam (72 minute) times
- [ ] Based on chosen zman opinion, determine how to differ results based on user's location (e.g. tzeis offset will be different in Israel vs Diaspora)
- [ ] Add "Expert Mode"
  - Shows more zmanim
  - Adds explanations of zmanim when selected

## Priority Items

- [ ] On-board zmanim
  - [x] Add algorithms (calculators & calenders)
  - [ ] Replace hebcal API request with on-board implementation
  - [ ] [HIGH-PRI] Compared to [KosherJava](https://kosherjava.com/maps/zmanim.html)
  - [ ] [LOW-PRI] Figure out what's causing a few seconds of difference compared to KosherJava map (see [NOTES](source/zmanim/NOTES.md#L32)). Maybe it's floating point differences? Create java example and compare output of functions (start with `AstronomicalCalendar.getSpecificTemporalHour()` or `AstronomicalCalendar.getDateFromTime()`).
  - [ ] [LOW-PRI] Detect and support Israeli location and use 40min candle lighting offset instead of 18min where applicable
- [ ] Reminders
  - Select a zman from the list to open a menu to enable/disable reminder for that zman
  - Alert time will be configurable via the Settings menu
  - Notify users which devices actually vibrate/beep/both/none to avoid surprised
  - Figure out how to set next temporal event after current one was just triggered
  - Not all devices support Attention alerts. Hide option if device doesn't support it.
- [ ] GPS-based location fetching
  - Instruct user to go outside for a signal, wait for signal, and set in Storage.
  - Save coords for easy re-use. Add menu item to "Reset Location" - clearing existing value.
  - Use elevation (when using GPS location source only). Important: Add pref to switch to sea level too.
  - [LOW-PRI] After successfully getting coords, prompt to save coordinates by name for future use. stored zmanim
    - With this, selecting "Reset Location" should just clear location as currently in use (with ability to re-triangulate position or select from existing list)

## Based on others

Implement features as seen in the Reviews

- [ ] https://apps.garmin.com/apps/5588a19d-ee0a-4445-8604-4b51d37f03a2?tid=2
