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
