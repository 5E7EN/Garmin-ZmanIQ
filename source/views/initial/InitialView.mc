import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

//* This is the main view of the application.
class InitialView extends Ui.View {
    private var subtitleLabel;
    private var promptLabel;

    //* Constructor
    public function initialize() {
        View.initialize();

        subtitleLabel = null;
        promptLabel = null;
    }

    //* Load resources here
    //* @param dc Device Context
    public function onLayout(dc as Dc) {
        setLayout($.Rez.Layouts.MainLayout(dc));

        subtitleLabel = View.findDrawableById("subtitle");
        promptLabel = View.findDrawableById("prompt");
    }

    //* Called when this View is brought to the foreground. Restore
    //* the state of this View and prepare it to be shown. This includes
    //* loading resources into memory.
    public function onShow() as Void {}

    //* Update the view
    //* @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        var location = $.getLocation();
        var zmanimErrorMessage = Storage.getValue($.getZmanimErrorMessageCacheKey());

        // Check if location is available
        if (location != null && zmanimErrorMessage == null) {
            //* Location is available from the chosen source and no errors have been reported.

            // Switch to zmanim view/menu
            $.switchToZmanimMenu(false);
        } else {
            //* Location is null based on source setting or a calculation error has occured.

            // If an error message is set, display it
            // Otherwise, display the welcome message
            if (zmanimErrorMessage != null) {
                // Display error message
                subtitleLabel.setText(Ui.loadResource(Rez.Strings.Error));
                promptLabel.setText(zmanimErrorMessage);
            } else {
                // Display welcome message
                subtitleLabel.setText(Ui.loadResource(Rez.Strings.InitialWelcome));
                promptLabel.setText(Ui.loadResource(Rez.Strings.InitialFetchPrompt));
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
