import Toybox.Lang;

var ZmanimFriendlyNames = {
    "chatzotNight" => "Chatzos Night",
    "alotHaShachar" => "Alos HaShachar",
    "misheyakir" => "Misheyakir",
    "misheyakirMachmir" => "Misheyakir Machmir",
    "dawn" => "Dawn",
    "sunrise" => "Sunrise",
    "sofZmanShmaMGA19Point8" => "Sof Zman Shma MGA 19.8°",
    "sofZmanShmaMGA16Point1" => "Sof Zman Shma MGA 16.1°",
    "sofZmanShmaMGA" => "Sof Zman Shma MGA",
    "sofZmanShma" => "Sof Zman Shma",
    "sofZmanTfillaMGA19Point8" => "Sof Zman Tfilla MGA 19.8°",
    "sofZmanTfillaMGA16Point1" => "Sof Zman Tfilla MGA 16.1°",
    "sofZmanTfillaMGA" => "Sof Zman Tfilla MGA",
    "sofZmanTfilla" => "Sof Zman Tfilla",
    "chatzot" => "Chatzot",
    "minchaGedola" => "Mincha Gedola",
    "minchaGedolaMGA" => "Mincha Gedola MGA",
    "minchaKetana" => "Mincha Ketana",
    "minchaKetanaMGA" => "Mincha Ketana MGA",
    "plagHaMincha" => "Plag HaMincha",
    "sunset" => "Sunset",
    "beinHaShmashos" => "Bein HaShmashos",
    "dusk" => "Dusk",
    "tzeit7083deg" => "Tzeit 70.83°",
    "tzeit85deg" => "Tzeit 85°",
    "tzeit42min" => "Tzeit 42 min",
    "tzeit50min" => "Tzeit 50 min",
    "tzeit72min" => "Tzeit 72 min"
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
