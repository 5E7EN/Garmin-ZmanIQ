import Toybox.Lang;

typedef GPSInfo as {
    "coordinates" as Array<Double>,
    "elevation" as Number?,
    "quality" as String,
    "lastUpdated" as Number?
};

typedef LocationInfo as {
    "coordinates" as Array<Double>,
    "source" as String,
    "elevation" as Number?,
    "gpsQuality" as String?,
    "lastUpdated" as Number?
};
