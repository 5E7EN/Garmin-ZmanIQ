# TODO

- [x] Fix bug that breaks displayed time when in another timezone. Always show time relative to the user's timezone.
- [x] Replace all `//!` comments with `//*` instead (too much red)
- [ ] Fix bug that doesn't fetch the zmanim for the user's current location if it changes
- [ ] Generate usage docs for the user using ChatGPT with the help of code logic/comments (GPTIJATP - GPT-is-just-a-tool-paradigm)
- [ ] Provide ability to choose method of location retrieval (GPS, weather, activity)
  - If choosing GPS, tell user to start an outdoor activity to get a GPS lock
  - If choosing weather, ensure user is connected to their phone/or was recently connected
  - If choosing Activity, ensure user is aware that the location will be based on the last activity they recorded
- [ ] See how to use strings within pushed views for multilingual support
