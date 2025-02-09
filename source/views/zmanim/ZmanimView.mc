import Toybox.Graphics;
import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Application.Storage as Storage;

//* Create the all zmanim menu
function switchToZmanimView() as Void {
    var zmanimCacheKey = $.getZmanimCacheKey();
    var remoteZmanData = Storage.getValue(zmanimCacheKey) as ZmanimApiResponse?;

    // Get upcoming zman
    //* Returns null if all zmanim have already passed
    var nextZman = $.getNextUpcomingZman(remoteZmanData["times"]);

    // Generate a new Menu
    //! TODO: Don't use a menu for this. Be more visually elegant.
    var menu = new Ui.Menu2({ :title => Ui.loadResource(Rez.Strings.NextZman) });

    // TODO: Add some kind of line separator here (between title and menu items)

    if (nextZman != null) {
        var friendlyZmanName = $.ZmanimFriendlyNames[nextZman[0]];
        var parsedZmanTime = $.parseTimestampToTimeString(nextZman[1]);
        menu.addItem(new Ui.MenuItem(friendlyZmanName, parsedZmanTime, :nextZman, null));
    } else {
        menu.addItem(new Ui.MenuItem("All zmanim have passed.", null, :nextZman, null));
    }

    // Add "Menu" option
    menu.addItem(new Ui.MenuItem("Menu", null, :menu, null));

    // TODO: Add wrap (with next 3 zmanim)
    // TODO: Add menu footer text explaining how to show all zmanim

    Ui.switchToView(menu, new $.ZmanimDelegate(), Ui.SLIDE_IMMEDIATE);
}
