import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//* This is the custom item drawable.
//* It draws the label it is initialized with at the center of the region
class CustomWrapItem extends WatchUi.CustomMenuItem {
    private var _label as String;
    private var _subLabel as String?;
    private var _textColor as ColorValue;

    //* Constructor
    //* @param id The identifier for this item
    //* @param label Text to display
    //* @param textColor Color of the text
    public function initialize(label as String, subLabel as String?, id as Symbol or String or Number, textColor as ColorValue) {
        CustomMenuItem.initialize(id, {});
        _label = label;
        _subLabel = subLabel;
        _textColor = textColor;
    }

    //* Draw the item string at the center of the item.
    //* @param dc Device Context
    public function draw(dc as Dc) as Void {
        var labelFont = Graphics.FONT_MEDIUM;
        var subLabelFont = Graphics.FONT_SMALL;
        var labelYOffset = 0;

        // Set the font size based on the selection state
        if (isFocused()) {
            labelFont = Graphics.FONT_LARGE;
            subLabelFont = Graphics.FONT_MEDIUM;
        }

        // Set the text color
        dc.setColor(_textColor, Graphics.COLOR_TRANSPARENT);

        // Draw sub-label, if any
        if (_subLabel != null) {
            // Calculate vertical positioning for label and sub-label
            var labelHeight = dc.getFontHeight(labelFont);
            var subLabelHeight = dc.getFontHeight(subLabelFont);
            var totalHeight = labelHeight + subLabelHeight;
            labelYOffset = (dc.getHeight() - totalHeight) / 2;

            // Draw sub-label
            dc.drawText(dc.getWidth() / 2, labelYOffset + labelHeight, subLabelFont, _subLabel, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            // Center the label if there's no sub-label
            labelYOffset = dc.getHeight() / 2;
        }

        // Draw label
        dc.drawText(dc.getWidth() / 2, labelYOffset, labelFont, _label, Graphics.TEXT_JUSTIFY_CENTER | (_subLabel == null ? Graphics.TEXT_JUSTIFY_VCENTER : 0));
    }
}
