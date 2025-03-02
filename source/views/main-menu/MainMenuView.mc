import Toybox.Graphics;
import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Application.Properties as Properties;

//* Create the all zmanim menu
function pushMainMenuView() as Void {
    // Generate a new Menu
    var menu = new Ui.Menu2({ :title => Ui.loadResource(Rez.Strings.MainMenuTitle) });

    // TODO: Add some kind of line separator here (between title and menu items)

    // Get current elevation preference
    var useElevation = Properties.getValue("useElevation") as Boolean;
    var useMGAZmanim = Properties.getValue("useMGAZmanim") as Boolean;

    // Add menu items
    menu.addItem(new Ui.MenuItem(Ui.loadResource(Rez.Strings.MainMenuLocationSourceText), Ui.loadResource(Rez.Strings.MainMenuLocationSourceSubText), :locationSource, null));
    menu.addItem(
        new Ui.ToggleMenuItem(Ui.loadResource(Rez.Strings.MainMenuUseElevationText), Ui.loadResource(Rez.Strings.MainMenuUseElevationSubText), :useElevation, useElevation, {
            :alignment => Ui.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT
        })
    );
    menu.addItem(
        new Ui.ToggleMenuItem(
            Ui.loadResource(Rez.Strings.MainMenuUseMGAZmanimText),
            { :disabled => "Selected: GR\"A", :enabled => "Selected: MG\"A" },
            :useMGAZmanim,
            useMGAZmanim,
            { :alignment => Ui.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT }
        )
    );
    // TODO: Implement Reminders logic
    // menu.addItem(new Ui.MenuItem("Reminders", "Manage active reminders", :reminders, null));
    menu.addItem(new Ui.MenuItem("About", null, :about, null));

    Ui.pushView(menu, new $.MainMenuDelegate(), Ui.SLIDE_LEFT);
}
