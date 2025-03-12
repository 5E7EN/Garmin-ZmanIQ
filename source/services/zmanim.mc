import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Application.Storage as Storage;

function getZmanim(date as Time.Moment, coordinates as Array, elevation as Number, useMGAZmanim as Boolean?) as Array<ZmanTime> {
    // Clear any existing error message
    // Storage.deleteValue($.getZmanimErrorMessageCacheKey());

    // Ensure date, coordinates, and elevation are not null
    if (date == null || coordinates == null || elevation == null) {
        $.log("[getZmanim] Invalid parameters provided.");
        Storage.setValue($.getZmanimErrorMessageCacheKey(), WatchUi.loadResource($.Rez.Strings.InternalError));
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
        zmanim.add({ "name" => $.ZmanMeta.ZmanNames["ALOS"], "time" => zmanimCalendar.getAlotHashachar() });
        zmanim.add({ "name" => $.ZmanMeta.ZmanNames["SUNRISE"], "time" => zmanimCalendar.getSunrise() });
        // Use preferred opinion for certain times
        if (useMGAZmanim == true) {
            zmanim.add({ "name" => $.ZmanMeta.ZmanNames["SOF_ZMAN_SHEMA"], "time" => zmanimCalendar.getSofZmanShmaMGA() });
            zmanim.add({ "name" => $.ZmanMeta.ZmanNames["SOF_ZMAN_TEFILLA"], "time" => zmanimCalendar.getSofZmanTfilaMGA() });
        } else {
            zmanim.add({ "name" => $.ZmanMeta.ZmanNames["SOF_ZMAN_SHEMA"], "time" => zmanimCalendar.getSofZmanShmaGRA() });
            zmanim.add({ "name" => $.ZmanMeta.ZmanNames["SOF_ZMAN_TEFILLA"], "time" => zmanimCalendar.getSofZmanTfilaGRA() });
        }
        zmanim.add({ "name" => $.ZmanMeta.ZmanNames["CHATZOS"], "time" => zmanimCalendar.getChatzot() });
        zmanim.add({ "name" => $.ZmanMeta.ZmanNames["MINCHA_GEDOLA"], "time" => zmanimCalendar.getMinchaGedola() });
        zmanim.add({ "name" => $.ZmanMeta.ZmanNames["MINCHA_KETANA"], "time" => zmanimCalendar.getMinchaKetana() });
        zmanim.add({ "name" => $.ZmanMeta.ZmanNames["PLAG_HAMINCHA"], "time" => zmanimCalendar.getPlagHamincha() });
        zmanim.add({ "name" => $.ZmanMeta.ZmanNames["SUNSET"], "time" => zmanimCalendar.getSunset() });
        zmanim.add({ "name" => $.ZmanMeta.ZmanNames["TZEIS"], "time" => zmanimCalendar.getTzait() });
        zmanim.add({ "name" => $.ZmanMeta.ZmanNames["TZEIS_72"], "time" => zmanimCalendar.getTzait72() });
    } catch (error) {
        // Log error
        $.log("[getZmanim] Error occurred while calculating zmanim: " + error);

        // Set error message to storage
        Storage.setValue($.getZmanimErrorMessageCacheKey(), WatchUi.loadResource($.Rez.Strings.InternalError));
    } finally {
        return zmanim;
    }
}

//* Determines the next upcoming zman from a given list of zmanim times
//* Returns null if all zmanim have already passed
//* @param zmanim - Array of zmanim times
//* @param afterTime - Optional time Moment to check against (defaults to current time)
function getNextUpcomingZman(zmanim as Array<ZmanTime>, afterTime as Time.Moment?) as Array? {
    var currentTime = afterTime == null ? Time.now().value() : afterTime.value();
    var closestZmanName = null;
    var closestZmanTime = null;
    //* Initialize to 123 to prevent compiler complaints. This value will be overwritten.
    var minDifference = 1337;

    // Find the next upcoming zman
    for (var i = 0; i < zmanim.size(); i++) {
        var zman = zmanim[i];
        var zmanName = zman["name"] as String;
        var zmanMoment = zman["time"] as Time.Moment?;

        // Ensure current zman index is after current time (i.e. in the future)
        if (zmanMoment != null && zmanMoment.value() > currentTime) {
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

//* Determines the next reminder-enabled zman from a given list of zmanim times
//* Returns null if, 1) all zmanim have already passed, or 2) the next zman is not occuring today, or 3) no zmanim have reminders enabled.
//* @param zmanim - Array of zmanim times
//* @param afterTime - Optional time Moment to check against
function getNextRemindingZmanToday(zmanim as Array<ZmanTime>, afterTime as Time.Moment?) as Array? {
    var nextZman = getNextUpcomingZman(zmanim, afterTime);

    // Ensure next zman is not null
    //* This will occur if all zmanim have passed for the day (min time) or no zmanim have reminders enabled (max time).
    if (nextZman == null) {
        return null;
    }

    // Ensure next zman is occuring today
    // Otherwise, quit early
    var nextZmanTime = nextZman[1] as Time.Moment;
    var nextZmanGregorian = Gregorian.info(nextZmanTime, Time.FORMAT_SHORT);
    var todayGregorian = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    if (nextZmanGregorian.year != todayGregorian.year || nextZmanGregorian.month != todayGregorian.month || nextZmanGregorian.day != todayGregorian.day) {
        return null;
    }

    // Check if zman key exists in reminder-enabled zmanim
    var zmanKey = nextZman[0];
    var reminderEnabledZmanim = Storage.getValue($.getReminderEnabledZmanimCacheKey()) as Array<String>;
    var isReminderEnabled = reminderEnabledZmanim.indexOf(zmanKey) != -1;

    if (isReminderEnabled == true) {
        // Return the next zman
        return nextZman;
    } else {
        // Recursively find the next zman that is reminder-enabled
        // TODO: This is inefficient.
        // TODO cont.: Instead, modify `getNextUpcomingZman()` to return ALL upcoming zmanim, and shift using an offset [until end of array].
        // TODO cont.: See if that significantly affects memory usage since we would have to switch to an array of dictionaries - which are memory hungry(er).
        return $.getNextRemindingZmanToday(zmanim, nextZmanTime);
    }
}
