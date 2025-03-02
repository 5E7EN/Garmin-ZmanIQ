using Toybox.Time as Time;

module JewishCalendarModule {
    module ZmanimCalendars {
        // 90° below the vertical. Used as a basis for most calculations since the location of the sun is 90° below
        // the horizon at sunrise and sunset.
        const GEOMETRIC_ZENITH = 90;

        class AstronomicalCalendar {
            // Sun's zenith at civil twilight (96°).
            const CIVIL_ZENITH = 96;
            // Sun's zenith at nautical twilight (102°).
            const NAUTICAL_ZENITH = 102;
            // Sun's zenith at astronomical twilight (108°).
            const ASTRONOMICAL_ZENITH = 108;

            hidden var calendar;
            hidden var geoLocation;

            hidden function getAstronomicalCalculator() {
                return ZmanimCalculators.AstronomicalCalculator.getDefault();
            }

            function initialize(ingeoLocation) {
                calendar = Time.now();
                geoLocation = ingeoLocation;
            }

            function getSunrise() {
                var sunrise = getUTCSunrise(GEOMETRIC_ZENITH);
                if (null == sunrise) {
                    return null;
                } else {
                    return getDateFromTime(sunrise);
                }
            }

            function getSeaLevelSunrise() {
                var sunrise = getUTCSeaLevelSunrise(GEOMETRIC_ZENITH);
                if (null == sunrise) {
                    return null;
                } else {
                    return getDateFromTime(sunrise);
                }
            }

            function getSunriseOffsetByDegrees(offsetZenith) {
                var dawn = getUTCSunrise(offsetZenith);
                if (null == dawn) {
                    return null;
                } else {
                    return getDateFromTime(dawn);
                }
            }

            function getSunset() {
                var sunset = getUTCSunset(GEOMETRIC_ZENITH);
                if (null == sunset) {
                    return null;
                } else {
                    //return getAdjustedSunsetDate(getDateFromTime(sunset), getSunrise());
                    return getDateFromTime(sunset);
                }
            }

            function getSeaLevelSunset() {
                var sunset = getUTCSeaLevelSunset(GEOMETRIC_ZENITH);
                if (null == sunset) {
                    return null;
                } else {
                    //return getAdjustedSunsetDate(getDateFromTime(sunset), getSunrise());
                    return getDateFromTime(sunset);
                }
            }

            function getSunsetOffsetByDegrees(offsetZenith) {
                var sunset = getUTCSunset(offsetZenith);
                if (null == sunset) {
                    return null;
                } else {
                    //return getAdjustedSunsetDate(getDateFromTime(sunset), getSunrise());
                    return getDateFromTime(sunset);
                }
            }

            hidden function getDateFromTime(time) {
                // Check for null or NaN
                //* This occurs when making calculations, for example, at locations far north.
                if (null == time || ExtendedMaths.isNaN(time) == true) {
                    return null;
                }
                var calculatedTime = time;

                var clockTime = System.getClockTime();
                var timeInfo = Time.Gregorian.info(calendar, Toybox.Time.FORMAT_SHORT);

                var hours = calculatedTime.toNumber();
                calculatedTime -= hours;
                calculatedTime *= 60;
                var minutes = calculatedTime.toNumber(); // retain only the minutes
                calculatedTime -= minutes;
                calculatedTime *= 60;
                var seconds = calculatedTime.toNumber(); // retain only the seconds
                calculatedTime -= seconds; // remaining milliseconds

                var cal = Time.Gregorian.moment({ :year => timeInfo.year, :month => timeInfo.month, :day => timeInfo.day, :hour => hours, :minute => minutes, :second => seconds });

                var gmtOffset = (clockTime.timeZoneOffset - clockTime.dst) / 3600;
                if (time + gmtOffset > 24) {
                    var duration = Time.Gregorian.duration({ :days => -1 });
                    cal = cal.add(duration);
                } else if (time + gmtOffset < 0) {
                    var duration = Time.Gregorian.duration({ :days => 1 });
                    cal = cal.add(duration);
                }

                return cal;
            }

            function getUTCSunrise(zenith) {
                return getAstronomicalCalculator().getUTCSunrise(calendar, geoLocation, zenith, true);
            }

            function getUTCSeaLevelSunrise(zenith) {
                return getAstronomicalCalculator().getUTCSunrise(calendar, geoLocation, zenith, false);
            }

            function getUTCSunset(zenith) {
                return getAstronomicalCalculator().getUTCSunset(calendar, geoLocation, zenith, true);
            }

            function getUTCSeaLevelSunset(zenith) {
                return getAstronomicalCalculator().getUTCSunset(calendar, geoLocation, zenith, false);
            }

            function getTimeOffset(time, offset) {
                if (time == null) {
                    return null;
                }
                return time.add(Time.Gregorian.duration({ :seconds => offset }));
            }

            function getTemporalHour() {
                return getSpecificTemporalHour(getSeaLevelSunrise(), getSeaLevelSunset());
            }

            function getSpecificTemporalHour(startOfday, endOfDay) {
                if (startOfday == null || endOfDay == null) {
                    return 0;
                }
                return (endOfDay.value() - startOfday.value()) / 12;
            }

