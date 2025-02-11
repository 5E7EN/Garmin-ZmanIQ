# TODO

- [x] Fix bug that breaks displayed time when in another timezone. Always show time relative to the user's timezone.
- [ ] Fix bug that doesn't fetch the zmanim for the user's current location if it changes
- [ ] Generate usage docs for the user using ChatGPT with the help of code logic/comments (GPTIJATP - GPT-is-just-a-tool-paradigm)
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
- [ ] Adapt best practices and menus from [this project](https://github.com/cedric-dufour/connectiq-app-rawlogger)
  - See also: https://github.com/myneur/late
- [ ] Improve location handling. See [this great project](https://github.com/dagstuan/skredvarselGarmin).
- [x] Make constants of Storage key names for cached data (e.g. constants/storage.mc, see `SkredvarselStorage.mc` in project above)
- [ ] Show user where we assume he his based on coords (use some API) to prevent confusion. See NOTES.md.
- [ ] Migrate to widget instead of app
  - Implications: https://developer.garmin.com/connect-iq/connect-iq-basics/app-types/
  - None affect us, other than loss of location fetching via Last Activity.
- [ ] Initial view, if no zmanim yet cached, should be "fetching GPS coords, go outside". SELECT button opens menu to choose between Weather location or last fetched GPS coords.
- [ ] Zmanim display should be a scrollable View instead of Menu (for onMenu support)
- [ ] Support on-device zmanim calculations
  - See: https://github.com/KosherJava/zmanim
  - See: https://github.com/hebcal/hebcal-es6
- [ ] Improve view/menu animations (see elegance in Menu2Custom sample)

## Based on others

Implement features as seen in the Reviews

- [ ] https://apps.garmin.com/apps/5588a19d-ee0a-4445-8604-4b51d37f03a2?tid=2
