using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Attention as Attention;
using Toybox.Timer as Timer;

var match;

class BadmintonScoreTrackerApp extends App.AppBase {

	//! onStart() is called on application start up
	function onStart(state) {
		Sys.println("on start " + state);
		match = new Match(); //new Match(state);
		match.listener = self;
		var timer = new Timer.Timer();
		timer.start(method(:redraw), 1000, true);
		//test
		//Test.test();
	}

	//! onStop() is called when your application is exiting
	function onStop(state) {
		//match.save(state);
		Sys.println("on stop " + state);
	}

	//! Return the initial view of your application here
	function getInitialView() {
		return [ new MainView(), new MainViewDelegate() ];
	}

	function redraw() {
		if(match.hasBegun()) {
			Ui.requestUpdate();
		}
	}

	function onMatchBegin() {
		Attention.playTone(Attention.TONE_START);
		Attention.vibrate([new Attention.VibeProfile(80, 200)]);
	}

	function onMatchEnd(winner) {
		Attention.playTone(winner == :player_1 ? Attention.TONE_SUCCESS : Attention.TONE_FAILURE);
		Attention.vibrate([new Attention.VibeProfile(80, 200)]);
	}
}
