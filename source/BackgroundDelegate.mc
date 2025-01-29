import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Background as Bg;
using Toybox.Time.Gregorian;
using Toybox.Application.Storage as Storage;

(:background)
class ZmanimReminderBackgroundDelegate extends Sys.ServiceDelegate {
    (:background_method)
    function initialize() {
        Sys.ServiceDelegate.initialize();
    }

    (:background_method)
    public function onTemporalEvent() as Void {
        var app = App.getApp();

        // Calculate time until zman
        var timeNowEpoch = Time.now().value();
        var rawSofZmanKS = Storage.getValue("SofZmanShma");
        var sofZmanKriasShmaMoment = app.parseISODate(rawSofZmanKS);
        var sofZmanKriasShmaEpoch = sofZmanKriasShmaMoment.value();
        var timeDifferenceInMinutes = ~~(
            (sofZmanKriasShmaEpoch - timeNowEpoch) /
            60
        );

        // Alert user of impending zman, assuming it hasn't yet passed
        // An example of already passing is, for instance, if the user opens the app (queueing the temporal reminder), waits for the zman to pass, then closes the app.
        if (timeDifferenceInMinutes > 0) {
            var gregorianZman = Gregorian.info(
                sofZmanKriasShmaMoment,
                Time.FORMAT_SHORT
            );
            var sofZmanKriasShmaTime =
                gregorianZman.hour +
                ":" +
                gregorianZman.min.format("%02d") +
                ":" +
                gregorianZman.sec.format("%02d");

            Sys.println("Triggering zman notification!");
            Bg.requestApplicationWake(
                "Zman is in " +
                    timeDifferenceInMinutes +
                    " minutes! " +
                    "(" +
                    sofZmanKriasShmaTime +
                    ")"
            );
            Bg.exit(null);
        } else {
            Sys.println(
                "Zman has already passed. Aborted reminder notification!"
            );
            Bg.exit(null);
        }
    }
}
