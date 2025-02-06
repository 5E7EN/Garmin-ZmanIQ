import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

//* This delegate is for the main page of our application that pushes the menu
//* when the onMenu() behavior is received.
class InitialDelegate extends WatchUi.BehaviorDelegate {
    //* Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
    }

    //* Handle the menu button click event
    //* @return true if handled, false otherwise
    public function onMenu() as Boolean {
        // Render the main menu found in menus/main/View.mc
        $.pushMainMenuView();

        return true;
    }

    //* Handle the select/start/enter button click event
    //* @return true if handled, false otherwise
    public function onSelect() as Boolean {
        $.log("[onSelect] SELECT button pressed");

        var zmanimStatusCacheKey = $.getZmanimStatusCacheKey();

        // If the zmanim request is already in progress, do nothing
        var zmanimRequestStatus = Storage.getValue(zmanimStatusCacheKey);
        if (zmanimRequestStatus.equals("pending")) {
            $.log("Zmanim request already in progress...");
            return true;
        }

        // TODO: Ensure phone is connected (Sys.getDeviceSettings().phoneConnected == true)

        // Clear cached zmanim data, if any
        $.clearZmanim();

        // Get the current location coordinates
        // TODO: Make this global module like zmanim
        var coordinates = $.getLocation();

        // TODO: Ensure coordinates are not null

        // Set request status to pending
        Storage.setValue(zmanimStatusCacheKey, "pending");

        // Fetch zmanim passing callback (seen below)
        $.loadZmanim(coordinates[0], coordinates[1], method(:handleZmanimResponse));

        // Refresh the UI for the pending state
        //* The main view will handle the new ZmanimRequestStatus state and render accordingly
        WatchUi.requestUpdate();

        return true;
    }

    //* Handles the response from the zmanim API
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
}
