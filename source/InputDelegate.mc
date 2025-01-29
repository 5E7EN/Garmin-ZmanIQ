import Toybox.Lang;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi;
using Toybox.Application.Storage as Storage;

class ZmanimReminderInputDelegate extends WatchUi.InputDelegate {
    function initialize() {
        InputDelegate.initialize();
    }

    function onKey(evt) {
        var app = App.getApp();

        // DOWN key handler - Manually reloads zmanim
        if (evt.getKey() == WatchUi.KEY_DOWN) {
            // Trigger manual reload of zmanim
            Sys.println(
                "[onKey | DOWN] User triggered reload of zmanim, refreshing..."
            );

            Storage.deleteValue("RemoteZmanData");
            Storage.deleteValue("ZmanimRequestStatus");

            // Refresh UI to update zmanim
            WatchUi.requestUpdate();

            return true;
        }

        return false;
    }
}
