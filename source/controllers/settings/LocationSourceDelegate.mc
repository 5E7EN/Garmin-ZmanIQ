import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Application.Properties as Properties;

//* This is the menu input delegate/handler for the main menu of the application
class LocationSourceDelegate extends WatchUi.Menu2InputDelegate {
    //* Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    //* Handle an item being selected
    //* @param item The selected menu item
    public function onSelect(item as MenuItem) as Void {
        // Get the ID of the selected item
        var id = item.getId();

        // React based on the selected item ID
        if (id == :auto) {
            Properties.setValue("locationSource", "Auto");
        } else if (id == :gps) {
            Properties.setValue("locationSource", "GPS");
        } else if (id == :weather) {
            Properties.setValue("locationSource", "Weather");
        } else if (id == :last_activity) {
            Properties.setValue("locationSource", "Activity");
        }

        // TODO: Show toast explaining implications of the change (see TODO)

        // Go back and refresh the main menu
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    //* Handle the back key being pressed
    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
