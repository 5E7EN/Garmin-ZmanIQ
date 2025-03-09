import Toybox.Graphics;
import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;

//* @param skipZmanAutoFocus If true, skip auto-focusing the next zman.
//* @param focusID The ID of the zman to focus on. If null, auto-focus the next upcoming zman (unless skipZmanAutoFocus is true).
function switchToZmanimMenu(skipZmanAutoFocus as Boolean?, focusID as String?) as Void {
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
    var locationInfo = $.getLocation() as LocationInfo?;

    // If no location/coordinates are available, switch to initial view
    //* Initial view will handle lack of location and render accordingly. It will do this same check there too.
    if (locationInfo == null) {
        //* This isn't reached upon error necessarily, but rather when location is not available via the chosen source.
        Ui.switchToView(new $.InitialView(), new $.InitialDelegate(), Ui.SLIDE_IMMEDIATE);
        return;
    }

    // Get zmanim
    //* Get user-configurable date from storage. This is (re)set on app launch and should therefore never be null.
    var dateEpoch = Storage.getValue($.getZmanimEpochDateCacheKey()) as Number;
    var dateMoment = new Time.Moment(dateEpoch);
    var coordinates = locationInfo["coordinates"];
    var elevation = locationInfo["elevation"];
    // Get preference of opinion
    var useMGAZmanim = Properties.getValue("useMGAZmanim") as Boolean;
    var zmanim = $.getZmanim(dateMoment, coordinates, elevation, useMGAZmanim) as Array<ZmanTime>;

    // Ensure zmanim don't come back empty (type checked so should be fine, but I don't trust compiler)
    if (zmanim.size() == 0) {
        $.log("[switchToZmanimMenu] Zmanim are empty. Refreshing view for error state...");

        // Switch to main view (is likely already the current one)
        //* The main view will handle the error and render accordingly.
        Ui.switchToView(new $.InitialView(), new $.InitialDelegate(), Ui.SLIDE_IMMEDIATE);
        return;
    }

    // Set title with the date
    // TODO: Set menu title as hebrew date
    var greorianDate = Gregorian.info(dateMoment, Time.FORMAT_MEDIUM);
    var topMenu = new $.CustomWrapTopMenu(Lang.format("$1$ $2$", [greorianDate.month, greorianDate.day]), 80, Graphics.COLOR_BLACK);

    // Build the menu
    for (var i = 0; i < zmanim.size(); i++) {
        var zman = zmanim[i];
        var zmanName = zman["name"] as String;
        var zmanTime = zman["time"] as Time.Moment?;

        topMenu.addItem(createZmanMenuItem(zmanName, zmanTime));
    }

    if (skipZmanAutoFocus != true) {
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
            //* All zmanim have passed for the day. Focus the last zman in list.

            topMenu.setFocus(zmanim.size() - 1);
        }
    } else {
        //* User is likely returning to the menu from a submenu. Focus the last zman in list.

        topMenu.setFocus(zmanim.size() - 1);
    }

    // If a specific zman ID is provided, focus that zman instead
    if (focusID != null) {
        // Focus the zman with the given ID
        var focusIndex = topMenu.findItemById(focusID);
        if (focusIndex != -1) {
            topMenu.setFocus(focusIndex);
        }
    }

    Ui.switchToView(topMenu, new $.ZmanimTopDelegate(new Lang.Method($, :pushBottomZmanimMenu), locationInfo), Ui.SLIDE_IMMEDIATE);
}

//* Create the sub-menu menu of the Wrap custom menu
function pushBottomZmanimMenu(locationInfo as LocationInfo) as Void {
    // TODO: Use rez strings for menu title and items
    var bottomMenu = new $.CustomWrapBottomMenu("Show Zmanim", 80, Graphics.COLOR_WHITE);

    bottomMenu.addItem(new $.CustomWrapItem("Location Info", null, :locationInfo, Graphics.COLOR_BLACK));
    bottomMenu.addItem(new $.CustomWrapItem("Change Date", null, :changeDate, Graphics.COLOR_BLACK));
    bottomMenu.addItem(new $.CustomWrapItem("Settings", null, :settings, Graphics.COLOR_BLACK));

    Ui.pushView(bottomMenu, new $.ZmanimBottomDelegate(locationInfo), Ui.SLIDE_UP);
}

//* Helper function to create a consistent menu item.
function createZmanMenuItem(zmanName as String, zmanTime as Time.Moment?) as CustomWrapItem {
    // Get the friendly name for the zman key
    var friendlyName = $.ZmanimFriendlyNames[zmanName];
    var timeString = null;

    if (friendlyName == null) {
        // Fallback to the key if no friendly name is found for some reason
        friendlyName = zmanName;
    }

    // Convert the zman time to a time string
    if (zmanTime == null) {
        //* Zman is null. For example, at locations in the far north (Longyearbyen, Norway).
        timeString = "N/A";
    } else {
        timeString = $.parseMomentToTimeString(zmanTime);
    }

    // Return the custom menu item
    return new $.CustomWrapItem(friendlyName, timeString, zmanName, Graphics.COLOR_WHITE);
}
