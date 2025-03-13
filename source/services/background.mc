import Toybox.System;

(:background)
class BackgroundServiceDelegate extends System.ServiceDelegate {
    (:background_method)
    function initialize() {
        System.ServiceDelegate.initialize();
    }

    (:background_method)
    public function onTemporalEvent() as Void {
        $.log("[onTemporalEvent] Background event triggered");

        // Invoke reminder trigger
        $.onReminderTrigger();
    }
}
