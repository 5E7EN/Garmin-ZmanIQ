import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;

//* Create the all zmanim menu
function pushMainMenuView() as Void {
    // Generate a new Menu
    var menu = new Ui.Menu2({ :title => Ui.loadResource(Rez.Strings.MainMenuTitle) });

    // TODO: Add some kind of line separator here (between title and menu items)

    // Add menu items
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.MainMenuLocationSourceText), Ui.loadResource(Rez.Strings.MainMenuLocationSourceSubText), :locationSource, null));
    // TODO: Implement Reminders logic
    // menu.addItem(new Ui.MenuItem("Reminders", "Manage active reminders", :reminders, null));
    menu.addItem(new Ui.MenuItem("About", null, :about, null));

    Ui.pushView(menu, new $.MainMenuDelegate(), Ui.SLIDE_UP);
}
