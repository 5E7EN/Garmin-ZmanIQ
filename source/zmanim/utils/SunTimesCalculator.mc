using Toybox.Math as Maths;
using Toybox.Time.Gregorian as Gregorian;

module JewishCalendarModule {
    module ZmanimCalculators {
        class SunTimesCalculator extends AstronomicalCalculator {
            static const DEG_PER_HOUR = 360.0 / 24.0;

            function initialize() {
                AstronomicalCalculator.initialize();
            }

            function getCalculatorName() {
                return "US Naval Almanac Algorithm";
            }

            function getUTCSunrise(moment, geoLocation, zenith, adjustForElevation) {
                var doubleTime = null;

                var elevation = adjustForElevation ? geoLocation.elevation : 0;
                var adjustedZenith = adjustZenith(zenith, elevation);

                doubleTime = getTimeUTC(moment, geoLocation.latitude, geoLocation.longitude, adjustedZenith, true);
                return doubleTime;
            }

            function getUTCSunset(moment, geoLocation, zenith, adjustForElevation) {
                var doubleTime = null;

                var elevation = adjustForElevation ? geoLocation.elevation : 0;
                var adjustedZenith = adjustZenith(zenith, elevation);

                doubleTime = getTimeUTC(moment, geoLocation.latitude, geoLocation.longitude, adjustedZenith, false);
                return doubleTime;
            }

            // This implementation returns solar noon as the time halfway between sunrise and sunset.
            // NOAACalculator, the soon-to-be default calculator, returns true solar noon.
            // See here: https://kosherjava.com/2020/07/02/definition-of-chatzos/
            public function getUTCNoon(moment, geoLocation) {
                var sunrise = getUTCSunrise(moment, geoLocation, 90, false);
                var sunset = getUTCSunset(moment, geoLocation, 90, false);
                var noon = sunrise + (sunset - sunrise) / 2;

                if (noon < 0) {
                    noon += 12;
                }
                if (noon < sunrise) {
                    noon -= 12;
                }

                return noon;
            }

            public function getUTCMidnight(moment, geoLocation) {
                return getUTCNoon(moment, geoLocation) + 12;
            }

            static function getTimeUTC(moment, latitude, longitude, zenith, isSunrise) {
                var dayOfYear = getDayOfYear(moment);
                var sunMeanAnomaly = getMeanAnomaly(dayOfYear, longitude, isSunrise);
                var sunTrueLong = getSunTrueLongitude(sunMeanAnomaly);
                var sunRightAscensionHours = getSunRightAscensionHours(sunTrueLong);
                var cosLocalHourAngle = getCosLocalHourAngle(sunTrueLong, latitude, zenith);

                var localHourAngle = 0;
                if (isSunrise) {
                    localHourAngle = 360.0 - ExtendedMaths.acosDeg(cosLocalHourAngle);
                } else {
                    // sunset
                    localHourAngle = ExtendedMaths.acosDeg(cosLocalHourAngle);
                }
                var localHour = localHourAngle / DEG_PER_HOUR;

                var localMeanTime = getLocalMeanTime(localHour, sunRightAscensionHours, getApproxTimeDays(dayOfYear, getHoursFromMeridian(longitude), isSunrise));
                var pocessedTime = localMeanTime - getHoursFromMeridian(longitude);
                while (pocessedTime < 0.0) {
                    pocessedTime += 24.0;
                }
                while (pocessedTime >= 24.0) {
                    pocessedTime -= 24.0;
                }

                //System.println("DOY"+dayOfYear);
                //System.println(sunMeanAnomaly);
                //System.println(sunTrueLong);
                //System.println(sunRightAscensionHours);
                //System.println(cosLocalHourAngle);
                //	System.println(pocessedTime);

                return pocessedTime;
            }

            static function getDayOfYear(moment) {
                var timeInfo = Gregorian.info(moment, Toybox.Time.FORMAT_SHORT);
                var n1 = (275 * timeInfo.month) / 9;
                var n2 = (timeInfo.month + 9) / 12;
                var n3 = 1 + (timeInfo.year - 4 * (timeInfo.year / 4) + 2) / 3;
                return n1 - n2 * n3 + timeInfo.day - 30;
            }

            static function getMeanAnomaly(dayOfYear, longitude, isSunrise) {
                return 0.9856 * getApproxTimeDays(dayOfYear, getHoursFromMeridian(longitude), isSunrise) - 3.289;
            }

            static function getHoursFromMeridian(longitude) {
                return longitude / DEG_PER_HOUR;
            }

            static function getApproxTimeDays(dayOfYear, hoursFromMeridian, isSunrise) {
                if (isSunrise) {
                    return dayOfYear + (6.0 - hoursFromMeridian) / 24;
                } else {
                    // sunset
                    return dayOfYear + (18.0 - hoursFromMeridian) / 24;
                }
            }

            static function getSunTrueLongitude(sunMeanAnomaly) {
                var l = sunMeanAnomaly + 1.916 * ExtendedMaths.sinDeg(sunMeanAnomaly) + 0.02 * ExtendedMaths.sinDeg(2 * sunMeanAnomaly) + 282.634;

                // get longitude into 0-360 degree range
                if (l >= 360.0) {
                    l = l - 360.0;
                }
                if (l < 0) {
                    l = l + 360.0;
                }
                return l;
            }

            static function getSunRightAscensionHours(sunTrueLongitude) {
                var a = 0.91764 * ExtendedMaths.tanDeg(sunTrueLongitude);
                var ra = (360.0 / (2.0 * Maths.PI)) * Maths.atan(a);

                var lQuadrant = ExtendedMaths.floor(sunTrueLongitude / 90.0) * 90.0;
                var raQuadrant = ExtendedMaths.floor(ra / 90.0) * 90.0;
                ra = ra + (lQuadrant - raQuadrant);

                return ra / DEG_PER_HOUR; // convert to hours
            }

            static function getCosLocalHourAngle(sunTrueLongitude, latitude, zenith) {
                var sinDec = 0.39782 * ExtendedMaths.sinDeg(sunTrueLongitude);
                var cosDec = ExtendedMaths.cosDeg(ExtendedMaths.asinDeg(sinDec));
                return (ExtendedMaths.cosDeg(zenith) - sinDec * ExtendedMaths.sinDeg(latitude)) / (cosDec * ExtendedMaths.cosDeg(latitude));
            }

            static function getLocalMeanTime(localHour, sunRightAscensionHours, approxTimeDays) {
                return localHour + sunRightAscensionHours - 0.06571 * approxTimeDays - 6.622;
            }
        }
    }
}
