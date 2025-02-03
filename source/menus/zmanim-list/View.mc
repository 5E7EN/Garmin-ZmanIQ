import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//* Create the all zmanim menu
function pushZmanimListView() as Void {
    // TODO: Maybe use menu item with subtitle for showing zmanim (and wrapping menu for category division)
    // TODO: This allows for the user to see a preview of the time without having to click into it
    var customMenu = new WatchUi.CustomMenu(35, Graphics.COLOR_WHITE, {
        :focusItemHeight => 45,
        :foreground => new $.Rez.Drawables.MenuForeground(),
        :title => new $.ZmanimListMenuTitle(),
        :footer => new $.ZmanimListMenuFooter()
    });

    // TODO: Provide different text to show for when an item is selected
    customMenu.addItem(new $.CustomItem(:item1, "Hello World"));
    customMenu.addItem(new $.CustomItem(:item2, "Foo"));
    customMenu.addItem(new $.CustomItem(:item3, "Bar"));
    customMenu.addItem(new $.CustomItem(:item4, "Run"));
    customMenu.addItem(new $.CustomItem(:item5, "Walk"));
    customMenu.addItem(new $.CustomItem(:item6, "Eat"));
    customMenu.addItem(new $.CustomItem(:item7, "Climb"));

    WatchUi.pushView(customMenu, new $.ZmanimListDelegate(), WatchUi.SLIDE_UP);
}

// TODO: Change the name of this and move it somewhere else since it's really generic (other than the title, which should use @strings)
class ZmanimListMenuTitle extends WatchUi.Drawable {
    //* Constructor
    public function initialize() {
        Drawable.initialize({});
    }

    //* Draw the application icon and main menu title
    //* @param dc Device Context
    public function draw(dc as Dc) as Void {
        var text = "Zmanim List";

        // Calculate X and Y positions to center the text
        // TODO: This was adapted from an example. Learn why it's necessary to do this if we set the justification to center below...
        var labelX = dc.getWidth() / 2;
        var labelY = dc.getHeight() / 2;

        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw the text centered on screen
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            labelX,
            labelY,
            Graphics.FONT_MEDIUM,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}

// TODO: Change the name of this and move it somewhere else since it's really generic
class ZmanimListMenuFooter extends WatchUi.Drawable {
    //* Constructor
    public function initialize() {
        Drawable.initialize({});
    }

    //* Draw bottom half of the last dividing line below the final item
    //* @param dc Device context
    public function draw(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.drawLine(0, 0, dc.getWidth(), 0);
    }
}
