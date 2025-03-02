import Toybox.Lang;

using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

//* Converts Time.Moment to time string (e.g. 12:30:03 PM). Accounts for 24-hour time device setting.
function parseMomentToTimeString(moment as Time.Moment) as String {
    // Determine if the device is set to 24-hour time
    var is24Hour = Sys.getDeviceSettings().is24Hour;

    // Convert the moment into a Gregorian object
    var gregorianZman = Gregorian.info(moment, Time.FORMAT_SHORT);

    // Format the time string, converting to 12-hour format if necessary
    var parsed = Lang.format("$1$:$2$:$3$$4$", [
        is24Hour ? gregorianZman.hour : 1 + ((gregorianZman.hour + 11) % 12),
        gregorianZman.min.format("%02u"),
        gregorianZman.sec.format("%02u"),
        is24Hour ? "" : gregorianZman.hour < 12 ? " AM" : " PM"
    ]);

    return parsed;
}

function formatTimeAgo(epochSeconds as Number) as String? {
    if (epochSeconds == null || !(epochSeconds instanceof Number)) {
        $.log("[formatTimeAgo] Invalid epoch seconds: " + epochSeconds);
        return null;
    }

    var now = Time.now();
    var duration = now.subtract(new Time.Duration(epochSeconds));
    var seconds = duration.value();

    if (seconds < 0) {
        // Handle future time (should not happen with proper usage)
        return null;
    }

    if (seconds < 60) {
        return seconds + " seconds ago";
    }

    var minutes = (seconds / 60).toNumber();
    if (minutes < 60) {
        return minutes + (minutes == 1 ? " minute" : " minutes") + " ago";
    }

    var hours = (minutes / 60).toNumber();
    if (hours < 24) {
        return hours + (hours == 1 ? " hour" : " hours") + " ago";
    }

    var days = (hours / 24).toNumber();
    if (days < 30) {
        // Approximate months
        return days + (days == 1 ? " day" : " days") + " ago";
    }

    // Approximate months. We don't need perfect accuracy.
    var months = (days / 30.44).toNumber(); // Average days in a month
    if (months < 12) {
        return months + (months == 1 ? " month" : " months") + " ago";
    }

    // Approximate years
    var years = (months / 12).toNumber();
    return years + (years == 1 ? " year" : " years") + " ago";
}
