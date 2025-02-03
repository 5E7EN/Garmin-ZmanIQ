import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

//* Delegate is not included here by default.
//* See an example implementation in `all-zmanim/Delegate.mc`

//* This is the custom item drawable.
//* It draws the label it is initialized with at the center of the region
class CustomItem extends WatchUi.CustomMenuItem {
    private var _label as String;

    //* Constructor
    //* @param id The identifier for this item
    //* @param text Text to display
    public function initialize(id as Symbol, text as String) {
        CustomMenuItem.initialize(id, {});
        _label = text;
    }

    //* Draw the item string at the center of the item.
    //* @param dc Device context
    public function draw(dc as Dc) as Void {
        var font = Graphics.FONT_SMALL;
        if (isFocused()) {
            font = Graphics.FONT_LARGE;
        }

        if (isSelected()) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
            dc.clear();
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            font,
            _label,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.drawLine(0, 0, dc.getWidth(), 0);
        dc.drawLine(0, dc.getHeight() - 1, dc.getWidth(), dc.getHeight() - 1);
    }

    //* Get the item label
    //* @return The label
    public function getLabel() as String {
        return _label;
    }
}

//* View to show when an item is selected
class CustomItemView extends WatchUi.View {
    private var _text as Text;

    //* Constructor
    //* @param text The item text
    public function initialize(text as String) {
        View.initialize();
        _text = new WatchUi.Text({
            :text => text,
            :color => Graphics.COLOR_BLACK,
            :backgroundColor => Graphics.COLOR_WHITE,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_CENTER,
            :justification => Graphics.TEXT_JUSTIFY_CENTER
        });
    }

    //* Update the view
    //* @param dc Device context
    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();
        _text.draw(dc);
    }
}
