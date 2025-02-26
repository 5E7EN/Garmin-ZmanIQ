import Toybox.Lang;

using Toybox.Application.Storage as Storage;

//* Constants
// TODO: Change these to use camelCase

function getZmanimErrorMessageCacheKey() {
    return "ZmanimErrorMessage";
}

function getGpsStatusCacheKey() {
    return "GPSStatus";
}

function getGpsInfoCacheKey() {
    return "GPSInfo";
}

function getPendingRefreshCacheKey() {
    return "PendingRefresh";
}

//* Methods

//* These refresh-related methods are defined here since as of now I have no better place to put them.
function getPendingRefresh() as Boolean {
    var isPendingRefresh = Storage.getValue(getPendingRefreshCacheKey());

    if (isPendingRefresh == null || isPendingRefresh == false) {
        return false;
    }

    return true;
}

function setPendingRefresh(value as Boolean) {
    Storage.setValue(getPendingRefreshCacheKey(), value);
}
