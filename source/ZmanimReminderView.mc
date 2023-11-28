using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Time;
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
        // Update the time label text with the current time
        //var currentTime = Time.now().value();
        // var timeString = Lang.formatTime(currentTime, Lang.TIME_FORMAT_12_HOUR);
        timeLabel.setText("Making req...");
        Sys.println("Making req...");
        makeRequest();
        timeLabel.setText("Made req!");
        Sys.println("Made req!");

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {}

    // set up the response callback function
    // function onReceive(responseCode, data) {
    //     if (responseCode == 200) {
    //         System.println("Request Successful"); // print success
    //     } else {
    //         System.println("Response: " + responseCode); // print response code
    //     }
    // }

    // Callback to handle receiving a response
    function handleResponse(responseCode as Lang.Number, data as Lang.Dictionary or Lang.String or PersistedContent.Iterator or Null) as Void {
        Sys.println("Response code: " + responseCode);

        // If we got data back then we were successful. Otherwise
        // pass the error onto the delegate
        if (data != null) {
            Sys.println("Success in handleResponse");
            Sys.println("Got data with size = " + data.length);
        } else {
            Sys.println("Error in handleResponse");
            Sys.println("data = " + data);
        }
    }

    function makeRequest() {
        // Make HTTPS POST request to request the access token
        // Comm.makeWebRequest(
        //     // URL
        //     "https://www.google.com",
        //     // Parameters
        //     {
        //         "asd" => "xdd"
        //     },
        //     // Options to the request
        //     {
        //         :method => Comm.HTTP_REQUEST_METHOD_GET
        //     },
        //     // Callback to handle response
        //     method(:handleResponse)
        // );

        Comm.makeWebRequest(
            // URL for the authorization URL
            "https://gmail.com",
            // Parameters
            {
                "xd" => "xdd"
            },
            // Response type
            {
                :method => Comm.HTTP_REQUEST_METHOD_GET
            },
            // Value to look for
            method(:handleResponse)
        );
    }
}
