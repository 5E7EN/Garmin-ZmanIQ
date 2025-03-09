import Toybox.Graphics;
import Toybox.Lang;

using Toybox.WatchUi as Ui;

function pushRemindersMenuView() as Void {
    // Generate a new Menu
    var menu = new Ui.Menu2({ :title => Ui.loadResource(Rez.Strings.RemindersMenuTitle) });

    // Add menu items
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.RemindersMenuTimeBeforeText), Ui.loadResource(Rez.Strings.RemindersMenuTimeBeforeSubText), :timeBefore, null));

    Ui.pushView(menu, new $.RemindersMenuDelegate(), Ui.SLIDE_UP);
}
