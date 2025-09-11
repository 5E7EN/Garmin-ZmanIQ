using Toybox.WatchUi as Ui;

//* Shows the menu with info and actions for the zmanim list.
function pushZmanimListMenuView(locationInfo as LocationInfo) as Void {
    // TODO: Use rez strings for menu title and items
    var menu = new Ui.Menu2({ :title => Ui.loadResource($.Rez.Strings.ZmanimMenuTitle) });

    menu.addItem(new Ui.MenuItem(Ui.loadResource($.Rez.Strings.ZmanimMenuLocationInfoText), null, :locationInfo, null));
    menu.addItem(new Ui.MenuItem(Ui.loadResource($.Rez.Strings.ZmanimMenuCompassText), null, :compass, null));
    menu.addItem(new Ui.MenuItem(Ui.loadResource($.Rez.Strings.ZmanimMenuChangeDateText), null, :changeDate, null));
    menu.addItem(new Ui.MenuItem(Ui.loadResource($.Rez.Strings.ZmanimMenuSettingsText), null, :settings, null));

    Ui.pushView(menu, new $.ZmanimListMenuDelegate(locationInfo), Ui.SLIDE_LEFT);
}
