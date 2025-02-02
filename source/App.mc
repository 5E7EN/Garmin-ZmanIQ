import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class ZmanIQ extends Application.AppBase {
    //! Constructor
    public function initialize() {
        AppBase.initialize();
    }

    //! Handle app startup
    //! @param state Startup arguments
    public function onStart(state as Dictionary?) as Void {}

    //! Handle app shutdown
    //! @param state Shutdown arguments
    public function onStop(state as Dictionary?) as Void {}

    //! Return the initial view for the app
    //! @return Array [View, Delegate]
    public function getInitialView() as Array<Views or InputDelegates>? {
        return [new $.InitialView(), new $.InitialDelegate()] as Array<Views or InputDelegates>;
    }
}
