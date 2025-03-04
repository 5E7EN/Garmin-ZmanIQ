import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class ZmanimTopDelegate extends WatchUi.Menu2InputDelegate {
    private var mBottomMenuCallback as (Method(locationInfo as LocationInfo) as Void);
    public var mLocationInfo as LocationInfo;

    //* Constructor
    public function initialize(pushBottomMenu as (Method(locationInfo as LocationInfo) as Void), locationInfo as LocationInfo) {
        Menu2InputDelegate.initialize();

        mBottomMenuCallback = pushBottomMenu;
        mLocationInfo = locationInfo;
    }

    //* Handle an item being selected
    //* @param item The selected menu item
    public function onSelect(item as MenuItem) as Void {
        var id = item.getId();

        //* Specific zman was selected
        // TODO: Open zman menu (Set Reminder, etc.)
    }

    //* Handle the back key being pressed
    public function onBack() as Void {
        //* If this is called, the app will just quit. No need for the line below really...
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    //* Handle the user navigating off the end of the menu
    //* @param key The key triggering the menu wrap
    //* @return true if wrap is allowed, false otherwise
    public function onWrap(key as Key) as Boolean {
        // TODO: On wrap up, go to bottom of zmanim list. Pass topMenu from View to this delegate and invoke `setFocus` (maybe not work though).
        if (key == WatchUi.KEY_DOWN) {
            // Push buttom menu
            mBottomMenuCallback.invoke(mLocationInfo);
        }
        return false;
    }

    //* Handle the footer being selected
    public function onFooter() as Void {
        // Push buttom menu
        mBottomMenuCallback.invoke(mLocationInfo);
    }
}
