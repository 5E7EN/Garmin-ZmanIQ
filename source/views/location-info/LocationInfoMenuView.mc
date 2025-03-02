import Toybox.Graphics;
import Toybox.Lang;

using Toybox.System as System;
using Toybox.WatchUi as Ui;
using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;

function pushLocationInfoMenuView(locationInfo as LocationInfo) as Void {
    // Generate a new Menu
    var menu = new Ui.Menu2({ :title => Ui.loadResource(Rez.Strings.LocationInfoMenuTitle) });

    // Determine displayed elevation value
    var elevationValue = locationInfo["elevation"].equals(0) ? "Unavailable" : locationInfo["elevation"].toString() + " meters";
    if (locationInfo["useElevation"] == false) {
        elevationValue = "Disabled";
    }

    // Determine last updated value
    var lastUpdatedValue = locationInfo["lastUpdated"] != null ? $.formatTimeAgo(locationInfo["lastUpdated"]) : "Unknown";

    // Add info items
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.LocationInfoMenuSource), locationInfo["source"].toString(), null, null));
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.LocationInfoMenuCoords), locationInfo["coordinates"].toString(), null, null));
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.LocationInfoMenuElevation), elevationValue, null, null));

    // If using GPS, add related info
    if (locationInfo["source"].equals("GPS")) {
        menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.LocationInfoMenuGpsQuality), locationInfo["gpsQuality"], null, null));
    }

    // Add more info item(s)
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.LocationInfoMenuLastUpdated), lastUpdatedValue, null, null));

    // Add functional items
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.LocationInfoMenuReloadLocation), null, :reloadLocation, null));

    //* Delegate might need to be `new $.AboutDelegate()` to support back functionality
    Ui.pushView(menu, new $.LocationInfoMenuDelegate(), Ui.SLIDE_LEFT);
}
