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

        // If the GPS request is already in progress, do nothing
        // var zmanimStatusCacheKey = $.getZmanimStatusCacheKey();
        // var zmanimRequestStatus = Storage.getValue(zmanimStatusCacheKey);
        // if (zmanimRequestStatus != null && zmanimRequestStatus.find("pending") != null) {
        //     $.log("Zmanim request already in progress...");
        //     return true;
        // }

        // TODO: Get GPS location
        // TODO: Set storage key indicating pending GPS. Update it when location is received in onPosition.

        // Refresh the UI for the pending state
        //* The main view will handle the new request state and render accordingly
        WatchUi.requestUpdate();

        return true;
    }
}
