import Toybox.Graphics;
import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;

function switchToZmanimMenu(skipZmanAutoFocus as Boolean?) as Void {
    // TODO: If already on the zmanim menu, do nothing (prevent double-rendering)
    // TODO cont.: cannot use Ui.getCurrentView() because API level isn't supported on many watches

    // If there's an error, switch to initial view to display the error message
    var zmanimErrorMessage = Storage.getValue($.getZmanimErrorMessageCacheKey());
    if (zmanimErrorMessage != null) {
        $.log("[switchToZmanimMenu] Error message found. Switching to initial view...");

        // Switch to the initial view
        Ui.switchToView(new $.InitialView(), new $.InitialDelegate(), Ui.SLIDE_IMMEDIATE);
        return;
    }

    // Retrieve the current location
    var location = $.getLocation() as LocationInfo?;

    // If no location/coordinates are available, switch to initial view
    //* Initial view will handle lack of location and render accordingly. It will do this same check there too.
    if (location == null) {
        //* This isn't reached upon error necessarily, but rather when location is not available via the chosen source.
        Ui.switchToView(new $.InitialView(), new $.InitialDelegate(), Ui.SLIDE_IMMEDIATE);
        return;
    }

    // Get zmanim
    // TODO: Allow user to select zmanim for a different date
    var dateToday = Time.now();
    var coordinates = location["coordinates"];
    var elevation = location["elevation"];
    var zmanim = $.getZmanim(dateToday, coordinates, elevation) as Array<ZmanTime>; // getZmanim(date as Time.Moment, coordinates as Array<String, String>, elevation as Number?) as DisplayedZmanimTimes

    // Ensure zmanim don't come back empty (type checked so should be fine, but I don't trust compiler)
    if (zmanim.size() == 0) {
        $.log("[switchToZmanimMenu] Zmanim are empty. Refreshing view for error state...");

        // Switch to main view (is likely already the current one)
        //* The main view will handle the error and render accordingly.
        Ui.switchToView(new $.InitialView(), new $.InitialDelegate(), Ui.SLIDE_IMMEDIATE);
        return;
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
    if (nextZman != null && skipZmanAutoFocus != true) {
        $.log("[switchToZmanimMenu] Upcoming zman: " + nextZman[0]);

        // Get next zman by ID (which is the zman key)
        var nextZmanIndex = topMenu.findItemById(nextZman[0]);

        if (nextZmanIndex != -1) {
            topMenu.setFocus(nextZmanIndex);
        }
    } else {
        //* All zmanim have passed for the day or user is navigating from a submenu. Focus the last zman.

        topMenu.setFocus(zmanim.size() - 1);
    }

    Ui.switchToView(topMenu, new $.ZmanimTopDelegate(new Lang.Method($, :pushBottomZmanimMenu)), Ui.SLIDE_IMMEDIATE);
}

//* Create the sub-menu menu of the Wrap custom menu
function pushBottomZmanimMenu() as Void {
    var locationSource = Properties.getValue("locationSource");
    var bottomMenu = new $.CustomWrapBottomMenu(80, Graphics.COLOR_WHITE);

    // menu.addItem(new Ui.MenuItem("Menu", null, :menu, null));
    // bottomMenu.addItem(new $.CustomWrapItem("Reload Zmanim", null, :reloadZmanim, Graphics.COLOR_BLACK));
    bottomMenu.addItem(new $.CustomWrapItem("Settings", null, :settings, Graphics.COLOR_BLACK));

    // Add GPS info menu option, if location source is set to GPS
    if (locationSource.equals("GPS")) {
        bottomMenu.addItem(new $.CustomWrapItem("GPS Info", null, :gpsInfo, Graphics.COLOR_BLACK));
    }

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
