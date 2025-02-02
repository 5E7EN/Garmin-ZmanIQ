import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//! Create the all zmanim menu
function pushMainMenuView() as Void {
    //* If this kind of pushing doesn't work for the main menu, move the logic below to `InitialDelegate.mc` .onMenu() method instead
    // Generate a new Menu
    var menu = new WatchUi.Menu2({ :title => "Test Title" });

    // TODO: Add some kind of line separator here (between title and menu items)

    // Add menu items
    menu.addItem(new WatchUi.MenuItem("PLACEHOLDER", null, :placeholder, null));
    menu.addItem(new WatchUi.MenuItem("All Zmanim", "List all zmanim", :all_zmanim, null));
    menu.addItem(new WatchUi.MenuItem("PLACEHOLDER", null, :placeholder, null));
    WatchUi.pushView(menu, new $.MainMenuDelegate(), WatchUi.SLIDE_UP);
}
