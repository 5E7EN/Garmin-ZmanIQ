import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;

using Toybox.WatchUi as Ui;
using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;

function pushChangeTimeBeforePicker() as Void {
    var minuteOptions = [1, 3, 5, 15, 30, 45, 60];

    // Determine existing stored time before
    var existingTimeBefore = Properties.getValue("remindBeforeTime") as Number;

    // Produce a factory
    var factory = new $.DictionaryFactory(minuteOptions, minuteOptions, {
        :font => Graphics.FONT_NUMBER_MEDIUM
    });

    // Determine index of existing time before value (for default selection)
    var existingTimeBeforeIndex = factory.indexOfKey(existingTimeBefore);
    if (existingTimeBeforeIndex == -1) {
        //* This should never happen. Just in case.
        existingTimeBeforeIndex = 0;
    }

    // Generate a new Picker
    var picker = new Ui.Picker({
        :title => new Ui.Text({
            :text => Rez.Strings.RemindersMenuTimeBeforePickerTitle,
            :locX => Ui.LAYOUT_HALIGN_CENTER,
            :locY => Ui.LAYOUT_VALIGN_BOTTOM,
            :color => Graphics.COLOR_WHITE,
            :font => Graphics.FONT_TINY
        }),
        :pattern => [
            factory,
            new Ui.Text({
                :text => "min(s)",
                :locX => Ui.LAYOUT_HALIGN_CENTER,
                :locY => Ui.LAYOUT_VALIGN_CENTER,
                :color => Graphics.COLOR_WHITE,
                :font => Graphics.FONT_SMALL
            })
        ],
        // Set default value to currently saved value
        :defaults => [existingTimeBeforeIndex, null]
        // TODO: Add custom checkmark icon (:confirm)
    });

    Ui.pushView(picker, new $.ChangeTimeBeforeDelegate(), Ui.SLIDE_LEFT);
}
