# Notes

- `Gregorian.info` comverts the given `Moment` object into local time
- `Gregorian.utcInfo` comverts the given `Moment` object into UTC time
- Inform user that they must be in the same timezone as their assumed location to avoid miscalculations.
  - This can be particularly important when using "Last Activity" location pref

## Naming Conventions

- Module and type names are camel case with an initial uppercase letter.
- Local variables are camel case and start with an initial lowercase letter.
- Class member variables use a prefix and are camel case. Typically the prefix is `m`. (Not yet fully in effect).
