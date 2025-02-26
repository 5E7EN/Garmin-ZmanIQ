import Toybox.Weather;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Math;

using Toybox.Application.Properties as Properties;
using Toybox.Application.Storage as Storage;
using Toybox.System as System;

function getLocation() as Array? {
    var source = Properties.getValue("locationSource");

    var position = null;
    var finalSource = null;

    // Get available locations (except GPS, for now)
    var weatherLocation = Weather.getCurrentConditions();
    var lastActivityLocation = Activity.getActivityInfo();

    // Determine current coordinates based on the selected location source
    switch (source) {
        // TODO: Remove "Auto" as an option to avoid confusion.
        case "Auto":
            // First, try to get location based on weather location
            if (weatherLocation != null && weatherLocation.observationLocationPosition != null) {
                position = weatherLocation.observationLocationPosition.toDegrees();
                finalSource = "Weather";
            }
            // Second, try to get location based on last activity
            else if (lastActivityLocation != null && lastActivityLocation.currentLocation != null) {
                position = lastActivityLocation.currentLocation.toDegrees();
                finalSource = "Last Activity";
            }

            break;
        case "GPS":
            // Get coordinates from storage
            //* This will have been stored by the onPosition event listener. If it's empty, user hasn't retrieved location yet.
            var gpsInfo = Storage.getValue($.getGpsInfoCacheKey()) as GPSInfo;

            if (gpsInfo != null && gpsInfo["coordinates"] != null && gpsInfo["coordinates"].size() == 2) {
                // TODO: Add elevation
                position = gpsInfo["coordinates"];
                finalSource = "GPS";
            } else {
                $.log("[getLocation] GPS coordinates not yet available.");
                position = null;
            }
            break;
        case "Weather":
            if (weatherLocation != null && weatherLocation.observationLocationPosition != null) {
                position = weatherLocation.observationLocationPosition.toDegrees();
                finalSource = "Weather";
            }

            break;
        case "Last Activity":
            if (lastActivityLocation != null && lastActivityLocation.currentLocation != null) {
                position = lastActivityLocation.currentLocation.toDegrees();
                finalSource = "Last Activity";
            }

            break;
    }

    // Check if we got position
    if (position == null || position.size() != 2) {
        $.log("[getLocation] Unable to determine coordinates.");
    } else {
        $.log(Lang.format("[getLocation] Coordinates found via $1$: $2$", [finalSource, position]));
    }

    return position;
}

function setGpsLocation(info as Position.Info) {
    var coordinates = info.position.toDegrees();
    var elevation = info.altitude;
    var quality = info.accuracy;
    var hrQuality = null;

    // Save GPS coordinates to storage
    //* Any "bad" quality values are already considered handled in the `onPosition` function (the caller of this one).
    if (coordinates != null && coordinates.size() == 2) {
        // Set human-friendly quality value
        if (quality == Position.QUALITY_GOOD) {
            hrQuality = "Good";
        } else if (quality == Position.QUALITY_USABLE) {
            hrQuality = "Medium";
        } else if (quality == Position.QUALITY_POOR) {
            hrQuality = "Poor";
        } else {
            hrQuality = "Unknown";
        }

        // Parse GPS info
        var gpsInfo =
            ({
                "coordinates" => coordinates,
                "elevation" => elevation != null ? elevation.toNumber() : -1,
                "quality" => hrQuality
            }) as GPSInfo;

        // Set data to storage
        Storage.setValue($.getGpsInfoCacheKey(), gpsInfo);

        $.log(Lang.format("[saveGpsLocation] Fresh GPS coordinates saved: $1$ - Elevation: $2$ ", [coordinates, elevation ? elevation.toNumber() : "N/A"]));
    } else {
        $.log("[saveGpsLocation] Provided coordinates are invalid.");
    }
}
