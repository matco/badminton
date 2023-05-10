import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Attention;
using Toybox.Application;
using Toybox.Timer;

class BadmintonScoreTrackerApp extends Application.AppBase {
	//create bus for the whole application
	private const bus = new Bus();
	private var match as Match?;

	function initialize() {
		AppBase.initialize();
	}

	function onStart(state as Dictionary?) as Void {
		//register application itself in the bus
		bus.register(self);
	}

	function getInitialView() {
		return [new InitialView(), new InitialViewDelegate()] as Array<InputDelegate or View>;
	}

	function getBus() as Bus {
		return bus;
	}

	function getMatch() as Match {
		return match;
	}

	function setMatch(m as Match) as Void {
		match = m;
	}

	function onMatchBegin() as Void {
		if(Attention has :playTone) {
			if(Properties.getValue("enable_sound")) {
				Attention.playTone(Attention.TONE_START);
			}
		}
		if(Attention has :vibrate) {
			Attention.vibrate([new Attention.VibeProfile(80, 200)] as Array<VibeProfile>);
		}
	}

	function onMatchEnd(payload) as Void {
		var winner = payload["winner"];
		if(winner != null && Attention has :playTone && Properties.getValue("enable_sound")) {
			Attention.playTone(winner == YOU ? Attention.TONE_SUCCESS : Attention.TONE_FAILURE);
		}
		if(Attention has :vibrate) {
			Attention.vibrate([new Attention.VibeProfile(80, 200)] as Array<VibeProfile>);
		}
	}

	function onSettingsChanged() {
		//dispatch updated settings event
		//do not name the event "onSettingsChanged" to avoid recursion
		//"onSettingsChanged" is the native event and "onUpdateSettings" is the custom event for this app (that views can catch)
		bus.dispatch(new BusEvent(:onUpdateSettings, null));
	}
}
