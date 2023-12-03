import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Background as Bg;

(:background)
class ZmanimReminderBackgroundDelegate extends Sys.ServiceDelegate {
    (:background_method)
    function initialize() {
        Sys.ServiceDelegate.initialize();
    }

    (:background_method)
    public function onTemporalEvent() as Void {
        var app = App.getApp();
        var timeUntilZman = app.getProperty("BgMinutesBeforeZmanToRemind");

        Sys.println("Triggering zman notification!");
        Bg.requestApplicationWake("Zman is in " + timeUntilZman + " minutes!");
        Bg.exit(null);
    }
}
