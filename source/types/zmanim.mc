import Toybox.Lang;
import Toybox.Time;

// Zmanim to display:
// Alos 16.1 ✅
// Misheyakir - See TODO.md
// Sunrise ✅
// Sof Zman Shema GR"A / Sof Zman Shema MG"A ✅
// Sof Zman Tfila GR"A / Sof Zman Tfila MG"A ✅
// Chatzos ✅
// Mincha Gedola ✅
// Mincha Ketana ✅
// Plag Hamincha ✅
// Sunset ✅
// Tzais ✅
// Tzais 72 ✅

// TODO: Use symbols instead? May save memory.
var ZmanNames = {
    "ALOS" => "alos",
    "SUNRISE" => "sunrise",
    "SOF_ZMAN_SHEMA" => "sofZmanShema",
    "SOF_ZMAN_TEFILLA" => "sofZmanTefilla",
    "CHATZOS" => "chatzos",
    "MINCHA_GEDOLA" => "minchaGedola",
    "MINCHA_KETANA" => "minchaKetana",
    "PLAG_HAMINCHA" => "plagHamincha",
    "SUNSET" => "sunset",
    "TZEIS" => "tzeis",
    "TZEIS_72" => "tzeis72"
};

var ZmanimFriendlyNames = {
    ZmanNames["ALOS"] => "Alos 16.1°",
    ZmanNames["SUNRISE"] => "Sunrise",
    ZmanNames["SOF_ZMAN_SHEMA"] => "Sof Zman Shema",
    ZmanNames["SOF_ZMAN_TEFILLA"] => "Sof Zman Tefilla",
    ZmanNames["CHATZOS"] => "Chatzos",
    ZmanNames["MINCHA_GEDOLA"] => "Earliest Mincha",
    ZmanNames["MINCHA_KETANA"] => "Mincha Ketana",
    ZmanNames["PLAG_HAMINCHA"] => "Plag HaMincha",
    ZmanNames["SUNSET"] => "Sunset",
    ZmanNames["TZEIS"] => "Tzeis",
    ZmanNames["TZEIS_72"] => "Tzeis 72"
};

typedef ZmanTime as {
    "name" as Symbol,
    "time" as Time.Moment
};
