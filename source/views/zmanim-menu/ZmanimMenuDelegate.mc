import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.Application.Storage as Storage;

//* This is the menu input delegate/handler for the main menu of the application
class ZmanimMenuDelegate extends WatchUi.Menu2InputDelegate {
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
        if (id == :reloadZmanim) {
            reloadZmanimOption();
        } else if (id == :settings) {
            // Render main menu
            $.pushMainMenuView();
        }
    }

    public function reloadZmanimOption() {
        $.log("[reloadZmanimOption] Reload triggered via menu");

        // If the zmanim request is already in progress, do nothing
        var zmanimStatusCacheKey = $.getZmanimStatusCacheKey();
        var zmanimRequestStatus = Storage.getValue(zmanimStatusCacheKey);
        if (zmanimRequestStatus != null && zmanimRequestStatus.equals("pending")) {
            $.log("Zmanim request already in progress...");
            return;
        }

        // (Re)fresh zmanim :)
        //* This will set the zmanim request status to "pending"
        $.refreshZmanim();

        // Switch back to intial view for reloading
        WatchUi.switchToView(new $.InitialView(), new $.InitialDelegate(), WatchUi.SLIDE_DOWN);

        // Refresh the UI for the pending state
        //* The main view will handle the new request state and render accordingly
        WatchUi.requestUpdate();
    }

    //* Handle the back key being pressed
    public function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}
