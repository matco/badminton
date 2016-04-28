using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Math as Math;

class BeginnerView extends Ui.View {

	function onLayout(dc) {
		setLayout(Rez.Layouts.beginner(dc));
	}
}

class BeginnerViewDelegate extends Ui.BehaviorDelegate {

	hidden var view;

	function initialize(view) {
		self.view = view;
	}

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
		var view = new TypeView();
		Ui.switchToView(view, new TypeViewDelegate(view), Ui.SLIDE_IMMEDIATE);
		return true;
	}

	function onTap(event) {
		var random = view.findDrawableById("beginner_random");
		var opponent = view.findDrawableById("beginner_opponent");
		var you = view.findDrawableById("beginner_you");
		var tapped = UIHelpers.findTappedDrawable(event, [random, opponent, you]);
		if("beginner_opponent".equals(tapped.identifier)) {
			manageChoice(:player_2);
		}
		else if("beginner_you".equals(tapped.identifier)) {
			manageChoice(:player_1);
		}
		else {
			manageRandomChoice();
		}
		return true;
	}
}