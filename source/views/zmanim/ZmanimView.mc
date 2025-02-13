import Toybox.Graphics;
import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Application.Storage as Storage;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;

function switchToZmanimMenu() as Void {
    // TODO: If already on the zmanim menu, do nothing (prevent double-rendering)
    // TODO cont.: cannot use Ui.getCurrentView() because API level isn't supported on many watches

    // TODO: Cache zmanim to prevent having to make all calculations every render (like before, and set date key to check against for expiration of cached data)
    var dateToday = Time.now();
    var coordinates = $.getLocation() as Array;
    var elevation = 0; // $.getElevation() as Number?;
    var zmanim = $.getZmanim(dateToday, coordinates, elevation) as Array<ZmanTime>; // getZmanim(date as Time.Moment, coordinates as Array<String, String>, elevation as Number?) as DisplayedZmanimTimes

    // Ensure zmanim don't come back empty (type checked so should be fine, but I don't trust compiler)
    if (zmanim.size() == 0) {
        $.log("[switchToZmanimMenu] Zmanim are empty.");
        // TODO: Set error flag in Storage and re-render to show it
    }

    // Set title as current date
    // TODO: Set menu title as current hebrew date
    var greorianToday = Gregorian.info(new Time.Moment(Time.now().value()), Time.FORMAT_MEDIUM);
    var topMenu = new $.CustomWrapTopMenu(Lang.format("$1$ $2$", [greorianToday.month, greorianToday.day.format("%02d")]), 80, Graphics.COLOR_BLACK);

    // Build the menu
    for (var i = 0; i < zmanim.size(); i++) {
        var zman = zmanim[i];
        var zmanName = zman["name"] as String;
        var zmanTime = zman["time"] as Time.Moment;

        topMenu.addItem(createZmanMenuItem(zmanName, zmanTime));
    }

    // Set focus to the next upcoming zman, passing filtered zmanim
    var nextZman = $.getNextUpcomingZman(zmanim);
    if (nextZman != null) {
        $.log("[switchToZmanimMenu] Upcoming zman: " + nextZman[0]);

        // Get next zman by ID (which is the zman key)
        var nextZmanIndex = topMenu.findItemById(nextZman[0]);

        if (nextZmanIndex != -1) {
            topMenu.setFocus(nextZmanIndex);
        }
    } else {
        //* All zmanim have passed for the day.
        // Focus last zman
        topMenu.setFocus(zmanim.size() - 1);
    }

    Ui.switchToView(topMenu, new $.ZmanimTopDelegate(new Lang.Method($, :pushBottomZmanimMenu)), Ui.SLIDE_IMMEDIATE);
}

//* Create the sub-menu menu of the Wrap custom menu
function pushBottomZmanimMenu() as Void {
    var bottomMenu = new $.CustomWrapBottomMenu(80, Graphics.COLOR_WHITE);

    // menu.addItem(new Ui.MenuItem("Menu", null, :menu, null));
    bottomMenu.addItem(new $.CustomWrapItem("Reload Zmanim", null, :reloadZmanim, Graphics.COLOR_BLACK));
    bottomMenu.addItem(new $.CustomWrapItem("Settings", null, :settings, Graphics.COLOR_BLACK));

    Ui.pushView(bottomMenu, new $.ZmanimBottomDelegate(), Ui.SLIDE_UP);
}

//* Helper function to create a consistent menu item.
function createZmanMenuItem(zmanName as String, zmanTime as Time.Moment) as CustomWrapItem {
    // Get the friendly name for the zman key
    var friendlyName = $.ZmanimFriendlyNames[zmanName];

    if (friendlyName == null) {
        // Fallback to the key if no friendly name is found for some reason
        friendlyName = zmanName;
    }

    // Convert the zman time to a time string
    var timeString = $.parseMomentToTimeString(zmanTime);

    // Return the custom menu item
    return new $.CustomWrapItem(friendlyName, timeString, zmanName, Graphics.COLOR_WHITE);
}
