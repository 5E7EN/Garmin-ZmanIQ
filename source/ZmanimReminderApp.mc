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

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        setCurrentLocation();
        setTodaysZmanim();
    }

    /*
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
        Sys.println("Fetching current watch location...");

        // Get watch location
        var activityLocation = Activity.getActivityInfo().currentLocation;
        var weatherLocation = Weather.getCurrentConditions().observationLocationPosition;
        var position = weatherLocation ? weatherLocation : activityLocation;

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

        setProperty("LastLocationLat", gLocationLat);
        setProperty("LastLocationLng", gLocationLng);

        Sys.println("Stored watch location.");
    }

    function setTodaysZmanim() {
        // Get current date
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateString = Lang.format("$1$-$2$-$3$", [today.year, today.month, today.day]);

        // Get stored location
        var latitude = getProperty("LastLocationLat");
        var longitude = getProperty("LastLocationLng");

        // If no location data exists, halt
        if (latitude == null || longitude == null) {
            Sys.println("Failed to detect GPS location.");
        }

        // Zmanim URL
        var zmanimUrl = "https://www.hebcal.com/zmanim?cfg=json&sec=1&date=" + dateString + "&latitude=" + latitude + "&longitude=" + longitude;

        // Fetch zmanim
        Sys.println("Fetching Zmanim -> " + zmanimUrl);
        Comm.makeWebRequest(zmanimUrl, {}, { :method => Comm.HTTP_REQUEST_METHOD_GET }, method(:handleZmanimResponse));
    }

    // Callback to handle receiving a response
    function handleZmanimResponse(responseCode as Lang.Number, data as Lang.Dictionary or Lang.String or PersistedContent.Iterator or Null) as Void {
        if (responseCode == 200) {
            if (data != null) {
                // Set zmanim in global storage
                setProperty("SofZmanShma", data["times"]["sofZmanShma"]);
                Sys.println("Stored zmanim");

                Sys.println("Got data, Sof Zman Kiras Shema is at: " + data["times"]["sofZmanShma"]);

                // Ui.requestUpdate();
            } else {
                Sys.println("Request returned no data -> " + data);
            }
        } else {
            Sys.println("Encountered non-OK response code: " + responseCode);
        }
    }
}
