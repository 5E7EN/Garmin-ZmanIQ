import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

//* This delegate is for the main page of our application that pushes the menu
//* when the onMenu() behavior is received.
class ZmanimDelegate extends WatchUi.Menu2InputDelegate {
    //* Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    //* Handle the select/start/enter button click event
    //* @return true if handled, false otherwise
    public function onSelect(item as MenuItem) as Void {
        var id = item.getId();

        // React based on the selected item ID
        if (id == :menu) {
            // Render zmanim menu
            $.pushZmanimMenuView();
        } else {
            // TODO: Expand zman
        }
    }

    //* Handle the user navigating off the end of the menu
    //* @param key The key triggering the menu wrap
    //* @return true if wrap is allowed, false otherwise
    public function onWrap(key as Key) as Boolean {
        // Don't allow wrapping
        return false;
    }
}
