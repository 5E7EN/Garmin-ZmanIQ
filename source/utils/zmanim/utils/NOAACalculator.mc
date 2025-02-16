using Toybox.Math as Maths;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.System as Sys;

module JewishCalendarModule {
    module ZmanimCalculators {
        class NOAACalculator extends AstronomicalCalculator {
            static const JULIAN_DAY_JAN_1_2000 = 2451545.0;
            static const JULIAN_DAYS_PER_CENTURY = 36525.0;

            //* Workaround for named enums in classes...
            class SolarEvent {
                enum {
                    /**SUNRISE A solar event related to sunrise*/ SUNRISE,
                    /**SUNSET A solar event related to sunset*/ SUNSET,
                    /**NOON A solar event related to noon*/ NOON,
                    /**MIDNIGHT A solar event related to midnight*/ MIDNIGHT
                }
            }

            function initialize() {
                AstronomicalCalculator.initialize();
            }

            function getCalculatorName() {
                return "US National Oceanic and Atmospheric Administration Algorithm"; // Implementation of the Jean Meeus algorithm
            }

            function getUTCSunrise(moment, geoLocation, zenith, adjustForElevation) {
                var elevation = adjustForElevation ? geoLocation.elevation : 0;
                var adjustedZenith = adjustZenith(zenith, elevation);

                var sunrise = getSunRiseSetUTC(moment, geoLocation.latitude, -geoLocation.longitude, adjustedZenith, SolarEvent.SUNRISE);
                sunrise = sunrise / 60;

                return sunrise > 0 ? ExtendedMaths.fmod(sunrise, 24.0) : ExtendedMaths.fmod(sunrise, 24.0) + 24; // ensure that the time is >= 0 and < 24
            }

            function getUTCSunset(moment, geoLocation, zenith, adjustForElevation) {
                var elevation = adjustForElevation ? geoLocation.elevation : 0;
                var adjustedZenith = adjustZenith(zenith, elevation);

                var sunset = getSunRiseSetUTC(moment, geoLocation.latitude, -geoLocation.longitude, adjustedZenith, SolarEvent.SUNSET);
                sunset = sunset / 60;

                return sunset > 0 ? ExtendedMaths.fmod(sunset, 24.0) : ExtendedMaths.fmod(sunset, 24.0) + 24; // ensure that the time is >= 0 and < 24
            }

            static function getJulianDay(moment) {
                var timeInfo = Gregorian.info(moment, Toybox.Time.FORMAT_SHORT);
                var year = timeInfo.year;
                var month = timeInfo.month; // No need for + 1. Monkey-C doesn't use 0-based months.
                var day = timeInfo.day;

                if (month <= 2) {
                    year -= 1;
                    month += 12;
                }
                var a = year / 100;
                var b = 2 - a + a / 4;
                return ExtendedMaths.floor(365.25 * (year + 4716)) + ExtendedMaths.floor(30.6001 * (month + 1)) + day + b - 1524.5;
            }

            function getJulianCenturiesFromJulianDay(julianDay) {
                return (julianDay - JULIAN_DAY_JAN_1_2000) / JULIAN_DAYS_PER_CENTURY;
            }

            function getSunGeometricMeanLongitude(julianCenturies) {
                var longitude = 280.46646 + julianCenturies * (36000.76983 + 0.0003032 * julianCenturies);
                return longitude > 0 ? ExtendedMaths.fmod(longitude, 360.0) : ExtendedMaths.fmod(longitude, 360.0) + 360; // ensure that the longitude is >= 0 and < 360
            }

            function getSunGeometricMeanAnomaly(julianCenturies) {
                return 357.52911 + julianCenturies * (35999.05029 - 0.0001537 * julianCenturies);
            }

            function getEarthOrbitEccentricity(julianCenturies) {
                return 0.016708634 - julianCenturies * (0.000042037 + 0.0000001267 * julianCenturies);
            }

            function getSunEquationOfCenter(julianCenturies) {
                var m = getSunGeometricMeanAnomaly(julianCenturies);
                var mrad = Maths.toRadians(m);
                var sinm = Maths.sin(mrad);
                var sin2m = Maths.sin(mrad + mrad);
                var sin3m = Maths.sin(mrad + mrad + mrad);
                return sinm * (1.914602 - julianCenturies * (0.004817 + 0.000014 * julianCenturies)) + sin2m * (0.019993 - 0.000101 * julianCenturies) + sin3m * 0.000289;
            }

            function getSunTrueLongitude(julianCenturies) {
                var sunLongitude = getSunGeometricMeanLongitude(julianCenturies);
                var center = getSunEquationOfCenter(julianCenturies);
                return sunLongitude + center;
            }

