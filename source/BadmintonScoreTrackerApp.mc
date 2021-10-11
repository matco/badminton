using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Attention;
using Toybox.Timer;
using Toybox.System;

var bus;
var match;
var device = System.getDeviceSettings();

class BadmintonScoreTrackerApp extends Application.AppBase {

	function initialize() {
		AppBase.initialize();

		//create bus for the whole application
		$.bus = new Bus();
		$.bus.register(self);
	}

	function getInitialView() {
		var view = new InitialView();
		return [view, new InitialViewDelegate(view)];
	}

	function onMatchBegin() {
		if(Attention has :playTone) {
			if(getProperty("enable_sound")) {
				Attention.playTone(Attention.TONE_START);
			}
		}
		if(Attention has :vibrate) {
			Attention.vibrate([new Attention.VibeProfile(80, 200)]);
		}
	}

	function onMatchEnd(winner) {
		if(Attention has :playTone) {
			if(getProperty("enable_sound")) {
				Attention.playTone(winner == YOU ? Attention.TONE_SUCCESS : Attention.TONE_FAILURE);
			}
		}
		if(Attention has :vibrate) {
			Attention.vibrate([new Attention.VibeProfile(80, 200)]);
		}
	}

	function onSettingsChanged() {
		//dispatch updated settings event
		//do not name the event "onSettingsChanged" to avoid recursion
		//"onSettingsChanged" is the native event and "onUpdateSettings" is the custom event for this app (that views can catch)
		$.bus.dispatch(new BusEvent(:onUpdateSettings, null));
	}
}
