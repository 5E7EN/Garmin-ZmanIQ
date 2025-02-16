import Toybox.Lang;
import Toybox.Time;

// TODO: Use all of the following times:
// Alos
// Sunrise
// Sof Zman Shema GR"A / Sof Zman Shema MG"A
// Sof Zman Tfila GR"A / Sof Zman Tfila MG"A
// Chatzos
// Mincha Gedola
// Mincha Ketana
// Plag Hamincha
// Sunset
// Tzais
// Tzais 72

// TODO: Use symbols instead? May save memory.
var ZmanNames = {
    "ALOS" => "alos",
    "SUNRISE" => "sunrise",
    "SOF_ZMAN_SHEMA" => "sofZmanShema",
    "SOF_ZMAN_TEFILLA" => "sofZmanTefilla",
    "CHATZOS" => "chatzos",
    "MINCHA_GEDOLA" => "minchaGedola",
    "SUNSET" => "sunset",
    "TZEIS" => "tzeis"
};

var ZmanimFriendlyNames = {
    ZmanNames["ALOS"] => "Alos 16.1°",
    ZmanNames["SUNRISE"] => "Sunrise",
    ZmanNames["SOF_ZMAN_SHEMA"] => "Sof Zman Shema",
    ZmanNames["SOF_ZMAN_TEFILLA"] => "Sof Zman Tefilla",
    ZmanNames["CHATZOS"] => "Chatzos",
    ZmanNames["MINCHA_GEDOLA"] => "Mincha Gedola",
    ZmanNames["SUNSET"] => "Sunset",
    ZmanNames["TZEIS"] => "Tzeis"
};

typedef ZmanTime as {
    "name" as Symbol,
    "time" as Time.Moment
};

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
