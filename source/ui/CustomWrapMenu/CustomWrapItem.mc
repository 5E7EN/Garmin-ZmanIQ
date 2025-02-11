import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//* This is the custom item drawable.
//* It draws the label it is initialized with at the center of the region
class CustomWrapItem extends WatchUi.CustomMenuItem {
    private var _label as String;
    private var _textColor as ColorValue;

    //* Constructor
    //* @param id The identifier for this item
    //* @param label Text to display
    //* @param textColor Color of the text
    public function initialize(label as String, id as Symbol, textColor as ColorValue) {
        CustomMenuItem.initialize(id, {});
        _label = label;
        _textColor = textColor;
    }

    //* Draw the item string at the center of the item.
    //* @param dc Device Context
    public function draw(dc as Dc) as Void {
        var font = Graphics.FONT_SMALL;
        if (isFocused()) {
            font = Graphics.FONT_LARGE;
        }

        if (isSelected()) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
            dc.clear();
        }

        dc.setColor(_textColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, font, _label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}
