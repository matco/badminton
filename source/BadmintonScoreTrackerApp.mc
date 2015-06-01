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
		return [ new MainView(), new MainDelegate() ];
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

class MainDelegate extends Ui.BehaviorDelegate {

	function onMenu() {
		Ui.pushView(new Rez.Menus.MainMenu(), new MenuDelegate(), Ui.SLIDE_UP);
		return true;
	}

	function handleScore(player) {
		if(!match.hasEnded()) {
			if(!match.hasBegun()) {
				match.begin(player);
			}
			else {
				match.score(player);
			}
			Ui.requestUpdate();
		}
	}

	function onKey(key) {
		Sys.println("on key " + key.getKey());
		//random start
		if(key.getKey() == Ui.KEY_ENTER && !match.hasBegun()) {
			var beginner = Math.rand() % 2 == 0 ? :player_1 : :player_2;
			match.begin(beginner);
			Ui.requestUpdate();
			return true;
		}
		return false;
	}

	//player 2 (opponent) scores
	function onNextPage() {
		Sys.println("on next page");
		handleScore(:player_1);
		return true;
	}

	//player 1 (watch carrier) scores
	function onPreviousPage() {
		Sys.println("on previous page");
		handleScore(:player_2);
		return true;
	}

	//undo last point
	function onBack() {
		Sys.println("on back");
		if(match.hasBegun()) {
			match.undo();
			Ui.requestUpdate();
			return true;
		}
		return false;
	}

}
