import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

using Toybox.Application.Properties as Properties;

//* This is the menu input delegate/handler for the main menu of the application
class ChangeTimeBeforeDelegate extends WatchUi.PickerDelegate {
    //* Constructor
    public function initialize() {
        PickerDelegate.initialize();
    }

    public function onAccept(values as Array) as Boolean {
        var timeBefore = values[0];

        Properties.setValue("remindBeforeTime", timeBefore);

        //* See comment in `RemindersMenuDelegate.onBack()`.
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
