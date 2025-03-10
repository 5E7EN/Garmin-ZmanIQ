import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Application.Storage as Storage;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.PersistedContent;
using Toybox.Background as Bg;

var gLocationLat = null;
var gLocationLng = null;

(:background)
class ZmanimReminderApp extends Application.AppBase {
    var currentView;

    function initialize() {
        AppBase.initialize();
    }

    /*
    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }
    */

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        currentView = new ZmanimReminderView();

        return [currentView, new ZmanimReminderInputDelegate()];
    }

    function getView() {
        return currentView;
    }

    (:background_method)
    function getServiceDelegate() {
        return [new ZmanimReminderBackgroundDelegate()];
    }

    function updateCurrentLocation() {
        // Attempt to update current location.
        Sys.println(
            "[updateCurrentLocation] Fetching current watch location..."
        );

        // Get location from activity and weather
        // TODO: Add check to ensure device supports on-demand GPS positioning (hasConfigurationSupport)
        // var gpsLocation = Position.getInfo(); // Most reliable, up-to-date
        var weatherLocation = Weather.getCurrentConditions(); // Medium reliable
        var activityLocation = Activity.getActivityInfo(); // Least reliable, based on last recorded activity

        var position = null;
        var locationRetrievalSource = null;

        // Try to get location by order of reliability
        // if (gpsLocation has :position && gpsLocation.position != null) {
        //     position = gpsLocation.position.toDegrees();
        //     locationRetrievalSource = "GPS";

        //     Sys.println(
        //         "[updateCurrentLocation] Found GPS location: " + position
        //     );
        // } else
        if (
            weatherLocation != null &&
            weatherLocation.observationLocationPosition != null
        ) {
            position = weatherLocation.observationLocationPosition.toDegrees();
            locationRetrievalSource = "Weather";

            Sys.println(
                "[updateCurrentLocation] Found weather location: " + position
            );
        } else if (
            activityLocation != null &&
            activityLocation.currentLocation != null
        ) {
            position = activityLocation.currentLocation.toDegrees();
            locationRetrievalSource = "Activity";

            Sys.println(
                "[updateCurrentLocation] Found activity location: " + position
            );
        }

        // Parse coordinates only if position is valid
        if (position) {
            if (position.size() == 2) {
                gLocationLat = position[0].toFloat();
                gLocationLng = position[1].toFloat();

                // Store the values persistently
                Storage.setValue("LastLocationLat", gLocationLat);
                Storage.setValue("LastLocationLng", gLocationLng);
                Storage.setValue(
                    "LocationRetrievalSource",
                    locationRetrievalSource
                );

                Sys.println(
                    "[updateCurrentLocation] Updated and stored location: " +
                        position
                );
            }
        } else {
            Sys.println(
                "[updateCurrentLocation] No valid live GPS data. Using stored location..."
            );

            // Try to get stored location
            var lat = Storage.getValue("LastLocationLat");
            var lng = Storage.getValue("LastLocationLng");

            if (lat != null && lng != null) {
                gLocationLat = lat.toFloat();
                gLocationLng = lng.toFloat();
                Sys.println(
                    "[updateCurrentLocation] Loaded stored location: Lat " +
                        gLocationLat +
                        ", Lng " +
                        gLocationLng
                );
            } else {
                Sys.println(
                    "[updateCurrentLocation] Failed to retrieve GPS coordinates."
                );
            }
        }
    }

    function setTodaysZmanim() {
        Sys.println("[setTodaysZmanim] Fetching new zmanim...");

        // Get current date
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateString = Lang.format("$1$-$2$-$3$", [
            today.year,
            today.month.format("%02d"),
            today.day.format("%02d")
        ]);

        // Get stored GPS coordinates
        var latitude = Storage.getValue("LastLocationLat");
        var longitude = Storage.getValue("LastLocationLng");

        // If no location data exists, halt
        if (latitude == null || longitude == null) {
            Sys.println(
                "[setTodaysZmanim] Failed to retrieve GPS coordinates since global values are empty."
            );
            return;
        }

        // Zmanim URL
        var zmanimUrl =
            "https://www.hebcal.com/zmanim?cfg=json&sec=1&date=" +
            dateString +
            "&latitude=" +
            latitude +
            "&longitude=" +
            longitude;
        Sys.println("[setTodaysZmanim] Zmanim URL -> " + zmanimUrl);

        // Update status of API request for main UI
        Storage.setValue("ZmanimRequestStatus", "pending");

        // Fetch zmanim
        Comm.makeWebRequest(
            zmanimUrl,
            {},
            { :method => Comm.HTTP_REQUEST_METHOD_GET },
            method(:handleZmanimResponse)
        );
    }

    // Callback to handle receiving a response from the Zmanim endpoint
    function handleZmanimResponse(
        responseCode as Lang.Number,
        data as
            Lang.Dictionary or Lang.String or PersistedContent.Iterator or Null
    ) as Void {
        if (responseCode == 200) {
            if (data != null) {
                // Ensure zmanim were returned in a proper format; otherwise, set error status
                if (
                    data["times"] != null &&
                    data["times"]["sofZmanShma"] != null
                ) {
                    // Set zmanim in global storage
                    Storage.setValue("RemoteZmanData", data);

                    // Update status of API request for main UI
                    Storage.setValue("ZmanimRequestStatus", "completed");

                    Sys.println(
                        "[handleZmanimResponse] Stored new remote zmanim to local cache."
                    );

                    // Set background alert reminder of the upcoming zman krias shema
                    // TODO: Allow the ability to toggle this feature
                    var sofZmanKriasShma = data["times"]["sofZmanShma"];
                    // TODO: Add checks to ensure that only one reminder/temporal event is set at a given time - NO NEED, anything existing will be overwritten
                    // TODO: Allow this number below to be configurable
                    var minutesBeforeZmanToRemind = 5; // 5 minutes

                    // Parse zman and calculate X minutes before the zman
                    var sofZmanKriasShmaMoment = parseISODate(sofZmanKriasShma);
                    var zmanMinusReminderTimeMoment =
                        sofZmanKriasShmaMoment.subtract(
                            new Time.Duration(minutesBeforeZmanToRemind * 60)
                        );
                    var zmanMinusReminderTimeInfo = Gregorian.utcInfo(
                        zmanMinusReminderTimeMoment,
                        Time.FORMAT_SHORT
                    );

                    // Set reminder trigger
                    //? Only one temporal event can be registered at a given time, so no need to worry about anything already pending
                    // Only register trigger if the zman didn't yet pass
                    if (
                        zmanMinusReminderTimeMoment.value() > Time.now().value()
                    ) {
                        Sys.println(
                            "[handleZmanimResponse] Registering reminder background event for -> " +
                                Lang.format("$1$:$2$:$3$ $4$/$5$/$6$", [
                                    zmanMinusReminderTimeInfo.hour,
                                    zmanMinusReminderTimeInfo.min.format(
                                        "%02d"
                                    ),
                                    zmanMinusReminderTimeInfo.sec.format(
                                        "%02d"
                                    ),
                                    zmanMinusReminderTimeInfo.month,
                                    zmanMinusReminderTimeInfo.day,
                                    zmanMinusReminderTimeInfo.year
                                ])
                        );

                        // Register for temporal event
                        Bg.registerForTemporalEvent(
                            zmanMinusReminderTimeMoment
                        );
                    } else {
                        Sys.println(
                            "[handleZmanimResponse] Zman has already passed. Aborted reminder notification!"
                        );
                    }
                    // For debugging:
                    // Bg.registerForTemporalEvent(
                    //     (new Time.Moment(Time.now().value())).add(
                    //         new Time.Duration(10)
                    //     )
                    // );
                } else {
                    Sys.println(
                        "[handleZmanimResponse] API returned data, but desired zmanim format not found."
                    );
                    Sys.println("[handleZmanimResponse] Data: " + data);

                    // Update status
                    Storage.setValue("ZmanimRequestStatus", "error");
                }
            } else {
                Sys.println(
                    "[handleZmanimResponse] Request returned no data -> " + data
                );

                // Update status
                Storage.setValue("ZmanimRequestStatus", "error");
            }
        } else {
            Sys.println(
                "[handleZmanimResponse] Encountered non-OK response code: " +
                    responseCode
            );
            Sys.println("[handleZmanimResponse] Data: " + data);
            Sys.println(
                "[handleZmanimResponse] If in simulation, you may need to uncheck 'Use Device HTTPS requirements' under Settings"
            );

            // Update status
            Storage.setValue("ZmanimRequestStatus", "error");
        }

        // Refresh UI to update status message / show zmanim (triggers onUpdate)
        WatchUi.requestUpdate();
    }

    // Converts rfc3339 formatted timestamp to Time::Moment - as UTC (returns null on error)
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
            tzOffset =
                suffix.substring(tz + 1, tz + 3).toNumber() *
                Gregorian.SECONDS_PER_HOUR;
            tzOffset +=
                suffix.substring(tz + 4, tz + 6).toNumber() *
                Gregorian.SECONDS_PER_MINUTE;

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

    // Converts rfc3339 formatted timestamp to Time::Moment - retaining timezone (returns null on error)
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
}