            function getSunTransit() {
                // OLD: return getSpecificSunTransit(getSeaLevelSunrise(), getSeaLevelSunset());
                var noon = getAstronomicalCalculator().getUTCNoon(calendar, geoLocation);
                return getDateFromTime(noon);
            }

            function getSolarMidnight() {
                var midnight = getAstronomicalCalculator().getUTCMidnight(calendar, geoLocation);
                return getDateFromTime(midnight);
            }

            function getSpecificSunTransit(startOfDay, endOfDay) {
                var temporalHour = getSpecificTemporalHour(startOfDay, endOfDay);
                return getTimeOffset(startOfDay, temporalHour * 6);
            }
        }

        class ZmanimCalendar extends AstronomicalCalendar {
            // The zenith of 8.5° below geometric zenith (90°).
            hidden static const ZENITH_8_POINT_5 = GEOMETRIC_ZENITH + 8.5;
            // The zenith of 11.5° below geometric zenith (90°).
            hidden static const ZENITH_11_POINT_5 = GEOMETRIC_ZENITH + 11.5;
            // The zenith of 16.1° below geometric zenith (90°).
            hidden static const ZENITH_16_POINT_1 = GEOMETRIC_ZENITH + 16.1;
            // TODO: Create setter to allow for adjustments (e.g. user is in certain parts of Israel where the offset is different)
            hidden var candleLightingOffset = 18;

            function initialize(ingeoLocation, setCalendar) {
                AstronomicalCalendar.initialize(ingeoLocation);
                calendar = setCalendar;
                geoLocation = ingeoLocation;
            }

            function getTzait() {
                return getSunsetOffsetByDegrees(ZENITH_8_POINT_5);
            }

            function getAlotHashachar() {
                return getSunriseOffsetByDegrees(ZENITH_16_POINT_1);
            }

            function getAlot72() {
                return getTimeOffset(getSeaLevelSunrise(), -72 * Time.Gregorian.SECONDS_PER_MINUTE);
            }

            function getChatzot() {
                return getSunTransit();
            }

            function getChatzotAsHalfDay() {
                return getSpecificSunTransit(getSeaLevelSunrise(), getSeaLevelSunset());
            }

            function getSofZmanShma(startOfDay, endOfDay) {
                var shaahZmanit = getSpecificTemporalHour(startOfDay, endOfDay);
                return getTimeOffset(startOfDay, shaahZmanit * 3);
            }

            function getSofZmanShmaGRA() {
                return getSofZmanShma(getSeaLevelSunrise(), getSeaLevelSunset());
            }

            function getSofZmanShmaMGA() {
                return getSofZmanShma(getAlot72(), getTzait72());
            }

            function getTzait72() {
                return getTimeOffset(getSeaLevelSunset(), 72 * Time.Gregorian.SECONDS_PER_MINUTE);
            }

            function getCandleLighting() {
                return getTimeOffset(getSeaLevelSunset(), -candleLightingOffset * Time.Gregorian.SECONDS_PER_MINUTE);
            }

            function getSofZmanTfila(startOfDay, endOfDay) {
                var shaahZmanit = getSpecificTemporalHour(startOfDay, endOfDay);
                return getTimeOffset(startOfDay, shaahZmanit * 4);
            }

            function getSofZmanTfilaGRA() {
                return getSofZmanTfila(getSeaLevelSunrise(), getSeaLevelSunset());
            }

            function getSofZmanTfilaMGA() {
                return getSofZmanTfila(getAlot72(), getTzait72());
            }

            function getSpecificMinchaGedola(startOfDay, endOfDay) {
                var shaahZmanit = getSpecificTemporalHour(startOfDay, endOfDay);
                return getTimeOffset(startOfDay, shaahZmanit * 6.5);
            }

            function getMinchaGedola() {
                return getSpecificMinchaGedola(getSeaLevelSunrise(), getSeaLevelSunset());
            }

            function getSpecificMinchaKetana(startOfDay, endOfDay) {
                var shaahZmanit = getSpecificTemporalHour(startOfDay, endOfDay);
                return getTimeOffset(startOfDay, shaahZmanit * 9.5);
            }

            function getMinchaKetana() {
                return getSpecificMinchaKetana(getSeaLevelSunrise(), getSeaLevelSunset());
            }

            function getSpecificPlagHamincha(startOfDay, endOfDay) {
                var shaahZmanit = getSpecificTemporalHour(startOfDay, endOfDay);
                return getTimeOffset(startOfDay, shaahZmanit * 10.75);
            }

            function getPlagHamincha() {
                return getSpecificPlagHamincha(getSeaLevelSunrise(), getSeaLevelSunset());
            }

            // Machlokes between (MyZmanim)[https://i.5e7en.me/3uc0mOvB8Cc5.png] and (KosherJava)[https://github.com/KosherJava/zmanim/blob/04dc83975db43582414d8639e0e204d9681aa6f0/src/main/java/com/kosherjava/zmanim/ComplexZmanimCalendar.java#L191] whether this translates to 60 or 52 minutes before sunrise.
            // Ayin Sham.
            function getMisheyakir11Point5Degrees() {
                return getSunriseOffsetByDegrees(ZENITH_11_POINT_5);
            }
        }
    }
}
