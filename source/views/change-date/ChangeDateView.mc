import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

using Toybox.WatchUi as Ui;
using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;

//* Create the all zmanim menu
function pushChangeDatePicker() as Void {
    var months =
        [
            Rez.Strings.Month01,
            Rez.Strings.Month02,
            Rez.Strings.Month03,
            Rez.Strings.Month04,
            Rez.Strings.Month05,
            Rez.Strings.Month06,
            Rez.Strings.Month07,
            Rez.Strings.Month08,
            Rez.Strings.Month09,
            Rez.Strings.Month10,
            Rez.Strings.Month11,
            Rez.Strings.Month12
        ] as Array<Symbol>;

    var separator = new Ui.Text({
        :text => "/",
        :locX => Ui.LAYOUT_HALIGN_CENTER,
        :locY => Ui.LAYOUT_VALIGN_CENTER,
        :color => Graphics.COLOR_WHITE
    });

    // Determine existing stored date
    var gregorianToday = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var existingDateEpoch = Storage.getValue($.getZmanimEpochDateCacheKey()) as Number;
    var gregorianExistingDate = Gregorian.info(new Time.Moment(existingDateEpoch), Time.FORMAT_SHORT);

    // Generate a new Picker
    var YEARS_OFFSET = 3; // Amount of years in the future and past from the current year to show in picker
    var startYears = (gregorianToday.year - YEARS_OFFSET) % 100;
    var endYears = (gregorianToday.year + YEARS_OFFSET) % 100;
    var picker = new Ui.Picker({
        :title => new Ui.Text({
            :text => Rez.Strings.ChangeDatePickerTitle,
            :locX => Ui.LAYOUT_HALIGN_CENTER,
            :locY => Ui.LAYOUT_VALIGN_BOTTOM,
            :color => Graphics.COLOR_WHITE
        }),
        :pattern => [
            // Allow selection of months
            new $.WordFactory(months, {}),
            separator,
            // Allow selection of days 1-31
            // TODO: Depending on month, should limit to 28/29/30 days
            new $.NumberFactory(1, 31, 1, {
                :font => Graphics.FONT_NUMBER_MEDIUM
            }),
            separator,
            // Allow selection of `YEARS_OFFSET` years from today into the past and future
            //* We then convert from 4-digit year to 2-digit year (e.g. 2025 -> 25)
            new $.NumberFactory(startYears, endYears, 1, {
                :font => Graphics.FONT_NUMBER_MEDIUM
            })
        ],
        // Set default values to currently saved date
        //* Converts month/day for 0-indexed values (as generated by NumberFactory)
        //* For year default, we determine the index of the currently saved year in the expected range of years
        :defaults => [gregorianExistingDate.month - 1, null, gregorianExistingDate.day - 1, null, (gregorianExistingDate.year % 100) - startYears]
        // TODO: Add custom checkmark icon (:confirm)
    });

    Ui.pushView(picker, new $.ChangeDatePickerDelegate(), Ui.SLIDE_LEFT);
}
