using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Attention as Attention;
using Toybox.Timer as Timer;

var match;
var device = Sys.getDeviceSettings();

class BadmintonScoreTrackerApp extends App.AppBase {

	//! onStart() is called on application start up
	function onStart() {
		//test
		//Test.test();
	}

	//! onStop() is called when your application is exiting
	function onStop() {
	}

	//! Return the initial view of your application here
	function getInitialView() {
		var view = new TypeView();
		return [ view, new TypeViewDelegate(view) ];
	}

	function onMatchBegin() {
		if(getProperty("enable_sound")) {
			Attention.playTone(Attention.TONE_START);
		}
		Attention.vibrate([new Attention.VibeProfile(80, 200)]);
	}

	function onMatchEnd(winner) {
		if(getProperty("enable_sound")) {
			Attention.playTone(winner == :player_1 ? Attention.TONE_SUCCESS : Attention.TONE_FAILURE);
		}
		Attention.vibrate([new Attention.VibeProfile(80, 200)]);
	}
}
