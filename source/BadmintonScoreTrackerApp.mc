using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Attention as Attention;
using Toybox.Timer as Timer;

var bus;
var match;
var device = Sys.getDeviceSettings();

class BadmintonScoreTrackerApp extends App.AppBase {

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
				Attention.playTone(winner == :player_1 ? Attention.TONE_SUCCESS : Attention.TONE_FAILURE);
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
