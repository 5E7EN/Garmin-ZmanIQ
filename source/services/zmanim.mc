import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application.Storage as Storage;

//* Refreshes locally cached zmanim. This will set the zmanim request status to "pending".
//* Call `WatchUi.requestUpdate()` after invoking this method to refresh the UI to reflect the pending state.
function refreshZmanim() as Void {
    var zmanimStatusCacheKey = $.getZmanimStatusCacheKey();

    // TODO: Ensure phone is connected (Sys.getDeviceSettings().phoneConnected == true)

    // Clear cached zmanim data, if any
    clearZmanim();

    // Get the current location coordinates
    var coordinates = $.getLocation();

    // TODO: Ensure coordinates are not null

    // Set request status to pending
    Storage.setValue(zmanimStatusCacheKey, "pending");

    // Fetch zmanim, passing callback (seen below)
    loadZmanim(coordinates[0], coordinates[1], new Lang.Method($, :handleZmanimResponse));
}

//* Fetches and loads zmanim from the Hebcal API into storage
function loadZmanim(latitude as Float, longitude as Float, callback as WebRequestDelegateCallback) as Void {
    // Ensure latitude and longitude are not null
    if (latitude == null || longitude == null) {
        $.log("[loadZmanim] GPS coordinates not provided.");
        return;
    }

    $.log("[loadZmanim] Loading new zmanim...");

    // Get current date string
    var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var dateString = Lang.format("$1$-$2$-$3$", [today.year, today.month.format("%02d"), today.day.format("%02d")]);

    // Build zmanim API URL
    var zmanimUrl = "https://www.hebcal.com/zmanim?cfg=json&sec=1&date=" + dateString + "&latitude=" + latitude.toString() + "&longitude=" + longitude.toString();
    $.log("[loadZmanim] Zmanim URL -> " + zmanimUrl);

    // Get zmanim storage key
    var storageKey = $.getZmanimCacheKey();

    $.makeApiRequest(zmanimUrl, storageKey, callback);
}

//* Handles the response from the zmanim API.
//* The zmanim request status will be updated based on the results - and the UI will be refreshed.
function handleZmanimResponse(responseCode as Number, data as ZmanimApiResponse?) as Void {
    var zmanimStatusCacheKey = $.getZmanimStatusCacheKey();

    // Update the request status based on request result
    if (responseCode != 200) {
        // Update request status
        Storage.setValue(zmanimStatusCacheKey, "error");
        $.log("[handleZmanimResponse] Zmanim request failed with status code: " + responseCode);
        $.log("[handleZmanimResponse] If in simulation, you may need to uncheck 'Use Device HTTPS requirements' under Settings");
    }

    // Ensure we got data back from the API
    if (data == null) {
        // Update request status
        Storage.setValue(zmanimStatusCacheKey, "error");
        $.log("[handleZmanimResponse] Request returned no data.");
    } else {
        // Ensure zmanim were returned in expected format, then store in cache
        if (data["times"] != null && data["times"]["sofZmanShma"] != null) {
            // Update request status
            Storage.setValue(zmanimStatusCacheKey, "completed");

            $.log("[handleZmanimResponse] Response format validated. Marked request status as completed.");
        } else {
            // Update request status
            Storage.setValue(zmanimStatusCacheKey, "error");

            $.log("[handleZmanimResponse] API returned data, but desired zmanim format not found.");
            $.log("[handleZmanimResponse] Data: " + data);
        }
    }

    // Refresh the UI
    //* The main view will handle the new ZmanimRequestStatus state and render accordingly
    WatchUi.requestUpdate();
}

//* Clears existing zmanim and metadata from storage
function clearZmanim() as Void {
    Storage.deleteValue($.getZmanimCacheKey());
    Storage.deleteValue($.getZmanimStatusCacheKey());
}

//* Checks if the provided zmanim are stale (are not for today)
function checkIfZmanimStale(data as ZmanimApiResponse) as Boolean {
    var zmanShema = data["times"]["sofZmanShma"];

    // Parse stored zman as Moment object
    var momentZmanShemaUTC = $.parseISODate(zmanShema);
    var gregorianZmanShema = Gregorian.info(momentZmanShemaUTC, Time.FORMAT_SHORT);

    // Ensure that the zmanim cached in local storage are today's zmanim
    var greorianToday = Gregorian.info(new Time.Moment(Time.now().value()), Time.FORMAT_SHORT);

    // If the stored zmanim dates don't match exactly, we must update them
    // Otherwise, display from local storage instead of making a redundant API request
    if (gregorianZmanShema.month != greorianToday.month || gregorianZmanShema.day != greorianToday.day || gregorianZmanShema.year != greorianToday.year) {
        //* Not same day
        return true;
    } else {
        //* Same day
        return false;
    }
}

//* Determines the next upcoming zman from a given list of zmanim times
//* Returns null if all zmanim have already passed
function getNextUpcomingZman(zmanim as ZmanimTimes) as Array<String?>? {
    var zmanKeys = zmanim.keys();
    var zmanValues = zmanim.values();

    var currentTime = Time.now().value();
    var closestZmanName = null;
    var closestZmanTime = null;
    var minDifference = null;

    // Find the next upcoming zman
    for (var i = 0; i < zmanKeys.size(); i++) {
        var name = zmanKeys[i];
        var time = zmanValues[i];

        var momentZmanUTC = $.parseISODate(time);
        // Ensure current zman index is after current time (i.e. in the future)
        if (momentZmanUTC.value() > currentTime) {
            // Ensure zman time at current index is earlier than existing "earliest" zman
            if (minDifference == null || momentZmanUTC.value() < minDifference) {
                closestZmanName = name;
                closestZmanTime = time;
                minDifference = momentZmanUTC.value();
            }
        }
    }

    // If no zman today was after current time, return empty handed
    if (minDifference == null) {
        // TODO: If all passed today, call this function with tomorrow's zmanim to get real next time
        return null;
    }

    // Return results
    return [closestZmanName, closestZmanTime];
}
