import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

function pushLocationSourceView() as Void {
    // Generate a new Menu
    var menu = new WatchUi.Menu2({ :title => "Location Source" });

    // Add menu items
    menu.addItem(new WatchUi.MenuItem("Auto", null, :auto, null));
    menu.addItem(new WatchUi.MenuItem("GPS", "Most precise, outdoors", :gps, null));
    menu.addItem(new WatchUi.MenuItem("Weather", "Last synced location", :weather, null));
    menu.addItem(new WatchUi.MenuItem("Last Activity", "Last active location", :last_activity, null));
    // TODO: Add "Manual" option to enter latitude and longitude coordinates

    // Determine selected item and focus it
    // TODO: Improve this code. Search for the selected item by value instead of mapping each index
    var locationSource = Storage.getValue("LocationSource") as String;

    if (locationSource.equals("Auto")) {
    } else if (locationSource.equals("GPS")) {
        menu.setFocus(1);
    } else if (locationSource.equals("Weather")) {
        menu.setFocus(2);
    } else if (locationSource.equals("Activity")) {
        menu.setFocus(3);
    }

    WatchUi.pushView(menu, new $.LocationSourceDelegate(), WatchUi.SLIDE_UP);
}
