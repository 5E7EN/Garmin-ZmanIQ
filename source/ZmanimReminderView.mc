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
        timeLabel.setText("Timer!");
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
        timeLabel.setText("Welcome!");
    }

    // Update the view
    // TODO: Figure out why this is re-rendering on launch more than once
    function onUpdate(dc) as Void {
        var app = App.getApp();

        // // If we got to this point, we assume that there haven't been any API related errors
        // Check if zmanim are already stored; then display if so
        var storedZman = app.getProperty("SofZmanShma");

        if (storedZman) {
            // TODO: Check if stored zmanim have expired. If so, clear
            Sys.println("[onUpdate] Zmanim retrieved from local storage.");

            var momentZman = parseISODate(storedZman);
            var parsedZman = Gregorian.info(momentZman, Time.FORMAT_SHORT);
            var zmanimForDate = parsedZman.month + "/" + parsedZman.day + "/" + parsedZman.year;
            var sofZmanKriasShma = parsedZman.hour + ":" + parsedZman.min + ":" + parsedZman.sec;
            timeLabel.setText("Zman Krias Shema: \n" + sofZmanKriasShma + "\nUpdated " + zmanimForDate);
        } else {
            // Determine status of Zmanim request, and show status on UI
            var currentZmanimStatus = app.getProperty("ZmanimRequestStatus");

            // Set default state if status is null
            // Since switch statement can't handle null value for some reason
            if (currentZmanimStatus == null) {
                currentZmanimStatus = "initial";
            }

            // Pending zmanim request & error handling
            Sys.println("[onUpdate] Current status of zmanim request: " + currentZmanimStatus.toUpper());
            switch (currentZmanimStatus) {
                case "initial":
                    // API request not yet executed, run logic below
                    Sys.println("[onUpdate] Zmanim not stored or have expired, updating...");
                    updateUiText("Fetching zmanim...", dc);
                    break;
                case "pending":
                    // If the API request is pending, return early to ensure another request isn't triggered below
                    // The request handler will invoke `WatchUi.requestUpdate()` once a response is received (after a relevant ZmanimRequestStatus is set)
                    updateUiText("Fetching zmanim...", dc);
                    return;
                case "error":
                    // Encountered error while fetching zmanim from API
                    updateUiText("Zmanim Error", dc);
                    System.println("[onUpdate] Error fetching Zmanim.");
                    return;
            }

            // Set and retrieve current watch location
            app.setCurrentLocation();
            var latitude = app.getProperty("LastLocationLat");
            var longitude = app.getProperty("LastLocationLng");

            // Ensure we have valid location data
            if (latitude == null || longitude == null) {
                Sys.println("[onUpdate] Location could not be retrieved. User must connect to phone or start an activity.");
                updateUiText("GPS Not Found", dc);
            } else {
                // Set current zmanim
                Sys.println("[onUpdate] Zmanim not found in local storage. Fetching new...");
                // This function will automatically refresh the UI (calling onUpdate againt) after updating the ZmanimRequestStatus
                // When onUpdate is invoked, the current status will be handled
                app.setTodaysZmanim();
            }
        }

        Sys.println("---");

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {}

    function updateUiText(message, dc) {
        timeLabel.setText(message);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

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
