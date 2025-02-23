import Toybox.Lang;

using Toybox.Application.Storage as Storage;

//* Constants
// TODO: Change these to use camelCase

function getZmanimErrorMessageCacheKey() {
    return "ZmanimErrorMessage";
}

function getGpsLocationCacheKey() {
    return "GPSLocation";
}

function getGpsStatusCacheKey() {
    return "GPSStatus";
}

function getPendingRefreshCacheKey() {
    return "PendingRefresh";
}

//* Methods

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
