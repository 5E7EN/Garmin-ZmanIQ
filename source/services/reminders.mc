import Toybox.Lang;

using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;

function scheduleNextReminder(zmanim as Array<ZmanTime>) {
    // Ensure zmanim aren't empty
    if (zmanim.size() == 0) {
        $.log("[scheduleNextReminder] Zmanim are empty. Cannot schedule reminder.");

        return;
    }

    // TODO: Only schedule if zman is for today
    // TODO: If zman already passed, do nothing
    // TODO: If happening in less time than the configured "remindBeforeTime", do nothing
    // TODO: If zman key doesn't existing in "$.getReminderEnabledZmanimCacheKey()", schedule next zman instead
    // TODO: Register for temporal event using a Moment object, not Duration (to bypass 5 minute restriction)
}
