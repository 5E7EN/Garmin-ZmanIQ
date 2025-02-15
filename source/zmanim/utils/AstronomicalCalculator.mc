using Toybox.Math as Maths;
using Toybox.Time.Gregorian as Gregorian;

module JewishCalendarModule {
    module ZmanimCalculators {
        class AstronomicalCalculator {
            // The commonly used average solar refraction. Calendrical Calculations lists a more accurate global average of
            // 34.478885263888294
            static const REFRACTION = 34.0 / 60.0;
            // The commonly used average solar radius in minutes of a degree.
            static const SOLAR_RADIUS = 16.0 / 60.0;
            // The zenith of astronomical sunrise and sunset. The sun is 90° from the vertical 0°.
            static const GEOMETRIC_ZENITH = 90;
            // The commonly used average earth radius in KM.
            static const EARTH_RADIUS = 6356.9;

            public function initialize() {}

            // Returns the default class for calculating sunrise and sunset. This is currently the
            // SunTimesCalculator, but this will change in the future once NOAA is ported.
            public function getDefault() {
                return new ZmanimCalculators.SunTimesCalculator();
            }

            // Adjusts the zenith of astronomical sunrise and sunset to account for solar refraction, solar radius, and elevation.
            public function adjustZenith(zenith, elevation) {
                var adjustedZenith = zenith;
                if (zenith == GEOMETRIC_ZENITH) {
                    // only adjust if it is exactly sunrise or sunset
                    adjustedZenith = zenith + (SOLAR_RADIUS + REFRACTION + getElevationAdjustment(elevation));
                }
                return adjustedZenith;
            }

            // Returns the adjustment to the zenith required to account for the elevation.
            public function getElevationAdjustment(elevation) {
                // double elevationAdjustment = 0.0347 * Math.sqrt(elevation);
                var elevationAdjustment = ExtendedMaths.toDegrees(Maths.acos(EARTH_RADIUS / (EARTH_RADIUS + elevation / 1000)));
                return elevationAdjustment;
            }

            // Abstract method
            // Returns the name of the algorithm.
            public function getCalculatorName() {}

            // Abstract method
            // Calculates UTC sunrise as well as any time based on an angle above or below sunrise.
            public function getUTCSunrise(moment, geoLocation, zenith, adjustForElevation) {}

            // Abstract method
            // Calculates UTC sunset as well as any time based on an angle above or below sunset.
            public function getUTCSunset(moment, geoLocation, zenith, adjustForElevation) {}

            // Abstract method
            // Returns solar noon (UTC) for the given day at the given location on earth.
            public function getUTCNoon(moment, geoLocation) {}

            // Abstract method
            // Returns solar midnight (UTC) for the given day at the given location on earth.
            public function getUTCMidnight(moment, geoLocation) {}
        }
    }
}
