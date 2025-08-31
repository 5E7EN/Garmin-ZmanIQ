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
class ZmanMeta {
    public static const ZmanNames = {
        "ALOS" => "alos",
        "MISHEYAKIR" => "misheyakir",
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

    public static const ZmanimFriendlyNames = {
        self.ZmanNames["ALOS"] => "Alos 16.1°",
        self.ZmanNames["MISHEYAKIR"] => "Earliest Tallis",
        self.ZmanNames["SUNRISE"] => "Sunrise",
        self.ZmanNames["SOF_ZMAN_SHEMA"] => "Sof Zman Shema",
        self.ZmanNames["SOF_ZMAN_TEFILLA"] => "Sof Zman Tefilla",
        self.ZmanNames["CHATZOS"] => "Chatzos",
        self.ZmanNames["MINCHA_GEDOLA"] => "Earliest Mincha",
        self.ZmanNames["MINCHA_KETANA"] => "Mincha Ketana",
        self.ZmanNames["PLAG_HAMINCHA"] => "Plag HaMincha",
        self.ZmanNames["SUNSET"] => "Sunset",
        self.ZmanNames["TZEIS"] => "Tzeis",
        self.ZmanNames["TZEIS_72"] => "Tzeis 72"
    };
}

typedef ZmanTime as {
    "name" as Symbol,
    "time" as Time.Moment
};
