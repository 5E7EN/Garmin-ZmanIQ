import Toybox.Graphics;
import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Application.Properties as Properties;
using Toybox.Application.Storage as Storage;

function pushSpecificZmanView(zmanName as String) as Void {
    // Get friendly zman name
    var friendlyName = $.ZmanimFriendlyNames[zmanName];
    if (friendlyName == null) {
        // Fallback to the key if no friendly name is found for some reason
        friendlyName = zmanName;
    }

    // Generate a new Menu
    var menu = new Ui.Menu2({ :title => Ui.loadResource(Rez.Strings.SpecificZmanMenuTitleStart) + "\n" + friendlyName });

    // Get reminder preference for current zman
    var remindBeforeTime = Properties.getValue("remindBeforeTime") as Number;
    var reminderEnabledZmanim = Storage.getValue($.getReminderEnabledZmanimCacheKey()) as Array<String>?;
    var isReminderEnabled = reminderEnabledZmanim != null && reminderEnabledZmanim.indexOf(zmanName) != -1;

    // Add menu items
    menu.addItem(
        new Ui.ToggleMenuItem(
            Ui.loadResource(Rez.Strings.SpecificZmanMenuEnableReminderText),
            // Subtext: "x minutes before zman"
            remindBeforeTime.toString() + " " + Ui.loadResource(Rez.Strings.SpecificZmanMenuEnableReminderSubTextEnd),
            :toggleReminder,
            isReminderEnabled,
            {
                :alignment => Ui.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT
            }
        )
    );

    Ui.pushView(menu, new $.SpecificZmanDelegate(zmanName), Ui.SLIDE_LEFT);
}
