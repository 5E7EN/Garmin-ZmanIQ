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

        // Determine status of Zmanim request, and show status on UI
        var currentZmanimStatus = app.getProperty("ZmanimRequestStatus");

        // Set default state if status is null
        // Since switch statement can't handle null value for some reason
        if (currentZmanimStatus == null) {
            currentZmanimStatus = "initial";
        }

        // Print the current status of zmanim API request
        Sys.println(
            "[onUpdate] Current status of zmanim request: " +
                currentZmanimStatus.toUpper()
        );

        // Check if zmanim are already stored; then display if so
        var storedZman = app.getProperty("SofZmanShma");

        if (storedZman) {
            // Parse stored zman as Moment object
            var momentZman = app.parseISODate(storedZman);
            var gregorianZman = Gregorian.info(momentZman, Time.FORMAT_SHORT);

            // Ensure that the zmanim cached in local storage are today's
            var greorianToday = Gregorian.info(
                new Time.Moment(Time.now().value()),
                Time.FORMAT_SHORT
            );

            // Debug
            Sys.println(
                "[onUpdate | DEBUG] Date today: " +
                    Lang.format("$1$/$2$/$3$", [
                        greorianToday.month,
                        greorianToday.day,
                        greorianToday.year
                    ])
            );
            Sys.println(
                "[onUpdate | DEBUG] Date of cached zmanim: " +
                    Lang.format("$1$/$2$/$3$", [
                        gregorianZman.month,
                        gregorianZman.day,
                        gregorianZman.year
                    ])
            );

            // If the stored zmanim dates don't match exactly, we must update them
            // Otherwise, display from local storage instead of making a redundant API request
            if (
                gregorianZman.month != greorianToday.month ||
                gregorianZman.day != greorianToday.day ||
                gregorianZman.year != greorianToday.year
            ) {
                // Not same day, reload zmanim
                Sys.println(
                    "[onUpdate] Cached zmanim are from another day, refreshing..."
                );
                app.deleteProperty("SofZmanShma");
                app.deleteProperty("ZmanimRequestStatus");

                // Refresh UI to update zmanim
                WatchUi.requestUpdate();
                return;
            } else {
                // Same day, use cached zmanim
                Sys.println(
                    "[onUpdate] Cached zmanim are from today, retrieved from local storage."
                );

                var sofZmanKriasShma =
                    gregorianZman.hour +
                    ":" +
                    gregorianZman.min.format("%02d") +
                    ":" +
                    gregorianZman.sec.format("%02d");
                var zmanimForDate =
                    gregorianZman.month +
                    "/" +
                    gregorianZman.day +
                    "/" +
                    gregorianZman.year;

                timeLabel.setText(
                    "Zman Krias Shema: \n" +
                        sofZmanKriasShma +
                        "\nUpdated " +
                        zmanimForDate
                );
            }
        } else {
            // Pending zmanim request & error handling
            switch (currentZmanimStatus) {
                case "initial":
                    // API request not yet executed, run logic below
                    Sys.println(
                        "[onUpdate] Zmanim not stored or have expired, updating..."
                    );
                    updateUiText("Updating zmanim...", dc);
                    break;
                case "pending":
                    // If the API request is pending, return early to ensure another request isn't triggered below
                    // The request handler will invoke `WatchUi.requestUpdate()` once a response is received (after a relevant ZmanimRequestStatus is set)
                    updateUiText("Updating zmanim...", dc);
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
                Sys.println(
                    "[onUpdate] Location could not be retrieved. User must connect to phone or start an activity."
                );
                updateUiText("GPS Not Found", dc);
            } else {
                // Set current zmanim
                Sys.println(
                    "[onUpdate] Zmanim not found in local storage. Fetching new..."
                );
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
}
