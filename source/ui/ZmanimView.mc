import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;

class ZmanimView extends Ui.View {
    private var mTitle as String;
    public var mZmanim as Array<ZmanTime>;
    public var mSelectedIndex as Number;

    // --- Layout Constants ---
    private const LARGE_TITLE_HEIGHT = 60;
    private const ITEM_HEIGHT = 85;

    // Constants for the FOCUSED item
    private const FOCUSED_NAME_Y_OFFSET = 25;
    private const FOCUSED_TIME_Y_OFFSET = 60;
    private const FOCUSED_NAME_FONT = Gfx.FONT_MEDIUM;
    private const FOCUSED_TIME_FONT = Gfx.FONT_NUMBER_MEDIUM;

    // Constants for the UNFOCUSED (previous/next) items
    private const UNFOCUSED_NAME_Y_OFFSET = 30;
    private const UNFOCUSED_TIME_Y_OFFSET = 55;
    private const UNFOCUSED_NAME_FONT = Gfx.FONT_SMALL;
    private const UNFOCUSED_TIME_FONT = Gfx.FONT_SMALL;

    // General color constants
    private const TITLE_COLOR = Gfx.COLOR_BLUE;
    private const TEXT_COLOR = Gfx.COLOR_WHITE;
    private const ARROW_COLOR = Gfx.COLOR_LT_GRAY;

    function initialize(title as String, zmanim as Array<ZmanTime>, initialFocusIndex as Number) {
        View.initialize();
        mTitle = title;
        mZmanim = zmanim;
        mSelectedIndex = initialFocusIndex;
    }

    function onUpdate(dc as Gfx.Dc) as Void {
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();

        if (mZmanim.size() == 0) {
            dc.setColor(TEXT_COLOR, Gfx.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Gfx.FONT_MEDIUM, "No Zmanim", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
            return;
        }

        // --- Step 1: Always draw the list centered on the selected item ---
        var screenCenterY = dc.getHeight() / 2;
        var selectedItemTopY = screenCenterY - ITEM_HEIGHT / 2;

        // Use a full-screen clip to be safe
        dc.setClip(0, 0, dc.getWidth(), dc.getHeight());
        for (var i = 0; i < mZmanim.size(); i++) {
            var itemTopY = selectedItemTopY + (i - mSelectedIndex) * ITEM_HEIGHT;
            var isFocused = i == mSelectedIndex;
            drawZmanItem(dc, mZmanim[i], itemTopY, isFocused);
        }
        dc.clearClip();

        // --- Step 2: Draw overlays (Title and Arrows) based on state ---
        if (mSelectedIndex == 0) {
            // If at the top, draw the large title bar. This will draw OVER the list.
            // Draw a black rectangle first to obscure the list items underneath
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
            dc.fillRectangle(0, 0, dc.getWidth(), LARGE_TITLE_HEIGHT);

            // Draw the large title text
            dc.setColor(TITLE_COLOR, Gfx.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() / 2, LARGE_TITLE_HEIGHT / 2, Gfx.FONT_LARGE, mTitle, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);

            // Draw only the down arrow
            if (mZmanim.size() > 1) {
                drawDownArrow(dc);
            }
        } else {
            // If scrolled down, draw the arrows but no title
            drawUpArrow(dc);
            if (mSelectedIndex < mZmanim.size() - 1) {
                drawDownArrow(dc);
            }
        }
    }

    // Helper to draw a single Zman item
    private function drawZmanItem(dc as Gfx.Dc, zman as ZmanTime, itemTopY as Number, isFocused as Boolean) as Void {
        if (itemTopY > dc.getHeight() || itemTopY < -ITEM_HEIGHT) {
            return;
        }

        // Select fonts and offsets based on focus state
        var nameFont, timeFont, nameYOffset, timeYOffset;
        if (isFocused) {
            nameFont = FOCUSED_NAME_FONT;
            timeFont = FOCUSED_TIME_FONT;
            nameYOffset = FOCUSED_NAME_Y_OFFSET;
            timeYOffset = FOCUSED_TIME_Y_OFFSET;
        } else {
            nameFont = UNFOCUSED_NAME_FONT;
            timeFont = UNFOCUSED_TIME_FONT;
            nameYOffset = UNFOCUSED_NAME_Y_OFFSET;
            timeYOffset = UNFOCUSED_TIME_Y_OFFSET;
        }

        var name = $.ZmanMeta.ZmanimFriendlyNames[zman["name"]];
        var fullTimeString = zman["time"] == null ? "N/A" : $.parseMomentToTimeString(zman["time"]);

        var timeNumber = fullTimeString;
        var timeAmPm = "";
        var spaceIndex = fullTimeString.find(" ");
        if (spaceIndex != null) {
            timeNumber = fullTimeString.substring(0, spaceIndex);
            timeAmPm = fullTimeString.substring(spaceIndex + 1, fullTimeString.length());
        }

        var centerX = dc.getWidth() / 2;
        dc.setColor(TEXT_COLOR, Gfx.COLOR_TRANSPARENT);

        // Draw name using the selected font and offset
        dc.drawText(centerX, itemTopY + nameYOffset, nameFont, name, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);

        // Use the selected fonts for measurement and drawing
        var timeNumberWidth = dc.getTextWidthInPixels(timeNumber, timeFont);
        var amPmWidth = 0;
        if (timeAmPm.length() > 0) {
            amPmWidth = dc.getTextWidthInPixels(timeAmPm, nameFont) + 5;
        }
        var totalTimeWidth = timeNumberWidth + amPmWidth;
        var timeStartX = centerX - totalTimeWidth / 2;

        // 1. Draw the number part using the selected time font
        dc.drawText(timeStartX, itemTopY + timeYOffset, timeFont, timeNumber, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);

        // 2. Draw the AM/PM part using the selected name font
        if (timeAmPm.length() > 0) {
            dc.drawText(timeStartX + timeNumberWidth + 5, itemTopY + timeYOffset, nameFont, timeAmPm, Gfx.TEXT_JUSTIFY_LEFT | Gfx.TEXT_JUSTIFY_VCENTER);
        }
    }

    // Helper to draw the up arrow near the top of the screen
    private function drawUpArrow(dc as Gfx.Dc) as Void {
        dc.setColor(ARROW_COLOR, Gfx.COLOR_TRANSPARENT);
        var x = dc.getWidth() / 2;
        var y = 15;
        dc.fillPolygon([
            [x - 7, y + 5],
            [x + 7, y + 5],
            [x, y - 5]
        ]);
    }

    // Helper to draw the down arrow near the bottom of the screen
    private function drawDownArrow(dc as Gfx.Dc) as Void {
        dc.setColor(ARROW_COLOR, Gfx.COLOR_TRANSPARENT);
        var x = dc.getWidth() / 2;
        var y = dc.getHeight() - 15;
        dc.fillPolygon([
            [x - 7, y - 5],
            [x + 7, y - 5],
            [x, y + 5]
        ]);
    }
}

class ZmanimDelegate extends Ui.BehaviorDelegate {
    private var mView as ZmanimView;
    private var mLocationInfo as LocationInfo;
    private var mItemCount as Number;

