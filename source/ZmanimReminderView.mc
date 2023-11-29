// https://stackoverflow.com/questions/58468168/how-to-re-open-a-connect-iq-app-from-a-background-process

using Toybox.WatchUi;
using Toybox.Application as App;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.PersistedContent;

class ZmanimReminderView extends WatchUi.View {
    var timeLabel;

    function initialize() {
        View.initialize();

        timeLabel = null;
    }

    function timerCallback() as Void {
        Sys.println("Timer triggered!");
        timeLabel.setText("OK:");
    }

    // Load your resources here
    function onLayout(dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));

        timeLabel = View.findDrawableById("id_time_label");

        // var myTimer = new Timer.Timer();
        // Sys.println("Started timer...");
        // myTimer.start(method(:timerCallback), 5000, true);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        Sys.println("Started!!");
    }

    // Update the view
    // TODO: Figure out why this is re-rendering on launch more than once
    function onUpdate(dc) as Void {
        var app = App.getApp();

        timeLabel.setText("Hello!");

        // Retrieve watch location
        app.setCurrentLocation();
        var lat = app.getProperty("LastLocationLat");
        var lng = app.getProperty("LastLocationLng");

        Sys.println("Latitude: " + lat);
        Sys.println("Longitude: " + lng);
        Sys.println("---");

        // Check if zman is already stored, then display
        var storedZman = app.getProperty("SofZmanShma");
        var momentZman = parseISODate(storedZman);

        if (storedZman) {
            var parsedZman = Gregorian.info(momentZman, Time.FORMAT_SHORT);
            var sofZmanKriasShma = parsedZman.hour + ":" + parsedZman.min + ":" + parsedZman.sec;
            timeLabel.setText("Zman: " + sofZmanKriasShma);
            Sys.println("HI: " + sofZmanKriasShma);
        } else {
            // Make zmanim request
            Sys.println("Zmanim not found in local storage.");
            app.setTodaysZmanim();

            // Refresh
            WatchUi.requestUpdate();
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {}

    // Converts rfc3339 formatted timestamp to Time::Moment (returns null on error)
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
}
