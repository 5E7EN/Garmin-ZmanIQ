import Toybox.Lang;
import Toybox.Time;
import Toybox.Background;

using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;

function scheduleNextReminder(zmanim as Array<ZmanTime>) {
    // Ensure zmanim aren't empty
    if (zmanim.size() == 0) {
        $.log("[scheduleNextReminder] Zmanim are empty. Cannot schedule reminder.");

        return;
    }

    // Get reminder config
    var remindBeforeTimeMins = Properties.getValue("remindBeforeTime") as Number;
    var remindBeforeTimeSecs = remindBeforeTimeMins * 60;

    // Get next reminder-enabled zman
    var nextReminding = $.getNextRemindingZmanToday(zmanim, remindBeforeTimeSecs, null);
    $.log("[scheduleNextReminder] Next reminding zman: " + (nextReminding != null ? nextReminding[0] : "null"));

    if (nextReminding == null) {
        //* See comment above getNextRemindingZmanToday() decleration for when this will occur.

        $.log("[scheduleNextReminder] No next reminding zman. Not scheduling reminder.");

        return;
    }

    //* No need to ensure the remind before time hasn't yet passed, since $.getNextRemindingZmanToday()
    //* will not return the zman if the remind before time has already occured (due to passing it the `remindBeforeTimeSecs`).

    // Get zman name and time
    var zmanName = nextReminding[0] as String;
    var zmanTime = nextReminding[1] as Time.Moment;
    var zmanFriendlyName = $.ZmanMeta.ZmanimFriendlyNames[zmanName];

    // Set pending zman reminder data to storage (for service delegate on trigger)
    var storageInfo = [zmanFriendlyName, zmanTime.value()];
    Storage.setValue($.getPendingZmanReminderInfoCacheKey(), storageInfo);

    // Register for temporal event
    var remindTimeMoment = zmanTime.subtract(new Time.Duration(remindBeforeTimeSecs));
    Background.registerForTemporalEvent(remindTimeMoment);

    // Log
    $.log("[scheduleNextReminder] - Scheduled '" + zmanName + "' reminder at: " + $.parseMomentToTimeString(remindTimeMoment));
}

function clearPendingReminder() {
    // Cancel any pending temporal event
    Background.deleteTemporalEvent();
    $.log("[clearPendingReminder] Cancelled any existing pending reminder.");

    // Clear pending zman reminder data from storage
    Storage.deleteValue($.getPendingZmanReminderInfoCacheKey());
}

(:background)
function onReminderTrigger() {
    $.log("[onReminderTrigger] Zman reminder triggered!");

    // Get pending zman reminder data from storage
    var pendingZmanReminderInfo = Storage.getValue($.getPendingZmanReminderInfoCacheKey());

    if (pendingZmanReminderInfo == null) {
        //* This should never happen. Just in case.

        $.log("[onReminderTrigger] No pending zman reminder data found in storage. Exiting.");
    } else {
        // Get zman name and time
        var zmanFriendlyName = pendingZmanReminderInfo[0] as String;
        var zmanTime = pendingZmanReminderInfo[1] as Number;
        var zmanTimeMoment = new Time.Moment(zmanTime);
        var zmanTimeString = $.parseMomentToTimeString(zmanTimeMoment);
        // Get remind before time
        var remindBeforeTimeMins = Properties.getValue("remindBeforeTime") as Number;

        // Clear pending zman reminder data from storage
        Storage.deleteValue($.getPendingZmanReminderInfoCacheKey());

        // Trigger app launch notification
        Background.requestApplicationWake(zmanFriendlyName + "\nis in " + remindBeforeTimeMins.toString() + " minutes! " + "\n(" + zmanTimeString + ")");
    }

    // Exit
    Background.exit(null);
}
