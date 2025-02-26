import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

//* This is the menu input delegate/handler for the menu of the application
class LocationInfoMenuDelegate extends WatchUi.Menu2InputDelegate {
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
        if (id == :reloadLocation) {
            $.log("[onSelect] User triggered location reload.");

            // Clear GPS related data from storage
            Storage.deleteValue($.getGpsStatusCacheKey());
            Storage.deleteValue($.getGpsInfoCacheKey());

            // Set pending refresh flag
            //* This will trigger a refresh of the zmanim top wrap menu when the user inevitably goes back to it from the bottom wrap menu.
            // $.setPendingRefresh(true);

            // Go back to zmanim menu
            //* Pop existing views to save memory.
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            $.switchToZmanimMenu(false);
        }
    }

    //* Handle the back key being pressed
    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
