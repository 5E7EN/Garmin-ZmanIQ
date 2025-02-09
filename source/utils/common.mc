import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

//* Splits string by delimiter.
function splitString(string, delimiter) {
    var result = [];
    var startIndex = 0;
    var delLen = delimiter.length();

    while (true) {
        var iend = string.find(delimiter);

        // Delimiter not found, handle the last part
        if (iend == null) {
            if (startIndex < string.length()) {
                // Check if there's any remaining string
                var lastPart = string.substring(startIndex, string.length());
                // Add the last part without toNumber()
                result.add(lastPart);
            }

            break;
        }

        var part = string.substring(startIndex, iend);
        // Add the extracted part to the result array.
        result.add(part);
        // Update startIndex for the next iteration
        startIndex = iend + delLen;

        string = string.substring(startIndex, string.length());
        startIndex = 0;
    }

    return result;
}

(:release)
public function log(message as String) {}

(:debug,:background)
public function log(message as String or Dictionary) {
    var info = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);

    Sys.println(
        Lang.format("$1$-$2$-$3$ $4$:$5$:$6$ - $7$", [
            info.year,
            info.month.format("%02u"),
            info.day.format("%02u"),
            info.hour.format("%02u"),
            info.min.format("%02u"),
            info.sec.format("%02u"),
            message
        ])
    );
}
