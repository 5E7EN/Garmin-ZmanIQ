import Toybox.Lang;

using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application.Storage as Storage;

//* Fetches and loads zmanim from the Hebcal API into storage
function loadZmanim(latitude as Float, longitude as Float, callback as WebRequestDelegateCallback) as Void {
    // Ensure latitude and longitude are not null
    if (latitude == null || longitude == null) {
        $.log("[loadZmanim] GPS coordinates not provided.");
        return;
    }

    $.log("[loadZmanim] Loading new zmanim...");

    // Get current date string
    var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var dateString = Lang.format("$1$-$2$-$3$", [today.year, today.month.format("%02d"), today.day.format("%02d")]);

    // Build zmanim API URL
    var zmanimUrl = "https://www.hebcal.com/zmanim?cfg=json&sec=1&date=" + dateString + "&latitude=" + latitude.toString() + "&longitude=" + longitude.toString();
    $.log("[loadZmanim] Zmanim URL -> " + zmanimUrl);

    // Get zmanim storage key
    var storageKey = $.getZmanimCacheKey();

    $.makeApiRequest(zmanimUrl, storageKey, callback);
}

//* Clears zmanim in storage
function clearZmanim() as Void {
    Storage.deleteValue($.getZmanimCacheKey());
    Storage.deleteValue($.getZmanimStatusCacheKey());
}

//* Checks if the provided zmanim are stale (are not for today)
function checkIfZmanimStale(data as ZmanimApiResponse) as Boolean {
    var zmanShema = data["times"]["sofZmanShma"];

    // Parse stored zman as Moment object
    var momentZmanShemaUTC = $.parseISODateUTC(zmanShema);
    var gregorianZmanShema = Gregorian.info(momentZmanShemaUTC, Time.FORMAT_SHORT);

    // Ensure that the zmanim cached in local storage are today's zmanim
    var greorianToday = Gregorian.info(new Time.Moment(Time.now().value()), Time.FORMAT_SHORT);

    // Debug
    $.log("[DEBUG] Date today: " + Lang.format("$1$/$2$/$3$", [greorianToday.month, greorianToday.day, greorianToday.year]));
    $.log(
        "[DEBUG] Date of cached zman in our time: " +
            Lang.format("$1$/$2$/$3$ $4$:$5$:$6$", [
                gregorianZmanShema.month,
                gregorianZmanShema.day,
                gregorianZmanShema.year,
                gregorianZmanShema.hour,
                gregorianZmanShema.min,
                gregorianZmanShema.sec
            ])
    );

    // If the stored zmanim dates don't match exactly, we must update them
    // Otherwise, display from local storage instead of making a redundant API request
    if (gregorianZmanShema.month != greorianToday.month || gregorianZmanShema.day != greorianToday.day || gregorianZmanShema.year != greorianToday.year) {
        //* Not same day
        return true;
    } else {
        //* Same day
        return false;
    }
}
