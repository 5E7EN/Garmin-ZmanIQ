import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System as Sys;
using Toybox.Application.Storage as Storage;

class ZmanIQ extends Application.AppBase {
    //* Constructor
    public function initialize() {
        AppBase.initialize();
    }

    //* Handle app startup
    //* @param state Startup arguments
    public function onStart(state as Dictionary?) as Void {}

    //* Handle app shutdown
    //* @param state Shutdown arguments
    public function onStop(state as Dictionary?) as Void {
        //* Note: When using simulator, if the app is crashed then any Properties set will not be saved
        //* See here: https://forums.garmin.com/developer/connect-iq/f/discussion/1191/persistent-storage-app-setproperty---where-is-data-stored/6787#6787
    }

    //* Return the initial view for the app
    //* @return Array [View, Delegate]
    public function getInitialView() as Array<Views or InputDelegates>? {
        var view = new $.InitialView();
        var delegate = new $.InitialDelegate();

        return [view, delegate] as Array<Views or InputDelegates>;
    }
}
