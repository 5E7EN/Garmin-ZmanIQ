import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.PersistedContent;

var gLocationLat = null;
var gLocationLng = null;

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

        return [currentView];
    }

    function getView() {
        return currentView;
    }

    function setCurrentLocation() {
        // Attempt to update current location.
        // If current location available from current weather or activity, save it in case it goes "stale" and can not longer be retrieved.
        Sys.println("[setCurrentLocation] Fetching current watch location...");

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
                "[setCurrentLocation] Failed to retrieve GPS coordinates."
            );
            return;
        } else {
            setProperty("LastLocationLat", gLocationLat);
            setProperty("LastLocationLng", gLocationLng);

            Sys.println("[setCurrentLocation] Stored watch location.");
        }

        Sys.println("[setCurrentLocation] Latitude: " + gLocationLat);
        Sys.println("[setCurrentLocation] Longitude: " + gLocationLng);
        // Sys.println("---");
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
                    setProperty("SofZmanShma", data["times"]["sofZmanShma"]);

                    // Set last updated time
                    var zmanimLastUpdated = Time.now().value();
                    setProperty("ZmanimLastUpdated", zmanimLastUpdated);

                    // Update status of API request for main UI
                    setProperty("ZmanimRequestStatus", "completed");

                    Sys.println(
                        "[handleZmanimResponse] Stored new remote zmanim. The time is now " +
                            zmanimLastUpdated +
                            "."
                    );
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

            // Update status
            setProperty("ZmanimRequestStatus", "error");
        }

        // Refresh UI to update status message / show zmanim (triggers onUpdate)
        WatchUi.requestUpdate();
    }
}
