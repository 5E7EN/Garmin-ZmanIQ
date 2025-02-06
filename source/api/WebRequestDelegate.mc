import Toybox.Lang;

using Toybox.Communications as Comm;
using Toybox.Time;
using Toybox.Application.Storage;
using Toybox.WatchUi as Ui;
using Toybox.System;

typedef WebRequestCallbackData as Null or Dictionary or String;
typedef WebRequestCallback as (Method(responseCode as Number, data as WebRequestCallbackData) as Void);

typedef WebRequestDelegateCallbackData as WebRequestCallbackData or Array;
typedef WebRequestDelegateCallback as (Method(responseCode as Number, data as WebRequestDelegateCallbackData) as Void);

(:background)
function makeApiRequest(url as String, storageKey as String, callback as WebRequestDelegateCallback) {
    var delegate = new WebRequestDelegate(url, storageKey, callback);
    delegate.makeRequest();
}

(:background)
class WebRequestDelegate {
    private var _url as String;
    private var _storageKey as String;
    private var _callback as WebRequestDelegateCallback;

    function initialize(url as String, storageKey as String?, callback as WebRequestDelegateCallback) {
        _url = url;
        _storageKey = storageKey;
        _callback = callback;
    }

    function makeRequest() {
        $.log(Lang.format("[WebRequestDelegate] Fetching: $1$", [_url]));

        Comm.makeWebRequest(
            _url,
            null,
            {
                :method => Comm.HTTP_REQUEST_METHOD_GET
            },
            method(:onReceive)
        );
    }

    function onReceive(responseCode as Number, data as WebRequestCallbackData) as Void {
        if (responseCode == 200) {
            $.log(Lang.format("[WebRequestDelegate] 200 OK. Setting in storage with key: $1$", [_storageKey]));

            Storage.setValue(_storageKey, data);
        } else {
            $.log(Lang.format("[WebRequestDelegate] Request failed: $1$ ->\n$2$", [responseCode, data]));
        }

        _callback.invoke(responseCode, data as WebRequestDelegateCallbackData);
    }
}
