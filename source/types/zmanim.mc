import Toybox.Lang;
import Toybox.Time;

// TODO: Use all of the following times:
// Alos 16.1 ✅
// Sunrise ✅
// Sof Zman Shema GR"A / Sof Zman Shema MG"A ✅
// Sof Zman Tfila GR"A / Sof Zman Tfila MG"A ✅
// Chatzos ✅
// Mincha Gedola ✅
// Mincha Ketana
// Plag Hamincha
// Sunset ✅
// Tzais ✅
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
