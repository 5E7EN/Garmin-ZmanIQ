//* This delegate was mostly created by Gemini 2.5 Pro on Aug 18, 2025.
//* Some customizations were made by hand to stay consistent with the rest of the app.

import Toybox.Lang;
using Toybox.WatchUi as Ui;

class ZmanimListDelegate extends Ui.BehaviorDelegate {
    private var mView as ZmanimListView;
    private var mLocationInfo as LocationInfo;
    private var mItemCount as Number;

    function initialize(view as ZmanimListView, locationInfo as LocationInfo) {
        BehaviorDelegate.initialize();
        mView = view;
        mLocationInfo = locationInfo;
        mItemCount = view.mZmanim.size();
    }

    //* Handles the menu button being pressed.
    function onMenu() as Boolean {
        // Push the zmanim list menu view
        $.pushZmanimListMenuView(mLocationInfo);
        return true;
    }

    //* Handles up/down buttons for scrolling.
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

        // Let system handle other keys
        return false;
    }

    //* Handles swipes for scrolling on touch devices.
    function onSwipe(swipeEvent as Ui.SwipeEvent) as Boolean {
        var direction = swipeEvent.getDirection();
        if (direction == Ui.SWIPE_UP) {
            mView.mSelectedIndex++;
            if (mView.mSelectedIndex >= mItemCount) {
                // Wrap around
                mView.mSelectedIndex = 0;
            }
            Ui.requestUpdate();
            return true;
        } else if (direction == Ui.SWIPE_DOWN) {
            mView.mSelectedIndex--;
            if (mView.mSelectedIndex < 0) {
                // Wrap around
                mView.mSelectedIndex = mItemCount - 1;
            }
            Ui.requestUpdate();
            return true;
        }
        return false;
    }

    //* Handles a zman item being selected.
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

    //* Handles the back key being pressed.
    public function onBack() as Boolean {
        //* If this is called, the app will just quit. No need for the line below really...
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}
