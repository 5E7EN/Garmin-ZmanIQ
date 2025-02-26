import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

function pushAboutView() as Void {
    // Generate a new Menu
    var menu = new Ui.Menu2({ :title => Ui.loadResource(Rez.Strings.AboutTitle) });

    // Add menu items
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.AboutAuthorText), "5E7EN", null, null));
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.AboutVersionText), Ui.loadResource(Rez.Strings.AppVersion), null, null));

    // TODO: Can we just pass some generic delegate that does nothing?
    Ui.pushView(menu, new $.AboutDelegate(), Ui.SLIDE_IMMEDIATE);
}
