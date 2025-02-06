import Toybox.Lang;

using Toybox.Application.Properties as Properties;

function getLocation() as Array? {
    var source = Properties.getValue("locationSource");

    // Temp debug, return hardcoded
    var latitude = 22.1159;
    var longitude = -53.6311;

    // Determine current coordinates based on the selected location source
    // TODO: Implement
    if (source.equals("Auto")) {
    } else if (source.equals("GPS")) {
    } else if (source.equals("Weather")) {
    } else if (source.equals("Last Activity")) {
    }

    return [latitude, longitude];
}
