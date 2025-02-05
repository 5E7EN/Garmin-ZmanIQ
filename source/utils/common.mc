import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

(:release)
public function log(message as String) {}

(:debug,:background)
public function log(message as String or Dictionary) {
    var info = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);

    Sys.println(
        Lang.format("$1$-$2$-$3$ $4$:$5$:$6$ - $7$", [info.year, info.month, info.day, info.hour.format("%02u"), info.min.format("%02u"), info.sec.format("%02u"), message])
    );
}
