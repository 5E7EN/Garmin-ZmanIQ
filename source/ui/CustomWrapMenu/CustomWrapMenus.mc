import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//* This is the top menu in the Wrap custom menu
class WrapTopMenu extends WatchUi.CustomMenu {
    //* Constructor
    //* @param itemHeight The pixel height of menu items rendered by this menu
    //* @param backgroundColor The color for the menu background
    public function initialize(itemHeight as Number, backgroundColor as ColorType) {
        CustomMenu.initialize(itemHeight, backgroundColor, {});
    }

    //* Draw the menu title
    //* @param dc Device Context
    public function drawTitle(dc as Dc) as Void {
        var centerX = dc.getWidth() / 2;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        dc.setPenWidth(3);
        dc.drawLine(0, dc.getHeight() - 2, dc.getWidth(), dc.getHeight() - 2);
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, (dc.getHeight() / 3) * 2, Graphics.FONT_MEDIUM, "Zmanim", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER); // centerX is already calculated.
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillPolygon([[centerX, 10] as Array<Number>, [centerX + 5, 15] as Array<Number>, [centerX - 5, 15] as Array<Number>] as Array<Array<Number> >);
    }

    //* Draw the menu footer
    //* @param dc Device Context
    public function drawFooter(dc as Dc) as Void {
        var height = dc.getHeight();
        var centerX = dc.getWidth() / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        dc.setPenWidth(3);
        dc.drawLine(0, 1, dc.getWidth(), 1);
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        // Load the bitmap
        var icon = WatchUi.loadResource($.Rez.Drawables.SettingsIcon) as WatchUi.BitmapResource;

        // Get the bitmap's dimensions
        var iconWidth = icon.getWidth();
        var iconHeight = icon.getHeight();

        // Calculate the top-left corner coordinates for centering
        var iconX = centerX - iconWidth / 2;
        var iconY = height / 3 - iconHeight / 2;

        // Draw settings icon
        dc.drawBitmap(iconX, iconY, WatchUi.loadResource($.Rez.Drawables.SettingsIcon));
        // dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 3) * 2, Graphics.FONT_MEDIUM, "Zmanim", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        // dc.drawText(dc.getWidth() / 2, dc.getHeight() / 3, Graphics.FONT_MEDIUM, "To Sub Menu", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillPolygon(
            [[centerX, height - 10] as Array<Number>, [centerX + 5, height - 15] as Array<Number>, [centerX - 5, height - 15] as Array<Number>] as Array<Array<Number> >
        );
    }
}

//* This is the sub-menu in the Wrap custom menu
class WrapBottomMenu extends WatchUi.CustomMenu {
    //* Constructor
    //* @param itemHeight The pixel height of menu items rendered by this menu
    //* @param backgroundColor The color for the menu background
    public function initialize(itemHeight as Number, backgroundColor as ColorType) {
        CustomMenu.initialize(itemHeight, backgroundColor, {});
    }

    //* Draw the menu title
    //* @param dc Device Context
    public function drawTitle(dc as Dc) as Void {
        var centerX = dc.getWidth() / 2;
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        dc.setPenWidth(3);
        dc.drawLine(0, dc.getHeight() - 2, dc.getWidth(), dc.getHeight() - 2);
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 3) * 2, Graphics.FONT_MEDIUM, "Zmanim", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillPolygon([[centerX, 10] as Array<Number>, [centerX + 5, 15] as Array<Number>, [centerX - 5, 15] as Array<Number>] as Array<Array<Number> >);
    }
}
