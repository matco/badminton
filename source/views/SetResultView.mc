using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class SetResultView extends Ui.View {

	function initialize() {
		View.initialize();
	}

	function onLayout(dc) {
		setLayout(Rez.Layouts.set_result(dc));
	}

	function onShow() {
		var set = $.match.getCurrentSet();
		//draw end of match text
		var set_winner = set.getWinner();
		var won_text = Ui.loadResource(set_winner == :player_1 ? Rez.Strings.set_end_you_won : Rez.Strings.set_end_opponent_won);
		findDrawableById("set_result_won_text").setText(won_text);
		//draw set score
		var score_text = set.getScore(:player_1).toString() + " - " + set.getScore(:player_2).toString();
		findDrawableById("set_result_score").setText(score_text);
		//draw rallies
		var rallies_text = Ui.loadResource(Rez.Strings.set_end_rallies);
		findDrawableById("set_result_rallies").setText(Helpers.formatString(rallies_text, {"rallies" => set.getRalliesNumber().toString()}));
	}
}

class SetResultViewDelegate extends Ui.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onBack() {
		//undo last point
		$.match.undo();
		Ui.switchToView(new MatchView(), new MatchViewDelegate(), Ui.SLIDE_IMMEDIATE);
		return true;
	}

	function onSelect() {
		if($.match.getWinner() == null) {
			$.match.nextSet();
			Ui.switchToView(new MatchView(), new MatchViewDelegate(), Ui.SLIDE_IMMEDIATE);
		}
		else {
			Ui.switchToView(new ResultView(), new ResultViewDelegate(), Ui.SLIDE_IMMEDIATE);
		}
		return true;
	}

	function onPreviousPage() {
		return onSelect();
	}

	function onNextPage() {
		return onSelect();
	}

}