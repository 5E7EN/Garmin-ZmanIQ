import Toybox.Graphics;
import Toybox.Lang;

using Toybox.System as System;
using Toybox.WatchUi as Ui;
using Toybox.Application.Storage as Storage;

function pushGpsInfoMenuView() as Void {
    // Get GPS info
    var gpsInfo = Storage.getValue($.getGpsInfoCacheKey()) as GPSInfo;

    // Generate a new Menu
    var menu = new Ui.Menu2({ :title => Ui.loadResource(Rez.Strings.GpsInfoMenuTitle) });

    // Add info items
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.GpsInfoMenuCoords), gpsInfo["coordinates"].toString(), null, null));
    menu.addItem(
        new Ui.MenuItem(
            Ui.loadResource(Rez.Strings.GpsInfoMenuElevation),
            // TODO: If "Use Elevation" pref is disabled, show "Unused" as the elevation
            gpsInfo["elevation"].equals(-1) ? "Unavailable" : gpsInfo["elevation"].toString() + " meters",
            null,
            null
        )
    );
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.GpsInfoMenuQuality), gpsInfo["quality"].toString(), null, null));
    // Add functional items
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.GpsInfoMenuReloadLocation), null, :reloadGps, null));

    //* Delegate might need to be `new $.AboutDelegate()` to support back functionality
    Ui.pushView(menu, new $.GpsInfoMenuDelegate(), Ui.SLIDE_IMMEDIATE);
}
