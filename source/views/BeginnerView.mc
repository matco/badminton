using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Math as Math;

var random = null;
var opponent = null;
var you = null;

class BeginnerView extends Ui.View {

	//! Load your resources here
	function onLayout(dc) {
		setLayout(Rez.Layouts.beginner(dc));
	}

	//! Restore the state of the app and prepare the view to be shown
	function onShow() {
		random = findDrawableById("beginner_random");
		opponent = findDrawableById("beginner_opponent");
		you = findDrawableById("beginner_you");
	}

	function onHide() {
		random = null;
		opponent = null;
		you = null;
	}
}

class BeginnerViewDelegate extends Ui.BehaviorDelegate {

	function manageRandomChoice() {
		var beginner = Math.rand() % 2 == 0 ? :player_1 : :player_2;
		manageChoice(beginner);
	}

	function manageChoice(player) {
		match.begin(player);
		Ui.switchToView(new MatchView(), new MatchViewDelegate(), Ui.SLIDE_IMMEDIATE);
	}

	function onKey(key) {
		if(key.getKey() == Ui.KEY_ENTER) {
			//do not enable enter key on touch watches
			if(!device.isTouchScreen) {
				//begin match with random player
				manageRandomChoice();
				return true;
			}
		}
		return false;
	}

	function onNextPage() {
		//begin match with player 1 (watch carrier)
		manageChoice(:player_1);
		return true;
	}

	function onPreviousPage() {
		//begin match with player 2 (opponent)
		manageChoice(:player_2);
		return true;
	}

	function onBack() {
		//return to type screen
		Ui.switchToView(new TypeView(), new TypeViewDelegate(), Ui.SLIDE_IMMEDIATE);
		return true;
	}

	function onTap(event) {
		if (random == null || opponent == null || you == null) {
			return false;
		}

		var tapped = UIHelpers.findTappedDrawable(event, [random, opponent, you]);
		if(opponent.identifier == tapped.identifier) {
			manageChoice(:player_2);
		}
		else if(beginner.identifier == tapped.identifier) {
			manageChoice(:player_1);
		}
		else {
			manageRandomChoice();
		}
		return true;
	}

}
