import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

//* This delegate is for the main page of our application that pushes the menu
//* when the onMenu() behavior is received.
class InitialDelegate extends WatchUi.BehaviorDelegate {
    var locationModel as LocationModel;
    var zmanimModel as ZmanimModel;

    //* Constructor
    public function initialize() {
        // Instantiate the location and zmanim models
        zmanimModel = new ZmanimModel();
        locationModel = new LocationModel();

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
        // If the zmanim request is already in progress, do nothing
        var zmanimRequestStatus = Storage.getValue("ZmanimRequestStatus");
        if (zmanimRequestStatus.equals("pending")) {
            $.log("Zmanim request already in progress...");
            return true;
        }

        // TODO: Ensure phone is connected (Sys.getDeviceSettings().phoneConnected == true)

        // Clear cached zmanim data
        Storage.deleteValue("RemoteZmanData");

        // Get the current location coordinates
        var coordinates = locationModel.getCoordinates() as Array?;

        // TODO: Ensure coordinates are not null

        // Set request status to pending
        Storage.setValue("ZmanimRequestStatus", "pending");

        // Fetch zmanim passing callback (seen below)
        zmanimModel.fetchZmanimCb(coordinates[0], coordinates[1], method(:handleZmanimResponse));

        // Refresh the UI for the pending state
        //* The main view will handle the new ZmanimRequestStatus state and render accordingly
        WatchUi.requestUpdate();

        return true;
    }

    //* Handles the response from the zmanim API
    function handleZmanimResponse(responseCode as Number, data as Dictionary or String or Null) as Void {
        // Check if the response is successful
        if (responseCode != 200) {
            // Update request status
            Storage.setValue("ZmanimRequestStatus", "error");
            $.log("[handleZmanimResponse] Zmanim request failed with status code: " + responseCode);
            $.log("[handleZmanimResponse] If in simulation, you may need to uncheck 'Use Device HTTPS requirements' under Settings");
        }

        if (data == null) {
            // Update request status
            Storage.setValue("ZmanimRequestStatus", "error");
            $.log("[handleZmanimResponse] Request returned no data");
        }

        // Ensure zmanim were returned in expected format, then store in cache
        // TODO: Use typedef for data structure
        if (data["times"] != null && data["times"]["sofZmanShma"] != null) {
            // Store zmanim in Storage cache
            Storage.setValue("RemoteZmanData", data);

            // Update request status
            Storage.setValue("ZmanimRequestStatus", "completed");

            $.log("[handleZmanimResponse] Success! Stored fresh zmanim in cache.");
        } else {
            // Update request status
            Storage.setValue("ZmanimRequestStatus", "error");
            $.log("[handleZmanimResponse] API returned data, but desired zmanim format not found.");
            $.log("[handleZmanimResponse] Data: " + data);
        }

        // Refresh the UI
        //* The main view will handle the new ZmanimRequestStatus state and render accordingly
        WatchUi.requestUpdate();
    }
}
