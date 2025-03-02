import Toybox.Weather;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Math;
import Toybox.Time;

using Toybox.Application.Properties as Properties;
using Toybox.Application.Storage as Storage;
using Toybox.System as System;

function getLocation() as LocationInfo? {
    var source = Properties.getValue("locationSource");

    var coordinates = null;
    var elevation = 0;
    var gpsQuality = null;
    var finalSource = null;
    var lastUpdated = null;

    // Get available locations (except GPS, for now)
    var weather = Weather.getCurrentConditions();
    var lastActivity = Activity.getActivityInfo();

    // Determine current coordinates based on the selected location source
    switch (source) {
        // TODO: Remove "Auto" as an option to avoid confusion.
        // TODO cont.: then `finalSource` can just be the same as `source`
        case "Auto":
            // First, try to get location based on weather location
            if (weather != null && weather.observationLocationPosition != null) {
                coordinates = weather.observationLocationPosition.toDegrees();
                finalSource = "Weather";
                lastUpdated = weather.observationTime != null ? weather.observationTime.value() : null;
            }
            // Second, try to get location based on last activity
            else if (lastActivity != null && lastActivity.currentLocation != null) {
                coordinates = lastActivity.currentLocation.toDegrees();
                finalSource = "Last Activity";
                lastUpdated = lastActivity.startTime != null ? lastActivity.startTime.value() : null;
            }

            break;
        case "GPS":
            // Get coordinates and elevation from storage
            //* This will have been stored by the onPosition event listener. If it's empty, user hasn't retrieved location yet.
            //* Elevation should never be null. If none was available, it will be set to 0.
            var gpsInfo = Storage.getValue($.getGpsInfoCacheKey()) as GPSInfo?;

            if (gpsInfo != null && gpsInfo["coordinates"] != null && gpsInfo["coordinates"].size() == 2) {
                coordinates = gpsInfo["coordinates"];
                // Set elevation to 0 if not available
                elevation = gpsInfo["elevation"];
                gpsQuality = gpsInfo["quality"];
                finalSource = "GPS";
                lastUpdated = gpsInfo["lastUpdated"];
            } else {
                $.log("[getLocation] GPS coordinates not yet available.");
                coordinates = null;
            }
            break;
        case "Weather":
            if (weather != null && weather.observationLocationPosition != null) {
                coordinates = weather.observationLocationPosition.toDegrees();
                finalSource = "Weather";
                lastUpdated = weather.observationTime != null ? weather.observationTime.value() : null;
            }

            break;
        case "Last Activity":
            if (lastActivity != null && lastActivity.currentLocation != null) {
                coordinates = lastActivity.currentLocation.toDegrees();
                finalSource = "Last Activity";
                lastUpdated = lastActivity.startTime != null ? lastActivity.startTime.value() : null;
            }

            break;
    }

    // Check if we got position
    if (coordinates == null || coordinates.size() != 2) {
        $.log("[getLocation] Unable to determine coordinates.");
        return null;
    } else {
        // Check if user has elevation disabled. If so, set elevation to 0.
        var useElevation = Properties.getValue("useElevation") as Boolean;
        if (useElevation == false) {
            elevation = 0;
        }

        $.log(Lang.format("[getLocation] Coordinates found via $1$: $2$ (elevated $3$ meters). UseElevation? $4$", [finalSource, coordinates, elevation, useElevation.toString()]));

        return (
            ({
                "coordinates" => coordinates,
                "elevation" => elevation,
                "source" => finalSource,
                "gpsQuality" => gpsQuality,
                "useElevation" => useElevation,
                "lastUpdated" => lastUpdated
            }) as LocationInfo
        );
    }
}

function setGpsLocation(info as Position.Info) {
    var coordinates = info.position.toDegrees();
    var elevation = info.altitude;
    var quality = info.accuracy;
    var lastUpdated = Time.now().value();

    // Save GPS coordinates to storage
    //* Any "bad" quality values are already considered handled in the `onPosition` function (the caller of this one).
    if (coordinates != null && coordinates.size() == 2) {
        // Parse GPS info
        // Set elevation to 0 if not available. If available, convert to number (removes decimals).
        var parsedElevation = elevation != null ? elevation.toNumber() : 0;
        // Set human-friendly quality value
        var parsedQuality = getGpsQuality(quality);
        var gpsInfo =
            ({
                "coordinates" => coordinates,
                "elevation" => parsedElevation,
                "quality" => parsedQuality,
                "lastUpdated" => lastUpdated
            }) as GPSInfo;

        // Set data to storage
        Storage.setValue($.getGpsInfoCacheKey(), gpsInfo);

        $.log(Lang.format("[saveGpsLocation] Fresh GPS coordinates saved: $1$ - Elevation: $2$ meters", [coordinates, parsedElevation]));
    } else {
        $.log("[saveGpsLocation] Provided coordinates are invalid.");
    }
}

function getGpsQuality(accuracy as Position.Quality) as String {
    var hrQuality = null;

    // Set human-friendly quality value
    if (accuracy == Position.QUALITY_NOT_AVAILABLE) {
        hrQuality = "Unavailable";
    } else if (accuracy == Position.QUALITY_LAST_KNOWN) {
        hrQuality = "Last Known";
    } else if (accuracy == Position.QUALITY_GOOD) {
        hrQuality = "Good";
    } else if (accuracy == Position.QUALITY_USABLE) {
        hrQuality = "Medium";
    } else if (accuracy == Position.QUALITY_POOR) {
        hrQuality = "Poor";
    } else {
        hrQuality = "Unknown";
    }

    return hrQuality;
}
