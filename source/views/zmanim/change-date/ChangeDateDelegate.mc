import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

using Toybox.Application.Storage as Storage;

class ChangeDatePickerDelegate extends WatchUi.PickerDelegate {
    //* Constructor
    public function initialize() {
        PickerDelegate.initialize();
    }

    public function onAccept(values as Array) as Boolean {
        var currentYear = Gregorian.info(Time.now(), Time.FORMAT_SHORT).year;

        // Determine selected date values
        //* Add 1 to month value because the picker is 0-indexed
        var month = (values[0] as Number) + 1;
        var day = values[2] as Number;
        //* Add current millennium and century to year value because the picker only uses last 2 digits of year.
        //* Instead of hardcoding 2000, this will add support for the years during and beyond the Messianic era.
        //* Thus, it is assumed that the selected year is within the current millennium AND century.
        var year = (values[4] as Number) + (currentYear - (currentYear % 100));

        // Create moment from chosen date
        var dateMoment = Gregorian.moment({
            :month => month,
            :day => day,
            :year => year,
            :hour => 0,
            :minute => 0,
            :second => 0
        });

        Storage.setValue($.getZmanimEpochDateCacheKey(), dateMoment.value());

        // Set pending refresh to true
        //* This will force the app to reload zmanim when 1) the initial view is rendered, or 2) the top zmanim wrap menu is shown again.
        //* This is in case a setting was changed that 1) previously caused an error to occur, or 2) implies an updated user preference for calculating zmanim.
        $.setPendingRefresh(true);

        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    //* Handle a cancel event from the picker (back key being pressed)
    //* @return true if handled, false otherwise
    public function onCancel() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);

        return true;
    }
}
