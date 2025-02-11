import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//* This is the top menu in the Wrap custom menu
class CustomWrapTopMenu extends WatchUi.CustomMenu {
    private var _title as String;

    //* Constructor
    //* @param itemHeight The pixel height of menu items rendered by this menu
    //* @param backgroundColor The color for the menu background
    public function initialize(menuTitle as String, itemHeight as Number, backgroundColor as ColorType) {
        CustomMenu.initialize(itemHeight, backgroundColor, {});

        _title = menuTitle;
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

        // Set the pen width to 3 pixels for the separator line.
        dc.setPenWidth(2);

        // Draw a horizontal line near the bottom of the title area to separate it from the menu items.
        dc.drawLine(0, dc.getHeight() - 2, dc.getWidth(), dc.getHeight() - 2);

        // Reset the pen width to 1 pixel for subsequent drawing operations.
        dc.setPenWidth(1);

        // Set the text color to blue, with a transparent background.
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);

        // Draw the title text centered horizontally and positioned halfway down from the top of the title area.
        // Uses a medium-sized font and both horizontal and vertical centering.
        dc.drawText(centerX, dc.getHeight() / 2, Graphics.FONT_MEDIUM, _title, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER); // centerX is already calculated.
    }

    //* Draw the menu footer
    //* @param dc Device Context
    public function drawFooter(dc as Dc) as Void {
        // Get the total height of the footer area.
        var height = dc.getHeight();
        // Calculate the horizontal center of the footer area.
        var centerX = dc.getWidth() / 2;
        // Get settings icon resource
        var settingsIcon = WatchUi.loadResource($.Rez.Drawables.SettingsIcon);

        // Set the drawing color to white and clear the entire footer area.
        // This sets the background color of the footer to white.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();

        // Set the color to dark gray for drawing a separator line.
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        // Set the pen width to 3 pixels for the separator line.
        dc.setPenWidth(3);
        // Draw a horizontal line near the top of the footer area to separate it from the menu items.
        dc.drawLine(0, 1, dc.getWidth(), 1);
        // Reset the pen width to 1 pixel for subsequent drawing operations.
        dc.setPenWidth(1);
        // Set the drawing color to black, with a transparent background for drawing text or icons.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        // Load the settings icon bitmap from resources.
        var icon = WatchUi.loadResource($.Rez.Drawables.SettingsIcon) as WatchUi.BitmapResource;

        // Get the width and height of the loaded bitmap.
        var iconWidth = icon.getWidth();
        var iconHeight = icon.getHeight();

        // Calculate the x and y coordinates for the top-left corner of the bitmap
        // to center it horizontally and place it 1/3 down from the top of the footer.
        var iconX = centerX - iconWidth / 2;
        var iconY = height / 3 - iconHeight / 2;

        // Draw the settings icon at the calculated centered position.  Re-loads the
        // resource; this is inefficient and the previous load should be used.
        dc.drawBitmap(iconX, iconY, settingsIcon);

        // dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 3) * 2, Graphics.FONT_MEDIUM, "Zmanim", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        // dc.drawText(dc.getWidth() / 2, dc.getHeight() / 3, Graphics.FONT_MEDIUM, "To Sub Menu", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Set the color to black for drawing a downward-pointing arrow.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        // Draw a small filled triangle (arrow) at the bottom of the footer area, pointing downwards.
        // This visually indicates that there's content (like a sub-menu) below this footer.
        dc.fillPolygon(
            [[centerX, height - 10] as Array<Number>, [centerX + 5, height - 15] as Array<Number>, [centerX - 5, height - 15] as Array<Number>] as Array<Array<Number> >
        );
    }
}

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

        // Draw the title text "Back to Top", centered horizontally.
        // Position the text 2/3 down from the top of the title area.
        // Use a medium font and both horizontal and vertical centering.
        dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 3) * 2, Graphics.FONT_MEDIUM, "Back to Top", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Set the drawing color to white.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);

        // Draw a small, filled, upward-pointing triangle (arrow) at the top of the title area.
        // This serves as a visual indicator, suggesting a return to a previous menu or screen.
        dc.fillPolygon([[centerX, 10] as Array<Number>, [centerX + 5, 15] as Array<Number>, [centerX - 5, 15] as Array<Number>] as Array<Array<Number> >);
    }
}
