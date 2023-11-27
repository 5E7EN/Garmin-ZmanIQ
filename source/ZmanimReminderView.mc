using Toybox.WatchUi;
using Toybox.Application;
using Toybox.Timer;
using Toybox.Lang;


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
    }

    // Update the view
    function onUpdate(dc) as Void {
        // Update the time label text with the current time
        //var currentTime = System.Time.CURRENT_TIME_DEFAULT;
        // var timeString = Lang.formatTime(currentTime, Lang.TIME_FORMAT_12_HOUR);
        timeLabel.setText("Hello World :)");

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
