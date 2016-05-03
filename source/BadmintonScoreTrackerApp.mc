using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Attention as Attention;
using Toybox.Timer as Timer;

var match;
var device = Sys.getDeviceSettings();

class BadmintonScoreTrackerApp extends App.AppBase {

	/*function onStart() {
		//test
		Test.test();
	}*/

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
