import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application.Properties as Properties;

function pushLocationSourceView() as Void {
    // Generate a new Menu
    var menu = new Ui.Menu2({ :title => Ui.loadResource(Rez.Strings.LocationSourceTitle) });

    // Add menu items
    // TODO: Only show this option if device supports GPS (Position.hasConfigurationSupport())
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.LocationSourceGPSText), Ui.loadResource(Rez.Strings.LocationSourceGPSSubText), :gps, null));
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.LocationSourceWeatherText), Ui.loadResource(Rez.Strings.LocationSourceWeatherSubText), :weather, null));

    // Determine selected item and focus it
    // TODO: Improve this code. Search for the selected item by value instead of mapping each index
    var locationSource = Properties.getValue("locationSource") as String;

    if (locationSource.equals("GPS")) {
        // Do nothing, focused by default
    } else if (locationSource.equals("Weather")) {
        menu.setFocus(1);
    }

    Ui.pushView(menu, new $.LocationSourceDelegate(), Ui.SLIDE_LEFT);
}
