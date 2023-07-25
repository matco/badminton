import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Graphics;

class SetResultView extends WatchUi.View {

	function initialize() {
		View.initialize();
	}

	function onLayout(dc) {
		setLayout(Rez.Layouts.set_result(dc));
	}

	function onShow() {
		var match = (Application.getApp() as BadmintonApp).getMatch();
		var set = match.getCurrentSet();
		//draw end of match text
		var set_winner = set.getWinner();
		var won_text = WatchUi.loadResource(set_winner == YOU ? Rez.Strings.set_end_you_won : Rez.Strings.set_end_opponent_won) as String;
		(findDrawableById("set_result_won_text") as Text).setText(won_text);
		//draw set score
		var score_text = set.getScore(YOU).toString() + " - " + set.getScore(OPPONENT).toString();
		(findDrawableById("set_result_score") as Text).setText(score_text);
		//draw rallies
		var rallies_text = WatchUi.loadResource(Rez.Strings.set_end_rallies) as String;
		(findDrawableById("set_result_rallies") as Text).setText(Helpers.formatString(rallies_text, {"rallies" => set.getRalliesNumber().toString()}));
	}
}

class SetResultViewDelegate extends WatchUi.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onMenu() {
		var menu = new WatchUi.Menu2({:title => Rez.Strings.menu_title});
		menu.addItem(new WatchUi.MenuItem(Rez.Strings.menu_end_game, null, :menu_end_game, null));
		menu.addItem(new WatchUi.MenuItem(Rez.Strings.menu_reset_game, null, :menu_reset_game, null));

		WatchUi.pushView(menu, new MatchMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onBack() {
		var match = (Application.getApp() as BadmintonApp).getMatch();
		//undo last point
		match.undo();
		var view = new MatchView();
		WatchUi.switchToView(view, new MatchViewDelegate(view), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onSelect() as Boolean {
		var match = (Application.getApp() as BadmintonApp).getMatch();
		if(match.hasEnded()) {
			WatchUi.switchToView(new ResultView(), new ResultViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		}
		else {
			match.nextSet();
			var view = new MatchView();
			WatchUi.switchToView(view, new MatchViewDelegate(view), WatchUi.SLIDE_IMMEDIATE);
		}
		return true;
	}
}