            function getSunApparentLongitude(julianCenturies) {
                var sunTrueLongitude = getSunTrueLongitude(julianCenturies);
                var omega = 125.04 - 1934.136 * julianCenturies;
                var lambda = sunTrueLongitude - 0.00569 - 0.00478 * Maths.sin(Maths.toRadians(omega));
                return lambda;
            }

            function getMeanObliquityOfEcliptic(julianCenturies) {
                var seconds = 21.448 - julianCenturies * (46.815 + julianCenturies * (0.00059 - julianCenturies * 0.001813));
                return 23.0 + (26.0 + seconds / 60.0) / 60.0;
            }

            function getObliquityCorrection(julianCenturies) {
                var obliquityOfEcliptic = getMeanObliquityOfEcliptic(julianCenturies);
                var omega = 125.04 - 1934.136 * julianCenturies;
                return obliquityOfEcliptic + 0.00256 * Math.cos(Math.toRadians(omega));
            }

            function getSunDeclination(julianCenturies) {
                var obliquityCorrection = getObliquityCorrection(julianCenturies);
                var lambda = getSunApparentLongitude(julianCenturies);
                var sint = Maths.sin(Math.toRadians(obliquityCorrection)) * Maths.sin(Maths.toRadians(lambda));
                var theta = Maths.toDegrees(Maths.asin(sint));
                return theta;
            }

            function getEquationOfTime(julianCenturies) {
                var epsilon = getObliquityCorrection(julianCenturies);
                var geomMeanLongSun = getSunGeometricMeanLongitude(julianCenturies);
                var eccentricityEarthOrbit = getEarthOrbitEccentricity(julianCenturies);
                var geomMeanAnomalySun = getSunGeometricMeanAnomaly(julianCenturies);
                var y = Maths.tan(Maths.toRadians(epsilon) / 2.0);
                y *= y;
                var sin2l0 = Maths.sin(2.0 * Maths.toRadians(geomMeanLongSun));
                var sinm = Maths.sin(Maths.toRadians(geomMeanAnomalySun));
                var cos2l0 = Maths.cos(2.0 * Maths.toRadians(geomMeanLongSun));
                var sin4l0 = Maths.sin(4.0 * Maths.toRadians(geomMeanLongSun));
                var sin2m = Maths.sin(2.0 * Maths.toRadians(geomMeanAnomalySun));
                var equationOfTime =
                    y * sin2l0 -
                    2.0 * eccentricityEarthOrbit * sinm +
                    4.0 * eccentricityEarthOrbit * y * sinm * cos2l0 -
                    0.5 * y * y * sin4l0 -
                    1.25 * eccentricityEarthOrbit * eccentricityEarthOrbit * sin2m;
                return Maths.toDegrees(equationOfTime) * 4.0;
            }

            function getSunHourAngle(latitude, solarDeclination, zenith, solarEvent) {
                var latRad = Maths.toRadians(latitude);
                var sdRad = Maths.toRadians(solarDeclination);
                var hourAngle = Maths.acos(Maths.cos(Maths.toRadians(zenith)) / (Maths.cos(latRad) * Maths.cos(sdRad)) - Maths.tan(latRad) * Maths.tan(sdRad));

                if (solarEvent == SolarEvent.SUNSET) {
                    hourAngle = -hourAngle;
                }

                return hourAngle;
            }

            function getSolarElevation(moment, latitude, longitude) {
                var julianDay = getJulianDay(moment);
                var julianCenturies = getJulianCenturiesFromJulianDay(julianDay);
                var eot = getEquationOfTime(julianCenturies);

                var timeInfo = Gregorian.info(moment, Toybox.Time.FORMAT_SHORT);
                // double adjustedLongitude = (calendar.get(Calendar.HOUR_OF_DAY) + 12.0) + (calendar.get(Calendar.MINUTE) + eot + calendar.get(Calendar.SECOND) / 60.0) / 60.0;
                var adjustedLongitude = timeInfo.hour + 12.0 + (timeInfo.min + eot + timeInfo.sec / 60.0) / 60.0;
                adjustedLongitude = -((adjustedLongitude * 360.0) / 24.0) % 360.0;
                var hourAngle_rad = Maths.toRadians(longitude - adjustedLongitude);

                var declination = getSunDeclination(julianCenturies);
                var dec_rad = Maths.toRadians(declination);
                var lat_rad = Maths.toRadians(latitude);
                return Maths.toDegrees(Maths.asin(Maths.sin(lat_rad) * Maths.sin(dec_rad) + Maths.cos(lat_rad) * Maths.cos(dec_rad) * Maths.cos(hourAngle_rad)));
            }

