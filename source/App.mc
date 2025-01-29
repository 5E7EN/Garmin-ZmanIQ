import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
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
        // If current location available from current weather or activity, save it in case it goes "stale" and can not longer be retrieved.
        Sys.println(
            "[updateCurrentLocation] Fetching current watch location..."
        );

        // Get watch location
        var activityLocation = Activity.getActivityInfo();
        var weatherLocation = Weather.getCurrentConditions();
        // Determine position based on which retrieval method has a valid value
        var position = weatherLocation
            ? weatherLocation.observationLocationPosition
            : activityLocation
            ? activityLocation.currentLocation
            : null;

        // Parse coordinates
        if (position) {
            position = position.toDegrees();
            gLocationLat = position[0].toFloat();
            gLocationLng = position[1].toFloat();
        } else {
            // If current location is not available, read stored value from Object Store, being careful not to overwrite a valid
            // in-memory value with an invalid stored one.
            var lat = getProperty("LastLocationLat");
            if (lat != null) {
                gLocationLat = lat;
            }

            var long = getProperty("LastLocationLng");
            if (long != null) {
                gLocationLng = long;
            }
        }

        // Ensure we have retrieved location data
        if (gLocationLat == null || gLocationLng == null) {
            Sys.println(
                "[updateCurrentLocation] Failed to retrieve GPS coordinates."
            );
            return;
        } else {
            setProperty("LastLocationLat", gLocationLat);
            setProperty("LastLocationLng", gLocationLng);

            Sys.println("[updateCurrentLocation] Stored watch location.");
        }

        Sys.println("[updateCurrentLocation] Latitude: " + gLocationLat);
        Sys.println("[updateCurrentLocation] Longitude: " + gLocationLng);
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
        var latitude = getProperty("LastLocationLat");
        var longitude = getProperty("LastLocationLng");

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
        setProperty("ZmanimRequestStatus", "pending");

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
                    var sofZmanKriasShma = data["times"]["sofZmanShma"];
                    setProperty("SofZmanShma", sofZmanKriasShma);

                    // Update status of API request for main UI
                    setProperty("ZmanimRequestStatus", "completed");

                    Sys.println(
                        "[handleZmanimResponse] Stored new remote zmanim to local cache."
                    );

                    // Set background alert reminder of the upcoming zman
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
                    setProperty("ZmanimRequestStatus", "error");
                }
            } else {
                Sys.println(
                    "[handleZmanimResponse] Request returned no data -> " + data
                );

                // Update status
                setProperty("ZmanimRequestStatus", "error");
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
            setProperty("ZmanimRequestStatus", "error");
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
