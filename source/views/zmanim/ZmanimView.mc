import Toybox.Graphics;
import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Application.Storage as Storage;

function switchToZmanimMenu() as Void {
    var zmanimCacheKey = $.getZmanimCacheKey();
    var remoteZmanData = Storage.getValue(zmanimCacheKey) as ZmanimApiResponse?;

    // Get upcoming zman
    //* Returns null if all zmanim have already passed
    var nextZman = $.getNextUpcomingZman(remoteZmanData["times"]);

    // TODO: Add menu title
    var topMenu = new $.WrapTopMenu(80, Graphics.COLOR_BLACK);

    if (nextZman != null) {
        var friendlyZmanName = $.ZmanimFriendlyNames[nextZman[0]];
        var parsedZmanTime = $.parseTimestampToTimeString(nextZman[1]);

        // TODO: Support custom wrap item subtitles
        topMenu.addItem(new $.CustomWrapItem(parsedZmanTime, :item1, Graphics.COLOR_WHITE));
        topMenu.addItem(new $.CustomWrapItem(parsedZmanTime, :item2, Graphics.COLOR_WHITE));
        topMenu.addItem(new $.CustomWrapItem(parsedZmanTime, :item3, Graphics.COLOR_WHITE));

        // TODO: Figure out how to set focus on specific menu item (based on which zman is next)
    }

    Ui.switchToView(topMenu, new $.ZmanimTopDelegate(new Lang.Method($, :pushBottomZmanimMenu)), Ui.SLIDE_LEFT);
}

//* Create the sub-menu menu of the Wrap custom menu
function pushBottomZmanimMenu() as Void {
    var bottomMenu = new $.WrapBottomMenu(80, Graphics.COLOR_WHITE);

    // menu.addItem(new Ui.MenuItem("Menu", null, :menu, null));
    bottomMenu.addItem(new $.CustomWrapItem("Reload Zmanim", :reloadZmanim, Graphics.COLOR_BLACK));
    bottomMenu.addItem(new $.CustomWrapItem("Settings", :settings, Graphics.COLOR_BLACK));

    Ui.pushView(bottomMenu, new $.ZmanimBottomDelegate(), Ui.SLIDE_UP);
}
