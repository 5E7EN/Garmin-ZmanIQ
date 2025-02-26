import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

//* This is the menu input delegate/handler for the menu of the application
class GpsInfoMenuDelegate extends WatchUi.Menu2InputDelegate {
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
        if (id == :reloadGps) {
            $.log("[onSelect] User triggered GPS reload.");

            // Clear the GPS status and info from storage
            Storage.deleteValue($.getGpsStatusCacheKey());
            Storage.deleteValue($.getGpsInfoCacheKey());

            // Set pending refresh flag
            $.setPendingRefresh(true);

            // Switch to zmanim menu
            //* The zmanim menu will try to get location, see there is none, and switch to initial view.
            $.switchToZmanimMenu(false);
        }
    }

    //* Handle the back key being pressed
    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
