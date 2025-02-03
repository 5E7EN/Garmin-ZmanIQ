import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

function pushAboutView() as Void {
    // Generate a new Menu
    var menu = new WatchUi.Menu2({ :title => "About" });

    // Add menu items
    menu.addItem(new WatchUi.MenuItem(Lang.format("$1$: 5E7EN", [WatchUi.loadResource(Rez.Strings.AboutAuthorText)]), null, :about_author, null));
    menu.addItem(
        new WatchUi.MenuItem(
            Lang.format("$1$: $2$", [WatchUi.loadResource(Rez.Strings.AboutVersionText), WatchUi.loadResource(Rez.Strings.AppVersion)]),
            null,
            :about_version,
            null
        )
    );

    // TODO: Can we just pass some generic delegate that does nothing?
    WatchUi.pushView(menu, new $.AboutDelegate(), WatchUi.SLIDE_IMMEDIATE);
}
