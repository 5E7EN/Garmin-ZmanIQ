import Toybox.Graphics;
import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Application.Storage as Storage;

// TODO: Adjust key based on future "Gra-or-MGA" preference using ternary
var displayedZmanimKeys = ["alotHaShachar", "sunrise", "sofZmanShma", "sofZmanTfilla", "chatzot", "minchaGedola", "sunset", "tzeit50min"];

function switchToZmanimMenu() as Void {
    // TODO: If already on the zmanim menu, do nothing (prevent double-rendering)
    // TODO cont.: cannot use Ui.getCurrentView() because API level isn't supported on many watches

    var zmanimCacheKey = $.getZmanimCacheKey();
    var remoteZmanData = Storage.getValue(zmanimCacheKey) as ZmanimApiResponse?;
    var zmanim = remoteZmanData["times"] as ZmanimTimes;

    // TODO: Set menu title as current hebrew date
    var topMenu = new $.CustomWrapTopMenu("Zmanim", 80, Graphics.COLOR_BLACK);

    // Build the menu
    for (var i = 0; i < displayedZmanimKeys.size(); i++) {
        var zmanKey = displayedZmanimKeys[i];

        if (zmanim.hasKey(zmanKey)) {
            topMenu.addItem(createZmanMenuItem(zmanKey, zmanim, Graphics.COLOR_WHITE));
        } else {
            $.log("[switchToZmanimMenu] Zman key not found: " + zmanKey);
        }
    }

    // Create a new dictionary containing only the displayed zmanim
    var filteredZmanim = ({}) as Dictionary<String, String>;
    for (var i = 0; i < displayedZmanimKeys.size(); i++) {
        var key = displayedZmanimKeys[i];

        if (zmanim.hasKey(key)) {
            filteredZmanim.put(key, zmanim[key]);
        }
    }

    // Set focus to the next upcoming zman, passing filtered zmanim
    var nextZman = $.getNextUpcomingZman(filteredZmanim);
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
        topMenu.setFocus(displayedZmanimKeys.size() - 1);
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
function createZmanMenuItem(zmanKey as String, zmanim as ZmanimTimes, color as ColorType) as CustomWrapItem {
    // Get the friendly name for the zman key
    var friendlyName = $.ZmanimFriendlyNames[zmanKey];

    if (friendlyName == null) {
        // Fallback to the key if no friendly name is found for some reason
        friendlyName = zmanKey;
    }

    var timeString = $.parseTimestampToTimeString(zmanim[zmanKey]);

    return new $.CustomWrapItem(friendlyName, timeString, zmanKey, color);
}
