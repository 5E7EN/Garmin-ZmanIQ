import Toybox.Lang;
import Toybox.WatchUi;

class ZmanimReminderDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(
            new Rez.Menus.MainMenu(),
            new ZmanimReminderMenuDelegate(),
            WatchUi.SLIDE_UP
        );
        return true;
    }
}
