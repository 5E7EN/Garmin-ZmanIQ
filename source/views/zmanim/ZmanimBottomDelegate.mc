import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.Application.Storage as Storage;

class ZmanimBottomDelegate extends WatchUi.Menu2InputDelegate {
    //* Constructor
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    //* Handle an item being selected
    //* @param item The selected menu item
    public function onSelect(item as MenuItem) as Void {
        var id = item.getId();

        // React based on the selected item ID
        if (id == :settings) {
            // Render main menu
            $.pushMainMenuView();
        } else if (id == :locationInfo) {
            // Render location info menu
            $.pushLocationInfoMenuView();
        }
    }

    //* Handle the back key being pressed
    public function onBack() as Void {
        goBack();
    }

    //* Handle the user navigating off the end of the menu
    //* @param key The key triggering the menu wrap
    //* @return true if wrap is allowed, false otherwise
    public function onWrap(key as Key) as Boolean {
        if (key == WatchUi.KEY_UP) {
            goBack();
        }
        return false;
    }

    //* Handle the title being selected
    //* Should be the same as onWrap with KEY_UP condition
    public function onTitle() as Void {
        goBack();
    }

    //* Goes back to top zmanim wrap menu
    private function goBack() {
        var isPendingRefresh = $.getPendingRefresh();
        if (isPendingRefresh == true) {
            $.log("[goBack] Forced refresh is pending. Reloading zmanim...");
            // Clear pending refresh
            $.setPendingRefresh(false);

            // Pop current view
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            // Reload zmanim
            $.switchToZmanimMenu(true);
        } else {
            // Pop current view
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }
}
