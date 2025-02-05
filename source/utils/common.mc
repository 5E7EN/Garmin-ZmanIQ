import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

function padLeft(str as String, length as Number, char as String) as String {
    if (str == null) {
        return "";
    }

    var padLength = length - str.length();
    if (padLength <= 0) {
        return str;
    }

    var padding = "";
    for (var i = 0; i < padLength; i++) {
        padding += char;
    }

    return padding + str;
}

(:release)
public function log(message as String) {}

(:debug,:background)
public function log(message as String or Dictionary) {
    var info = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);

    Sys.println(
        Lang.format("$1$-$2$-$3$ $4$:$5$:$6$ - $7$", [
            info.year,
            padLeft(info.month.toString(), 2, "0"),
            padLeft(info.day.toString(), 2, "0"),
            info.hour.format("%02u"),
            info.min.format("%02u"),
            info.sec.format("%02u"),
            message
        ])
    );
}
