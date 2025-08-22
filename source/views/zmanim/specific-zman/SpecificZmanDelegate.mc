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
        WatchUi.popView(WatchUi.SLIDE_RIGHT);

        // Check if a zman pref was updated
        if (mPrefUpdated == true) {
            // Delete any existing temporal event
            //* This is to ensure that, if the pref is updated to "disabled", a pending reminder doesn't fire if this
            //* specific zman was upcoming next and had been previously scheduled to fire soon.
            //* (If it's next, and the pref was updated to "enabled", no worries - it'll be rescheduled in $.switchToZmanimMenu() below).
            $.clearPendingReminder();

            // Reload zmanim
            //* This will ensure that any changes made in the specific zman menu are reflected in the main zmanim menu.
            //* e.g. Scheduling reminder based on new zman preference
            // TODO: Fix this not going back to focus the selected item - UPDATE 8/18/25, is this fixed?
            $.switchToZmanimMenu(mZmanName);

            //* Explanation:
            //* Similar to the goBack() function in ZmanimBottomDelegate, but since going back from the "specific zman" menu
            //* doesn't go back to that view/delegate, we need to handle the force refreshing here instead.
            //* The "force refresh" is done by invoking $.switchToZmanimMenu().
        }
    }
}
