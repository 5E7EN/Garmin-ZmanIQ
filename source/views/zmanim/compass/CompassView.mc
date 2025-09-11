import Toybox.WatchUi;

function pushCompassView(locationInfo as LocationInfo) as Void {
    var view = new $.CompassView(locationInfo);
    var delegate = new $.CompassDelegate();
    WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
}
