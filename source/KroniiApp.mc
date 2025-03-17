import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class KroniiApp extends Application.AppBase {
	var fieldTypes = new [3];

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }
    
    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        onSettingsChanged();
        return [ new KroniiView() ];
    }

	function getIntProperty(key, defaultValue) {
		var value = getProperty(key);
		if (value == null) {
			value = defaultValue;
		} else if (!(value instanceof Number)) {
			value = value.toNumber();
		}
		return value;
	}

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        fieldTypes[0] = getIntProperty("Field0Type", 0);
		fieldTypes[1] = getIntProperty("Field1Type", 1);
		fieldTypes[2] = getIntProperty("Field2Type", -1);

        WatchUi.requestUpdate();
    }
}

function getApp() as KroniiApp {
    return Application.getApp() as KroniiApp;
}