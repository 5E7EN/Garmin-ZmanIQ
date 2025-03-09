import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

using Toybox.Position;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;
using Toybox.Timer;
using Toybox.Attention;

//* This delegate is for the main page of our application that pushes the menu
//* when the onMenu() behavior is received.
class InitialDelegate extends WatchUi.BehaviorDelegate {
    //* Constructor
    public function initialize() {
        BehaviorDelegate.initialize();
    }

    //* Handle the menu button click event
    //* @return true if handled, false otherwise
    public function onMenu() as Boolean {
        // Render the main menu found in menus/main/View.mc
        $.pushMainMenuView();

        return true;
    }

    //* Handle the select/start/enter button click event
    //* @return true if handled, false otherwise
    public function onSelect() as Boolean {
        $.log("[onSelect] SELECT button pressed");

        // Handle "try again" attempt following error
        var zmanimErrorMessage = Storage.getValue($.getZmanimErrorMessageCacheKey());
        if (zmanimErrorMessage != null) {
            //* User was likely presented with an error message and is trying again.

            // Clear the error message
            Storage.deleteValue($.getZmanimErrorMessageCacheKey());

            // Try again by switching to zmanim view/menu
            $.switchToZmanimMenu(false, null);

            return true;
        }

        // Handle GPS request
        var locationSource = Properties.getValue("locationSource");
        if (locationSource.equals("GPS")) {
            // Ensure request is not already in progress
            var gpsStatus = Storage.getValue($.getGpsStatusCacheKey());
            if (gpsStatus != null && gpsStatus.equals("pending")) {
                $.log("[onSelect] GPS request already in progress...");
                return true;
            }

            // Request GPS location
            $.log("[onSelect] Requesting GPS location...");
            Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onPosition));

            // Set GPS status to pending
            Storage.setValue($.getGpsStatusCacheKey(), "pending");

            // Set timeout timer to check on GPS status after 2 mins
            var gpsTimer = new Timer.Timer();
            gpsTimer.start(method(:onGpsTimeout), 120000, false);
        }

        // Refresh the UI for the GPS pending state
        //* The main view will handle the new request state and render accordingly
        WatchUi.requestUpdate();

        return true;
    }

    public function onPosition(info as Position.Info) as Void {
        $.log("[onPosition] GPS coordinates retrieved.");

        // Ensure we got reliable results
        var quality = info.accuracy;
        if (quality == Position.QUALITY_NOT_AVAILABLE || quality == Position.QUALITY_LAST_KNOWN) {
            //* Coordinates are not up-to-date/available.
            $.log("[onPosition] Fresh GPS coordinates are not available.");

            // Set GPS status to "no_signal"
            Storage.setValue($.getGpsStatusCacheKey(), "no_signal");

            // Refresh the UI for the GPS no signal state
            //* The main view will handle the new request state and render accordingly
            WatchUi.requestUpdate();
        } else {
            //* Fresh GPS coordinates are available!

            $.log("[onPosition] Retrieved fresh coordinates!");

            // Set GPS status to completed
            Storage.setValue($.getGpsStatusCacheKey(), "completed");

            // Store the location
            $.setGpsLocation(info);

            // Vibrate to indicate success, if supported
            if (Attention has :vibrate) {
                Attention.vibrate([new Attention.VibeProfile(50, 500)]);
            }

            // Switch to the zmanim menu
            $.switchToZmanimMenu(false, null);
        }
    }

    public function onGpsTimeout() as Void {
        var gpsStatus = Storage.getValue($.getGpsStatusCacheKey());

        // If the GPS request is still pending, enforce timeout
        if (gpsStatus != null && gpsStatus.equals("pending")) {
            $.log("[onGpsTimeout] GPS request timed out.");

            // Set GPS status to "timeout"
            Storage.setValue($.getGpsStatusCacheKey(), "timeout");

            // Refresh the UI for the GPS timeout state
            //* The main view will handle the new request state and render accordingly
            WatchUi.requestUpdate();
        }
    }
}
