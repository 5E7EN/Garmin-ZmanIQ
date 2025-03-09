import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.Application.Storage as Storage;

class SpecificZmanDelegate extends WatchUi.Menu2InputDelegate {
    //* The zman name for the current view
    private var mZmanName as String;
    //* Flag to indicate if a zman preference was updated
    private var mPrefUpdated as Boolean = false;

    //* Constructor
    public function initialize(zmanName as String) {
        Menu2InputDelegate.initialize();

        mZmanName = zmanName;
    }

    //* Handle an item being selected
    //* @param item The selected menu item
    public function onSelect(item as MenuItem) as Void {
        mPrefUpdated = true;

        // Get the ID of the selected item
        var id = item.getId();

        if (id == :toggleReminder) {
            //* Toggle the reminder preference

            var reminderEnabledZmanim = Storage.getValue($.getReminderEnabledZmanimCacheKey()) as Array<String>?;

            // If the reminders list is null, create it
            if (reminderEnabledZmanim == null) {
                Storage.setValue($.getReminderEnabledZmanimCacheKey(), []);
                reminderEnabledZmanim = Storage.getValue($.getReminderEnabledZmanimCacheKey()) as Array<String>;
            }

            // Determine if reminder is enabled for the current zman
            var isReminderEnabled = reminderEnabledZmanim.indexOf(mZmanName) != -1;

            // If so, remove it from the list to disable
            if (isReminderEnabled == true) {
                reminderEnabledZmanim.remove(mZmanName);
            } else {
                // Otherwise, add it to the list
                reminderEnabledZmanim.add(mZmanName);
            }

            // Set the updated list back to storage
            Storage.setValue($.getReminderEnabledZmanimCacheKey(), reminderEnabledZmanim);
        }
    }

    //* Handle the back key being pressed
    public function onBack() as Void {
        // Pop current view
        WatchUi.popView(WatchUi.SLIDE_DOWN);

        // Check if a zman pref was updated
        if (mPrefUpdated == true) {
            // Reload zmanim
            //* This will ensure that any changes made in the specific zman menu are reflected in the main zmanim menu.
            //* e.g. schedule reminder based on new zman preference
            // TODO: Fix this not going back to focus the selected item
            $.switchToZmanimMenu(true, mZmanName);

            //* Explanation:
            //* Similar to the goBack() function in ZmanimBottomDelegate, but since going back from the "specific zman" menu
            //* doesn't go back to that view/delegate, we need to handle the force refreshing here instead.
        }
    }
}
