// https://stackoverflow.com/questions/58468168/how-to-re-open-a-connect-iq-app-from-a-background-process

using Toybox.WatchUi;
using Toybox.Application as App;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Application.Storage as Storage;

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
    // TODO: Figure out why this is re-rendering on launch more than once even when `storedZman` has a value
    function onUpdate(dc) as Void {
        var app = App.getApp();

        // Determine status of Zmanim request, and show status on UI
        var currentZmanimStatus = Storage.getValue("ZmanimRequestStatus");

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
        var remoteZmanData =
            Storage.getValue("RemoteZmanData") as Lang.Dictionary?;

        if (remoteZmanData != null) {
            var storedZmanShema = remoteZmanData["times"]["sofZmanShma"];

            // Parse stored zman as Moment object
            var momentZmanShemaUTC = app.parseISODateUTC(storedZmanShema);
            var gregorianZmanShema = Gregorian.info(
                momentZmanShemaUTC,
                Time.FORMAT_SHORT
            );

            // Ensure that the zmanim cached in local storage are today's zmanim
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
                "[onUpdate | DEBUG] Date of cached zman in our time: " +
                    Lang.format("$1$/$2$/$3$ $4$:$5$:$6$", [
                        gregorianZmanShema.month,
                        gregorianZmanShema.day,
                        gregorianZmanShema.year,
                        gregorianZmanShema.hour,
                        gregorianZmanShema.min,
                        gregorianZmanShema.sec
                    ])
            );

            // If the stored zmanim dates don't match exactly, we must update them
            // Otherwise, display from local storage instead of making a redundant API request
            if (
                gregorianZmanShema.month != greorianToday.month ||
                gregorianZmanShema.day != greorianToday.day ||
                gregorianZmanShema.year != greorianToday.year
            ) {
                // Not same day, reload zmanim
                Sys.println(
                    "[onUpdate] Cached zmanim are from another day, refreshing..."
                );
                Storage.deleteValue("RemoteZmanData");
                Storage.deleteValue("ZmanimRequestStatus");

                // Refresh UI to update zmanim
                WatchUi.requestUpdate();
                return;
            } else {
                // Same day, use cached zmanim
                Sys.println(
                    "[onUpdate] Cached zmanim are from today, retrieved from local storage."
                );

                // Get time as local to user's assumed location (not adjusting based on timezone in timestamp)
                var momentZmanShemaLocal = app.parseISODate(storedZmanShema);
                // It's not actually UTC, but the local time of the user's assumed location (original API-returned timestamp time)
                // This function basically just doesn't apply any conversions to the time, so we use it
                var gregorianLocalZmanShema = Gregorian.utcInfo(
                    momentZmanShemaLocal,
                    Time.FORMAT_SHORT
                );

                // Build the zman time to display
                var sofZmanKriasShma =
                    gregorianLocalZmanShema.hour +
                    ":" +
                    gregorianLocalZmanShema.min.format("%02d") +
                    ":" +
                    gregorianLocalZmanShema.sec.format("%02d");

                // Build the current date to display
                var zmanimForDate =
                    gregorianLocalZmanShema.month +
                    "/" +
                    gregorianLocalZmanShema.day +
                    "/" +
                    gregorianLocalZmanShema.year;

                // Get location source from local storage
                var locationSource = Storage.getValue(
                    "LocationRetrievalSource"
                );

                // Update the UI with the zmanim
                timeLabel.setText(
                    "Zman Krias Shema: \n" +
                        sofZmanKriasShma +
                        "\nUpdated " +
                        zmanimForDate +
                        "\nvia " +
                        locationSource
                );
            }
        } else {
            // Pending zmanim request & error handling
            switch (currentZmanimStatus) {
                case "initial":
                    // API request not yet executed, run logic below
                    Sys.println(
                        "[onUpdate] Zmanim not stored or were stale, updating..."
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
            app.updateCurrentLocation();
            var latitude = Storage.getValue("LastLocationLat");
            var longitude = Storage.getValue("LastLocationLng");

            // Ensure we have valid location data
            if (latitude == null || longitude == null) {
                Sys.println(
                    "[onUpdate] Location could not be retrieved. User must go outside, start an activity, or connect to phone for weather data."
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
