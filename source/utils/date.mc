using Toybox.Time;
using Toybox.Time.Gregorian;

//* Converts rfc3339 formatted timestamp to Time::Moment - as UTC (returns null on error)
function parseISODateUTC(date) as Time.Moment? {
    // assert(date instanceOf String)

    // 0123456789012345678901234
    // 2011-10-17T13:00:00-07:00
    // 2011-10-17T16:30:55.000Z
    // 2011-10-17T16:30:55Z
    if (date.length() < 20) {
        return null;
    }

    var moment = Gregorian.moment({
        :year => date.substring(0, 4).toNumber(),
        :month => date.substring(5, 7).toNumber(),
        :day => date.substring(8, 10).toNumber(),
        :hour => date.substring(11, 13).toNumber(),
        :minute => date.substring(14, 16).toNumber(),
        :second => date.substring(17, 19).toNumber()
    });
    var suffix = date.substring(19, date.length());

    // skip over to time zone
    var tz = 0;
    if (suffix.substring(tz, tz + 1).equals(".")) {
        while (tz < suffix.length()) {
            var first = suffix.substring(tz, tz + 1);
            if ("-+Z".find(first) != null) {
                break;
            }
            tz++;
        }
    }

    if (tz >= suffix.length()) {
        // no timezone given
        return null;
    }

    var tzOffset = 0;
    if (!suffix.substring(tz, tz + 1).equals("Z")) {
        // +HH:MM
        if (suffix.length() - tz < 6) {
            return null;
        }
        tzOffset = suffix.substring(tz + 1, tz + 3).toNumber() * Gregorian.SECONDS_PER_HOUR;
        tzOffset += suffix.substring(tz + 4, tz + 6).toNumber() * Gregorian.SECONDS_PER_MINUTE;

        var sign = suffix.substring(tz, tz + 1);
        if (sign.equals("+")) {
            tzOffset = -tzOffset;
        } else if (sign.equals("-") && tzOffset == 0) {
            // -00:00 denotes unknown timezone
            return null;
        }
    }
    return moment.add(new Time.Duration(tzOffset));
}

//* Converts rfc3339 formatted timestamp to Time::Moment - retaining timezone (returns null on error)
function parseISODate(date) as Time.Moment? {
    // assert(date instanceOf String)

    // 0123456789012345678901234
    // 2011-10-17T13:00:00-07:00
    // 2011-10-17T16:30:55.000Z
    // 2011-10-17T16:30:55Z
    if (date.length() < 20) {
        return null;
    }

    var moment = Gregorian.moment({
        :year => date.substring(0, 4).toNumber(),
        :month => date.substring(5, 7).toNumber(),
        :day => date.substring(8, 10).toNumber(),
        :hour => date.substring(11, 13).toNumber(),
        :minute => date.substring(14, 16).toNumber(),
        :second => date.substring(17, 19).toNumber()
    });

    return moment;
}
