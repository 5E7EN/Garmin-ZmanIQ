import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//* This is the menu input delegate/handler for the main menu of the application
class MainMenuDelegate extends WatchUi.Menu2InputDelegate {
    //* Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    //* Handle an item being selected
    //* @param item The selected menu item
    public function onSelect(item as MenuItem) as Void {
        // Get the ID of the selected item
        var id = item.getId();

        // React based on the selected item ID
        if (id == :locationSource) {
            $.pushLocationSourceView();
        } else if (id == :about) {
            $.pushAboutView();
        }
        // } else if (id == :reminders) {
        //     $.pushRemindersMenuView();
        // }
    }

    //* Handle the back key being pressed
    public function onBack() as Void {
        // Set pending retry to true
        //* This will force the app to reload zmanim when the initial view is rendered.
        //* This is in case a setting was changed that previously caused an error to occur.
        $.setPendingRetry(true);

        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