    function initialize(view as ZmanimView, locationInfo as LocationInfo) {
        BehaviorDelegate.initialize();
        mView = view;
        mLocationInfo = locationInfo;
        mItemCount = view.mZmanim.size();
    }

    function onMenu() as Boolean {
        pushBottomZmanimMenu(mLocationInfo);
        return true; // Event handled
    }

    // Handle up/down buttons for scrolling
    function onKey(keyEvent as Ui.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        if (key == Ui.KEY_UP) {
            mView.mSelectedIndex--;
            if (mView.mSelectedIndex < 0) {
                mView.mSelectedIndex = mItemCount - 1; // Wrap around
            }
            Ui.requestUpdate();
            return true;
        } else if (key == Ui.KEY_DOWN) {
            mView.mSelectedIndex++;
            if (mView.mSelectedIndex >= mItemCount) {
                mView.mSelectedIndex = 0; // Wrap around
            }
            Ui.requestUpdate();
            return true;
        }
        return false; // Let system handle other keys
    }

    // Handle swipes for scrolling on touch devices
    function onSwipe(swipeEvent as Ui.SwipeEvent) as Boolean {
        var direction = swipeEvent.getDirection();
        if (direction == Ui.SWIPE_UP) {
            mView.mSelectedIndex++;
            if (mView.mSelectedIndex >= mItemCount) {
                mView.mSelectedIndex = 0; // Wrap around
            }
            Ui.requestUpdate();
            return true;
        } else if (direction == Ui.SWIPE_DOWN) {
            mView.mSelectedIndex--;
            if (mView.mSelectedIndex < 0) {
                mView.mSelectedIndex = mItemCount - 1; // Wrap around
            }
            Ui.requestUpdate();
            return true;
        }
        return false;
    }

    //* Handle an item being selected
    function onSelect() as Boolean {
        //* This ID will come back as a string (the zman name)
        var id = mView.mZmanim[mView.mSelectedIndex]["name"];

        //* Specific zman was selected
        if (id != null) {
            // Get the zman name from the ID
            var zmanName = id as String;

            // Push the specific zman view
            $.pushSpecificZmanView(zmanName);
        } else {
            $.log("[onSelect] Specific zman was selected but ID is null");
        }
        return true;
    }

    //* Handle the back key being pressed
    public function onBack() as Boolean {
        //* If this is called, the app will just quit. No need for the line below really...
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
