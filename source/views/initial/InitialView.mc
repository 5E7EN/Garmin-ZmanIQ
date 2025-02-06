import Toybox.Graphics;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

//* This is the main view of the application.
class InitialView extends Ui.View {
    private var _refreshZmanim as (Method() as Void);
    private var subtitleLabel;
    private var promptLabel;

    //* Constructor
    public function initialize(refreshZmanim as (Method() as Void)) {
        View.initialize();

        _refreshZmanim = refreshZmanim;
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
        var zmanimCacheKey = $.getZmanimCacheKey();
        var zmanimStatusCacheKey = $.getZmanimStatusCacheKey();

        // Check if zmanim are already stored and render the view accordingly
        var zmanimRequestStatus = Storage.getValue(zmanimStatusCacheKey);
        var remoteZmanData = Storage.getValue(zmanimCacheKey) as ZmanimApiResponse?;

        if (zmanimRequestStatus != null && zmanimRequestStatus.equals("completed") && remoteZmanData != null) {
            //* Zmanim are stored in memory

            // Ensure that zmanim are not stale
            var isZmanimStale = $.checkIfZmanimStale(remoteZmanData);
            if (isZmanimStale) {
                $.log("[onUpdate] Zmanim are stale. Refreshing...");

                // Refresh zmanim via method passed from delegate
                //* This will set the zmanim request status to "pending"
                _refreshZmanim.invoke();

                // Refresh the UI for the pending state
                WatchUi.requestUpdate();

                return;
            }

            $.log("[onUpdate] Cached zmanim are up-to-date!");
            $.log(remoteZmanData);

            subtitleLabel.setText(Ui.loadResource(Rez.Strings.AtAGlance));
            promptLabel.setText("");

            //! rest of the fetched zmanim view
            //* maybe add "hold DOWN button for more" for showing all zmanim menu (instead of menu button, since we use that for main menu in all views)
        } else {
            //* Zmanim are not stored in memory or request status is not "completed".

            // Set a default state if null
            //* Since switch statement can't handle null value for some reason
            if (zmanimRequestStatus == null) {
                zmanimRequestStatus = "initial";
            }

            // Debug: Print the current status of zmanim API request
            $.log("[onUpdate] Current status of zmanim request: " + zmanimRequestStatus.toUpper());

            // Render display message based on the status of the zmanim request
            switch (zmanimRequestStatus) {
                case "initial":
                    // //* This should only be reached the first time the app is opened, since after that zmanim will auto-refresh if stale. <- COMING SOON
                    subtitleLabel.setText(Ui.loadResource(Rez.Strings.InitialWelcome));
                    promptLabel.setText(Ui.loadResource(Rez.Strings.InitialFetchPrompt));
                    break;
                case "pending":
                    subtitleLabel.setText(Ui.loadResource(Rez.Strings.Fetching));
                    promptLabel.setText(Ui.loadResource(Rez.Strings.PleaseWait));
                    break;
                case "error":
                    subtitleLabel.setText(Ui.loadResource(Rez.Strings.Error));
                    // TODO: Display a friendly error message via new Storage key ZmanimRequestErrorMessage
                    promptLabel.setText(Ui.loadResource(Rez.Strings.FailedToFetch));
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
