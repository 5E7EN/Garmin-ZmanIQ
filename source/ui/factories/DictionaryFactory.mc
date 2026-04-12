//* Adapted from [connectiq-app-glidersk](https://github.com/cedric-dufour/connectiq-app-glidersk/blob/d050287eaab06e47ae7f2137258deb5bca598ede/source/generic/PickerFactoryDictionary.mc)

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class DictionaryFactory extends WatchUi.PickerFactory {
    private var mKeys as Array = [];
    private var mValues as Array = [];
    private var mFont as FontDefinition;

    function initialize(
        keys as Array,
        values as Array,
        options as
            {
                :font as FontDefinition,
                :format as String
            }
    ) {
        PickerFactory.initialize();

        mKeys = keys;
        mValues = values;

        // Set custom font; or use default
        var font = options.get(:font);
        if (font != null) {
            mFont = font;
        } else {
            mFont = Graphics.FONT_NUMBER_HOT;
        }
    }

    function getDrawable(index as Number, selected as Boolean) as Drawable? {
        var value = null;

        // Check if the value is within the valid range and exists
        if (mValues.size() < index || indexOfValue(mValues[index]) == -1) {
            $.log("[getDrawable] Warning: Value " + value + " doesn't exist in provided values. Invalid default?");

            // Set value to the first index
            value = mValues[0];
        }

        // Convert value to string (if it's already a string, great!)
        value = mValues[index].toString();

        return new WatchUi.Text({
            :text => value,
            :color => selected ? Graphics.COLOR_WHITE : Graphics.COLOR_DK_GRAY,
            :font => mFont,
            :locX => WatchUi.LAYOUT_HALIGN_CENTER,
            :locY => WatchUi.LAYOUT_VALIGN_CENTER
        });
    }

    function getValue(index as Number) as Object? {
        return mKeys[index] as Object?;
    }

    function getSize() as Number {
        return mKeys.size();
    }

    //* Utility Methods

    function indexOfKey(key as Object?) as Number {
        return mKeys.indexOf(key);
    }

    function indexOfValue(value as Object?) as Number {
        return mValues.indexOf(value);
    }
}
