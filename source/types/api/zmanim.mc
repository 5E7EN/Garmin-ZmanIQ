import Toybox.Lang;

typedef ZmanimTimes as {
    "chatzotNight" as String,
    "alotHaShachar" as String,
    "misheyakir" as String,
    "misheyakirMachmir" as String,
    "dawn" as String,
    "sunrise" as String,
    "sofZmanShmaMGA19Point8" as String,
    "sofZmanShmaMGA16Point1" as String,
    "sofZmanShmaMGA" as String,
    "sofZmanShma" as String,
    "sofZmanTfillaMGA19Point8" as String,
    "sofZmanTfillaMGA16Point1" as String,
    "sofZmanTfillaMGA" as String,
    "sofZmanTfilla" as String,
    "chatzot" as String,
    "minchaGedola" as String,
    "minchaGedolaMGA" as String,
    "minchaKetana" as String,
    "minchaKetanaMGA" as String,
    "plagHaMincha" as String,
    "sunset" as String,
    "beinHaShmashos" as String,
    "dusk" as String,
    "tzeit7083deg" as String,
    "tzeit85deg" as String,
    "tzeit42min" as String,
    "tzeit50min" as String,
    "tzeit72min" as String
};

typedef ZmanimLocation as {
    "title" as String,
    "city" as String,
    "tzid" as String,
    "latitude" as Number,
    "longitude" as Number,
    "geo" as String
};

typedef ZmanimApiResponse as {
    "date" as String,
    "location" as ZmanimLocation,
    "times" as ZmanimTimes
};
