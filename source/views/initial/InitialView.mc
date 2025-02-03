import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

//* This is the main view of the application.
class InitialView extends WatchUi.View {
    var subtitleLabel;
    var promptLabel;

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
        // Check if zmanim are already stored and render the view accordingly
        var remoteZmanData = Storage.getValue("RemoteZmanData") as Lang.Dictionary?;

        if (remoteZmanData != null) {
            Sys.println(remoteZmanData);
            //* Zmanim are stored in memory
            subtitleLabel.setText("At a glance...");

            //! rest of the fetched zmanim view
            //* maybe add "hold DOWN button for more" for showing all zmanim menu (instead of menu button, since we use that for main menu in all views)
        } else {
            //* Zmanim are not stored in memory.

            // Determine status of Zmanim request and render the view accordingly
            //* This should never be "completed" and have reached this point, since `remoteZmanData` is also populated when request is marked "completed"
            var zmanimRequestStatus = Storage.getValue("ZmanimRequestStatus");

            // Set a default state if null
            //* Since switch statement can't handle null value for some reason
            if (zmanimRequestStatus == null) {
                zmanimRequestStatus = "initial";
            }

            // Debug: Print the current status of zmanim API request
            Sys.println("[onUpdate] Current status of zmanim request: " + zmanimRequestStatus.toUpper());

            // Determine the message based on the request status
            switch (zmanimRequestStatus) {
                case "initial":
                    subtitleLabel.setText("Welcome!");
                    promptLabel.setText("Press the Start button\nto fetch zmanim.");
                    break;
                case "pending":
                    subtitleLabel.setText("Fetching");
                    promptLabel.setText("Please wait...");
                    break;
                case "error":
                    subtitleLabel.setText("Error!");
                    // TODO: Display a friendly error message
                    promptLabel.setText("Failed to fetch zmanim.\nTry again later.");
                    break;
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
