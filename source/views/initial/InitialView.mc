import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;

//* This is the main view of the application.
class InitialView extends Ui.View {
    private var isFirstShowing = true;
    private var subtitleLabel;
    private var underSubtitleLabel;
    private var promptLabel;

    //* Constructor
    public function initialize() {
        View.initialize();

        subtitleLabel = null;
        underSubtitleLabel = null;
        promptLabel = null;
    }

    //* Load resources here
    //* @param dc Device Context
    public function onLayout(dc as Dc) {
        setLayout($.Rez.Layouts.MainLayout(dc));

        subtitleLabel = View.findDrawableById("subtitle");
        underSubtitleLabel = View.findDrawableById("under_subtitle");
        promptLabel = View.findDrawableById("prompt");
    }

    //* Called when this View is brought to the foreground. Restore
    //* the state of this View and prepare it to be shown. This includes
    //* loading resources into memory.
    public function onShow() as Void {
        // If this is the first time showing this view and GPS status has leftover "pending" state, clear it.
        //* This could will occur if the user quit the app while waiting for GPS.
        if (isFirstShowing == true) {
            var gpsStatus = Storage.getValue($.getGpsStatusCacheKey());
            if (gpsStatus != null && gpsStatus.equals("pending")) {
                Storage.deleteValue($.getGpsStatusCacheKey());
                $.log("[onShow] GPS status was pending and we're loading for first time, clearing status.");
            }

            isFirstShowing = false;
        }
    }

    //* Update the view
    //* @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        // TODO: Figure out another way to determine if location is ready. This is otherwise a redundant retrieval.

        // If forced refresh is pending, clear any error message and continue
        //* This will be true, for example, after exiting the main menu with the assumption that changes have been made.
        var isPendingRetry = $.getPendingRefresh();
        if (isPendingRetry == true) {
            $.log("[onUpdate] Forced retry is pending. Clearing error message and continuing.");
            Storage.setValue($.getZmanimErrorMessageCacheKey(), null);
            $.setPendingRefresh(false);
        }

        var gpsStatus = Storage.getValue($.getGpsStatusCacheKey());
        var isGpsStatusPending = gpsStatus != null && gpsStatus.equals("pending");
        var isLocationAvailable = $.getLocation() != null;
        var zmanimErrorMessage = Storage.getValue($.getZmanimErrorMessageCacheKey());

        // Check if location is available
        if (isLocationAvailable == true && zmanimErrorMessage == null && isGpsStatusPending != true) {
            //* Location is available from the chosen source and no errors have been set, or forced retry is pending.

            // Switch to zmanim view/menu
            $.switchToZmanimMenu(false);
        } else {
            //* Location is null based on source setting, a calculation error has occured, or GPS status is "pending".
            //* Existing error messages are cleared before calculating zmanim, so this __shouldn't__ be reached by mistake.

            // Clear existing "SELECT to try again" display text
            //* Since not all errors can be resolved by retrying.
            underSubtitleLabel.setText("");

            // If an error message is set, display it
            // Otherwise, display the welcome message
            if (zmanimErrorMessage != null) {
                //* An error has occured.

                // Display error message
                subtitleLabel.setText(Ui.loadResource(Rez.Strings.Error));
                underSubtitleLabel.setText(Ui.loadResource(Rez.Strings.SelectToTryAgain));
                promptLabel.setText(zmanimErrorMessage); //* This will likely be `Rez.Strings.InternalError`
            } else {
                //* Not a zmanim error, but no location was available.

                var locationSource = Properties.getValue("locationSource");

                // If GPS is the source, show initial welcome or fetch pending message
                if (locationSource.equals("GPS")) {
                    if (gpsStatus == null) {
                        //* GPS status is null; user hasn't yet retrieved location.

                        // Display welcome message
                        subtitleLabel.setText(Ui.loadResource(Rez.Strings.InitialWelcome));
                        promptLabel.setText(Ui.loadResource(Rez.Strings.InitialGpsPrompt));
                    } else if (gpsStatus.equals("pending")) {
                        //* GPS status is pending; user has requested location and results have yet to come in.

                        // Display locating GPS message
                        subtitleLabel.setText(Ui.loadResource(Rez.Strings.Locating));
                        promptLabel.setText(Ui.loadResource(Rez.Strings.MoveOutside));
                    } else if (gpsStatus.equals("no_signal")) {
                        //* GPS status is no signal; could not locate user.

                        // Display no GPS signal message
                        subtitleLabel.setText(Ui.loadResource(Rez.Strings.NoGpsSignal));
                        underSubtitleLabel.setText(Ui.loadResource(Rez.Strings.SelectToTryAgain));
                        promptLabel.setText(Ui.loadResource(Rez.Strings.MoveToBetterArea));
                    } else if (gpsStatus.equals("timeout")) {
                        //* GPS status is timeout; could not get a signal in time. Prompt to try again.

                        // Display GPS location message indicating timeout
                        subtitleLabel.setText(Ui.loadResource(Rez.Strings.GpsTimeout));
                        underSubtitleLabel.setText(Ui.loadResource(Rez.Strings.SelectToTryAgain));
                        promptLabel.setText(Ui.loadResource(Rez.Strings.MoveToBetterArea));
                    }

                    //* There should be no other GPS status values.
                    //* onPosition handler will call Ui.requestUpdate() upon location.
                } else {
                    //* Location could not be determined (and location source is not GPS).

                    // Display message
                    subtitleLabel.setText(Ui.loadResource(Rez.Strings.LocationUnavailable));
                    underSubtitleLabel.setText(Ui.loadResource(Rez.Strings.SelectToTryAgain));
                    promptLabel.setText(Ui.loadResource(Rez.Strings.ChooseLocationSource));
                }
            }
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    //* Called when this View is removed from the screen. Save the
    //* state of this View here. This includes freeing resources from
    //* memory.
    public function onHide() as Void {}
}
