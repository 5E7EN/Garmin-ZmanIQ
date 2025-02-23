import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;
using Toybox.Application.Properties as Properties;

//* This is the main view of the application.
class InitialView extends Ui.View {
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
    public function onShow() as Void {}

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

        var isLocationAvailable = $.getLocation() != null;
        var zmanimErrorMessage = Storage.getValue($.getZmanimErrorMessageCacheKey());

        // Check if location is available
        if (isLocationAvailable && zmanimErrorMessage == null) {
            //* Location is available from the chosen source and no errors have been set, or forced retry is pending.

            // Switch to zmanim view/menu
            $.switchToZmanimMenu(false);
        } else {
            //* Location is null based on source setting or a calculation error has occured.
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
                    var gpsStatus = Storage.getValue($.getGpsStatusCacheKey());

                    if (gpsStatus == null) {
                        //* GPS status is null, meaning the user hasn't yet retrieved location.

                        // Display welcome message
                        subtitleLabel.setText(Ui.loadResource(Rez.Strings.InitialWelcome));
                        promptLabel.setText(Ui.loadResource(Rez.Strings.InitialGpsPrompt));
                    } else if (gpsStatus.equals("pending")) {
                        // Display locating GPS message
                        subtitleLabel.setText(Ui.loadResource(Rez.Strings.Locating));
                        promptLabel.setText(Ui.loadResource(Rez.Strings.MoveOutside));
                    }

                    //* There should be no other GPS status values. onPosition handler will call Ui.requestUpdate() upon location.
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
