import Toybox.Graphics;
import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;

//* Show zmanim menu. Every time this is invoked, the zmanim will be reloaded.
//* @param focusID The ID of the zman to focus on. If null, auto-focuses the next upcoming zman.
function switchToZmanimMenu(focusID as String?) as Void {
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

    // TODO: Only schedule if device supports attention-grabbing reminders
    $.scheduleNextReminder(zmanim);

    // Set title with the date
    // TODO: Set menu title as hebrew date
    var gregorianDate = Gregorian.info(dateMoment, Time.FORMAT_MEDIUM);
    var title = Lang.format("$1$ $2$", [gregorianDate.month, gregorianDate.day]);

    // Default focus to the first item
    var initialFocusIndex = 0;

    // Find the next upcoming zman to set the initial focus
    var nextZman = $.getNextUpcomingZman(zmanim, null);
    if (nextZman != null) {
        // Find the index of this zman in our array
        for (var i = 0; i < zmanim.size(); i++) {
            if (zmanim[i]["name"].equals(nextZman[0])) {
                $.log("[switchToZmanimMenu] Upcoming zman: " + nextZman[0]);
                initialFocusIndex = i;
                break;
            }
        }
    } else {
        //* All zmanim have passed for the day. Focus the last zman in list.

        initialFocusIndex = zmanim.size() - 1;
    }

    // If a specific zman ID is provided, override the focus
    if (focusID != null) {
        for (var i = 0; i < zmanim.size(); i++) {
            if (zmanim[i]["name"].equals(focusID)) {
                initialFocusIndex = i;
                break;
            }
        }
    }

    // Create the zmanim view and delegate
    var view = new $.ZmanimListView(title, zmanim, initialFocusIndex);
    var delegate = new $.ZmanimListDelegate(view, locationInfo);

    // Switch to the new view
    Ui.switchToView(view, delegate, Ui.SLIDE_IMMEDIATE);
}
