import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Application.Storage as Storage;

class ZmanimListMenuDelegate extends WatchUi.Menu2InputDelegate {
    public var mLocationInfo as LocationInfo;

    public function initialize(locationInfo as LocationInfo) {
        Menu2InputDelegate.initialize();

        mLocationInfo = locationInfo;
    }

    //* Handle an item being selected
    //* @param item The selected menu item
    public function onSelect(item as MenuItem) as Void {
        var id = item.getId();

        // React based on the selected item ID
        if (id == :locationInfo) {
            // Render location info menu
            $.pushLocationInfoMenuView(mLocationInfo);
        } else if (id == :changeDate) {
            // Render date change picker
            $.pushChangeDatePicker();
        } else if (id == :settings) {
            // Render main menu
            $.pushMainMenuView();
        }
    }

    //* Handle the back key being pressed
    public function onBack() as Void {
        goBack();
    }

    //* Goes back to zmanim list, reloading zmanim if a refresh is pending.
    private function goBack() {
        var isPendingRefresh = $.getPendingRefresh();
        if (isPendingRefresh == true) {
            $.log("[goBack] Forced refresh is pending. Reloading zmanim...");
            // Clear pending refresh
            $.setPendingRefresh(false);

            // Pop current view
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            // Reload zmanim
            $.switchToZmanimMenu(null);
        } else {
            // Pop current view
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
        }
    }
}