            function getSolarAzimuth(moment, latitude, longitude) {
                var julianDay = getJulianDay(moment);
                var julianCenturies = getJulianCenturiesFromJulianDay(julianDay);
                var eot = getEquationOfTime(julianCenturies);

                var timeInfo = Gregorian.info(moment, Toybox.Time.FORMAT_SHORT);
                //var adjustedLongitude = calendar.get(Calendar.HOUR_OF_DAY) + 12.0 + (calendar.get(Calendar.MINUTE) + eot + calendar.get(Calendar.SECOND) / 60.0) / 60.0;
                var adjustedLongitude = timeInfo.hour + 12.0 + (timeInfo.min + eot + timeInfo.sec / 60.0) / 60.0;
                adjustedLongitude = -((adjustedLongitude * 360.0) / 24.0) % 360.0;
                var hourAngle_rad = Maths.toRadians(longitude - adjustedLongitude);

                var declination = getSunDeclination(julianCenturies);
                var dec_rad = Maths.toRadians(declination);
                var lat_rad = Maths.toRadians(latitude);
                return Maths.toDegrees(Maths.atan(Maths.sin(hourAngle_rad) / (Maths.cos(hourAngle_rad) * Maths.sin(lat_rad) - Maths.tan(dec_rad) * Maths.cos(lat_rad)))) + 180;
            }

            function getUTCNoon(moment, geoLocation) {
                var noon = getSolarNoonMidnightUTC(getJulianDay(moment), -geoLocation.longitude, SolarEvent.NOON);
                noon = noon / 60;

                return noon > 0 ? ExtendedMaths.fmod(noon, 24) : ExtendedMaths.fmod(noon, 24) + 24; // ensure that the time is >= 0 and < 24
            }

            function getUTCMidnight(moment, geoLocation) {
                var midnight = getSolarNoonMidnightUTC(getJulianDay(moment), -geoLocation.longitude, SolarEvent.MIDNIGHT);
                midnight = midnight / 60;
                return midnight > 0 ? midnight % 24 : (midnight % 24) + 24; // ensure that the time is >= 0 and < 24
            }

            function getSolarNoonMidnightUTC(julianDay, longitude, solarEvent) {
                julianDay = solarEvent == SolarEvent.NOON ? julianDay : julianDay + 0.5;
                // First pass for approximate solar noon to calculate equation of time
                var tnoon = getJulianCenturiesFromJulianDay(julianDay + longitude / 360.0);
                var equationOfTime = getEquationOfTime(tnoon);
                var solNoonUTC = longitude * 4 - equationOfTime; // minutes

                // second pass
                var newt = getJulianCenturiesFromJulianDay(julianDay + solNoonUTC / 1440.0);
                equationOfTime = getEquationOfTime(newt);
                return (solarEvent == SolarEvent.NOON ? 720 : 1440) + longitude * 4 - equationOfTime;
            }

            function getSunRiseSetUTC(moment, latitude, longitude, zenith, solarEvent) {
                var julianDay = getJulianDay(moment);

                // Find the time of solar noon at the location, and use that declination.
                // This is better than start of the Julian day
                // TODO really not needed since the Julian day starts from local fixed noon. Changing this would be more
                // efficient but would likely cause a very minor discrepancy in the calculated times (likely not reducing
                // accuracy, just slightly different, thus potentially breaking test cases). Regardless, it would be within
                // milliseconds.
                var noonmin = getSolarNoonMidnightUTC(julianDay, longitude, SolarEvent.NOON);

                var tnoon = getJulianCenturiesFromJulianDay(julianDay + noonmin / 1440.0);

                // First calculates sunrise and approximate length of day
                var equationOfTime = getEquationOfTime(tnoon);
                var solarDeclination = getSunDeclination(tnoon);
                var hourAngle = getSunHourAngle(latitude, solarDeclination, zenith, solarEvent);
                var delta = longitude - Maths.toDegrees(hourAngle);
                var timeDiff = 4 * delta;
                var timeUTC = 720 + timeDiff - equationOfTime;

                // Second pass includes fractional Julian Day in gamma calc
                var newt = getJulianCenturiesFromJulianDay(julianDay + timeUTC / 1440.0);
                equationOfTime = getEquationOfTime(newt);

                solarDeclination = getSunDeclination(newt);
                hourAngle = getSunHourAngle(latitude, solarDeclination, zenith, solarEvent);
                delta = longitude - Maths.toDegrees(hourAngle);
                timeDiff = 4 * delta;
                timeUTC = 720 + timeDiff - equationOfTime;
                return timeUTC;
            }
        }
    }
}
