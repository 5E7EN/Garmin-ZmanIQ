import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application.Storage as Storage;

function getZmanim(date as Time.Moment, coordinates as Array, elevation as Number) as Array<ZmanTime> {
    // Ensure date, coordinates, and elevation are not null
    if (date == null || coordinates == null || elevation == null) {
        $.log("[getZmanim] Invalid parameters provided.");
        return [];
    }

    // Initialize zmanim array
    var zmanim = new Array<ZmanTime>[0];

    try {
        // Geolocation
        var latitude = coordinates[0];
        var longitude = coordinates[1];
        var geoLocation = new $.JewishCalendarModule.GeoLocation("Zmanim", latitude, longitude, elevation);

        // Create a new zmanim calendar
        var zmanimCalendar = new $.JewishCalendarModule.ZmanimCalendars.ZmanimCalendar(geoLocation, date);

        // Verbose logging
        var parsedDate = Gregorian.info(date, Time.FORMAT_SHORT);
        $.log(Lang.format("[getZmanim] Calculated zmanim for date: $1$/$2$/$3$", [parsedDate.month.format("%02d"), parsedDate.day.format("%02d"), parsedDate.year]));

        // Build zmanim
        // TODO: Adjust based on future "Gra-or-MGA" preference. Currently using Gra only.
        zmanim.add({ "name" => $.ZmanNames["ALOS"], "time" => zmanimCalendar.getAlotHashachar() });
        zmanim.add({ "name" => $.ZmanNames["SUNRISE"], "time" => zmanimCalendar.getSunrise() });
        zmanim.add({ "name" => $.ZmanNames["SOF_ZMAN_SHEMA"], "time" => zmanimCalendar.getSofZmanShmaGRA() });
        zmanim.add({ "name" => $.ZmanNames["SOF_ZMAN_TEFILLA"], "time" => zmanimCalendar.getSofZmanTfilaGRA() });
        zmanim.add({ "name" => $.ZmanNames["CHATZOS"], "time" => zmanimCalendar.getChatzot() });
        zmanim.add({ "name" => $.ZmanNames["MINCHA_GEDOLA"], "time" => zmanimCalendar.getMinchaGedola() });
        zmanim.add({ "name" => $.ZmanNames["SUNSET"], "time" => zmanimCalendar.getSunset() });
        zmanim.add({ "name" => $.ZmanNames["TZEIS"], "time" => zmanimCalendar.getTzait() });
    } catch (error instanceof Lang.Exception) {
        // Log error
        $.log("[getZmanim] Error occurred while calculating zmanim: " + error);

        // Set error message to storage
        Storage.setValue($.getZmanimErrorMessageCacheKey(), WatchUi.loadResource($.Rez.Strings.FailedToCalculate));
    } finally {
        return zmanim;
    }
}

//* Determines the next upcoming zman from a given list of zmanim times
//* Returns null if all zmanim have already passed
function getNextUpcomingZman(zmanim as Array<ZmanTime>) as Array? {
    var currentTime = Time.now().value();
    var closestZmanName = null;
    var closestZmanTime = null;
    //* Initialize to 123 to prevent compiler complaints. This value will be overwritten.
    var minDifference = 1337;

    // Find the next upcoming zman
    for (var i = 0; i < zmanim.size(); i++) {
        var zman = zmanim[i];
        var zmanName = zman["name"] as String;
        var zmanMoment = zman["time"] as Time.Moment;

        // Ensure current zman index is after current time (i.e. in the future)
        if (zmanMoment.value() > currentTime) {
            // Ensure zman time at current index is earlier than existing "earliest" zman
            if (minDifference.equals(1337) || zmanMoment.value() < minDifference) {
                closestZmanName = zmanName;
                closestZmanTime = zmanMoment;
                minDifference = zmanMoment.value();
            }
        }
    }

    // If no zman was after current time, return empty handed
    if (closestZmanName == null || closestZmanTime == null) {
        return null;
    }

    // Return results
    return [closestZmanName, closestZmanTime];
}
