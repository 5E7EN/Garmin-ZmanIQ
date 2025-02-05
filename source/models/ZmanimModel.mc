import Toybox.Lang;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Time.Gregorian;

class ZmanimModel {
    //* We don't store zmanim data as class property since it's already being stored in Storage and we want to keep a low memory footprint

    function fetchZmanimCb(latitude as Float, longitude as Float, callback as (Method(responseCode as Number, data as Dictionary or String or Null) as Void)) as Void {
        // Ensure latitude and longitude are not null
        if (latitude == null || longitude == null) {
            $.log("[fetchAndStoreZmanim] GPS coordinates not provided.");
            return;
        }

        $.log("[fetchAndStoreZmanim] Fetching new zmanim...");

        // Get current date
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateString = Lang.format("$1$-$2$-$3$", [today.year, today.month.format("%02d"), today.day.format("%02d")]);

        // Build zmanim API URL
        var zmanimUrl = "https://www.hebcal.com/zmanim?cfg=json&sec=1&date=" + dateString + "&latitude=" + latitude.toString() + "&longitude=" + longitude.toString();
        $.log("[fetchAndStoreZmanim] Zmanim URL -> " + zmanimUrl);

        // Fetch zmanim
        Comm.makeWebRequest(
            zmanimUrl,
            {},
            {
                :method => Comm.HTTP_REQUEST_METHOD_GET
            },
            callback
        );
    }
}
