import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application.Properties as Properties;

function pushLocationSourceView() as Void {
    // Generate a new Menu
    var menu = new Ui.Menu2({ :title => Ui.loadResource(Rez.Strings.LocationSourceTitle) });

    // Add menu items
    menu.addItem(new Ui.MenuItem("Auto", null, :auto, null));
    menu.addItem(new Ui.MenuItem("GPS", Ui.loadResource(Rez.Strings.LocationSourceGPSSubText), :gps, null));
    menu.addItem(new Ui.MenuItem("Weather", Ui.loadResource(Rez.Strings.LocationSourceWeatherSubText), :weather, null));
    menu.addItem(new Ui.MenuItem("Last Activity", Ui.loadResource(Rez.Strings.LocationSourceLastActivitySubText), :lastActivity, null));
    // TODO: Add "Manual" option to enter latitude and longitude coordinates

    // Determine selected item and focus it
    // TODO: Improve this code. Search for the selected item by value instead of mapping each index
    var locationSource = Properties.getValue("locationSource") as String;

    if (locationSource.equals("Auto")) {
    } else if (locationSource.equals("GPS")) {
        menu.setFocus(1);
    } else if (locationSource.equals("Weather")) {
        menu.setFocus(2);
    } else if (locationSource.equals("Activity")) {
        menu.setFocus(3);
    }

    Ui.pushView(menu, new $.LocationSourceDelegate(), Ui.SLIDE_UP);
}
