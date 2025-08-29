using Toybox.WatchUi as Ui;

//* Shows the menu with info and actions for the zmanim list.
function pushZmanimListMenuView(locationInfo as LocationInfo) as Void {
    // TODO: Use rez strings for menu title and items
    var menu = new Ui.Menu2({ :title => "Zmanim Options" });

    menu.addItem(new Ui.MenuItem("Location Info", null, :locationInfo, null));
    menu.addItem(new Ui.MenuItem("Change Date", null, :changeDate, null));
    menu.addItem(new Ui.MenuItem("App Settings", null, :settings, null));

    Ui.pushView(menu, new $.ZmanimListMenuDelegate(locationInfo), Ui.SLIDE_LEFT);
}
