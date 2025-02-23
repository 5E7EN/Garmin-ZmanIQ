import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//* This is the sub-menu in the Wrap custom menu
class CustomWrapBottomMenu extends WatchUi.CustomMenu {
    //* Constructor
    //* @param itemHeight The pixel height of menu items rendered by this menu
    //* @param backgroundColor The color for the menu background
    public function initialize(itemHeight as Number, backgroundColor as ColorType) {
        CustomMenu.initialize(itemHeight, backgroundColor, {});
    }

    //* Draw the menu title
    //* @param dc Device Context
    public function drawTitle(dc as Dc) as Void {
        // Calculate the horizontal center of the screen.
        var centerX = dc.getWidth() / 2;

        // Set the drawing color to black and clear the entire title area.
        // This effectively sets the background color of the title area to black.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        // Set the color to dark gray for drawing a separator line.
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);

        // Set the pen width to 3 pixels for drawing the separator line.
        dc.setPenWidth(3);

        // Draw a horizontal line near the bottom of the title area,
        // separating the title from the menu items below.
        dc.drawLine(0, dc.getHeight() - 2, dc.getWidth(), dc.getHeight() - 2);

        // Reset the pen width to 1 pixel for subsequent drawing operations.
        dc.setPenWidth(1);

        // Set the text color to white with a transparent background.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Draw the title text, centered horizontally.
        // Position the text 2/3 down from the top of the title area.
        // Use a medium font and both horizontal and vertical centering.
        // TODO: Change this to use rez string
        dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 3) * 2, Graphics.FONT_MEDIUM, "Show Zmanim", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Set the drawing color to white.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);

        // Draw a small, filled, upward-pointing triangle (arrow) at the top of the title area.
        // This serves as a visual indicator, suggesting a return to a previous menu or screen.
        dc.fillPolygon([[centerX, 10] as Array<Number>, [centerX + 5, 15] as Array<Number>, [centerX - 5, 15] as Array<Number>] as Array<Array<Number> >);
    }
}
