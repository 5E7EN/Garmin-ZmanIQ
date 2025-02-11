import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class ZmanimTopDelegate extends WatchUi.Menu2InputDelegate {
    private var mBottomMenuCallback as (Method() as Void);

    //* Constructor
    public function initialize(pushBottomMenu as (Method() as Void)) {
        Menu2InputDelegate.initialize();

        mBottomMenuCallback = pushBottomMenu;
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
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    //* Handle the user navigating off the end of the menu
    //* @param key The key triggering the menu wrap
    //* @return true if wrap is allowed, false otherwise
    public function onWrap(key as Key) as Boolean {
        if (key == WatchUi.KEY_DOWN) {
            // Push buttom menu
            mBottomMenuCallback.invoke();
        }
        return false;
    }

    //* Handle the footer being selected
    public function onFooter() as Void {
        // Push buttom menu
        mBottomMenuCallback.invoke();
    }
}
