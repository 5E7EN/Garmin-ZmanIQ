import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;

//* Create the all zmanim menu
function pushZmanimMenuView() as Void {
    // Generate a new Menu
    var menu = new Ui.Menu2({ :title => Ui.loadResource(Rez.Strings.ZmanimMenuTitle) });

    // TODO: Add some kind of line separator here (between title and menu items)

    // Add menu items
    // TODO: Use res strings for menu texts
    menu.addItem(new Ui.MenuItem("Reload Zmanim", null, :reloadZmanim, null));
    menu.addItem(new Ui.MenuItem("Settings", null, :settings, null));

    Ui.pushView(menu, new $.ZmanimMenuDelegate(), Ui.SLIDE_UP);
}
