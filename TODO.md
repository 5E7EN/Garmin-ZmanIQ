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
- [ ] See also: https://github.com/myneur/late
- [ ] Improve location handling. See [this great project](https://github.com/dagstuan/skredvarselGarmin).
