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
        //* Refresh zmanim

        Sys.println("Fetching new zmanim...");

        // Clear cached zmanim data
        Storage.deleteValue("RemoteZmanData");
        Storage.deleteValue("ZmanimRequestStatus");

        //! Call the zmanim refresh model here

        // Refresh the UI with the new zmanim data
        WatchUi.requestUpdate();

        return true;
    }
}
