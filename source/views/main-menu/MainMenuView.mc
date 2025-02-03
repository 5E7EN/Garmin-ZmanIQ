import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//* Create the all zmanim menu
function pushMainMenuView() as Void {
    // Generate a new Menu
    var menu = new WatchUi.Menu2({ :title => "Main Menu" });

    // TODO: Add some kind of line separator here (between title and menu items)

    // Add menu items
    menu.addItem(new WatchUi.MenuItem("Location Source", "Set location source", :location_source, null));
    // TODO: Implement Reminders logic
    // menu.addItem(new WatchUi.MenuItem("Reminders", "Manage active reminders", :reminders, null));
    // TODO: Implement About view
    menu.addItem(new WatchUi.MenuItem("About", null, :about, null));

    WatchUi.pushView(menu, new $.MainMenuDelegate(), WatchUi.SLIDE_UP);
}
