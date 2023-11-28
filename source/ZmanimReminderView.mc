using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.PersistedContent;

class ZmanimReminderView extends WatchUi.View {
    var timeLabel;

    function initialize() {
        View.initialize();

        timeLabel = null;
    }

    // Load your resources here
    function onLayout(dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));

        timeLabel = View.findDrawableById("id_time_label");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        Sys.println("Started!!");
    }

    // Update the view
    function onUpdate(dc) as Void {
        // Get current date
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateString = Lang.format("$1$-$2$-$3$", [today.year, today.month, today.day]);

        timeLabel.setText("Making req...");
        Sys.println("Making req...");
        makeZmanimRequest(dateString);
        timeLabel.setText("Made req!");
        Sys.println("Made req!");

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {}

    // Callback to handle receiving a response
    function handleZmanimResponse(responseCode as Lang.Number, data as Lang.Dictionary or Lang.String or PersistedContent.Iterator or Null) as Void {
        if (responseCode == 200) {
            if (data != null) {
                Sys.println("Got data, Sof Zman Kiras Shema is at: " + data["times"]["sofZmanShma"]);
            } else {
                Sys.println("Request returned no data -> " + data);
            }
        } else {
            System.println("Encountered non-OK response code: " + responseCode);
        }
    }

    function makeZmanimRequest(currentDate) {
        var zmanimUrl = "https://www.hebcal.com/zmanim?cfg=json&sec=1&city=IL-Jerusalem&date=" + currentDate;

        System.println("Fetching Zmanim -> " + zmanimUrl);

        Comm.makeWebRequest(zmanimUrl, {}, { :method => Comm.HTTP_REQUEST_METHOD_GET }, method(:handleZmanimResponse));
    }
}
