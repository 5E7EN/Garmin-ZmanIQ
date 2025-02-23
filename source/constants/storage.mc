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

function getPendingRetryCacheKey() {
    return "PendingRetry";
}

//* Methods

function getPendingRetry() as Boolean {
    var isPendingRetry = Storage.getValue(getPendingRetryCacheKey());

    if (isPendingRetry == null || isPendingRetry == false) {
        return false;
    }

    return true;
}

function setPendingRetry(value as Boolean) {
    Storage.setValue(getPendingRetryCacheKey(), value);
}
