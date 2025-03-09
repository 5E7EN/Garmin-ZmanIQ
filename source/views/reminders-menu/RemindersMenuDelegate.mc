import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.Application.Properties as Properties;

class RemindersMenuDelegate extends WatchUi.Menu2InputDelegate {
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
        if (id == :timeBefore) {
            // Render reminder timechange picker
            $.pushChangeTimeBeforePicker();
        }
    }

    //* Handle the back key being pressed
    public function onBack() as Void {
        //* We can just pop this view without having to set "pending refresh" flag, since
        //* this submenu is accessed via the main menu and the main menu will do that for us
        //* when the user exits from it.

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}
