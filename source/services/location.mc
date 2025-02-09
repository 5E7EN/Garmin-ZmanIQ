import Toybox.Weather;
import Toybox.Activity;
import Toybox.Lang;

using Toybox.Application.Properties as Properties;

function getLocation() as Array? {
    var source = Properties.getValue("locationSource");

    var position = null;
    var finalSource = null;

    // Get available locations (except GPS, for now)
    var weatherLocation = Weather.getCurrentConditions();
    var lastActivityLocation = Activity.getActivityInfo();

    // Determine current coordinates based on the selected location source
    switch (source) {
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
            // TODO: Implement
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
