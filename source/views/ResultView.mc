using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class ResultView extends Ui.View {

	function onLayout(dc) {
		setLayout(Rez.Layouts.result(dc));
	}

	function onShow() {
		//draw end of match text
		var winner = $.match.getWinner();
		var won_text = Ui.loadResource(winner == :player_1 ? Rez.Strings.end_you_won : Rez.Strings.end_opponent_won);
		findDrawableById("result_won_text").setText(won_text);
		//draw score
		findDrawableById("result_score").setText($.match.getScore(:player_1).toString() + " - " + $.match.getScore(:player_2).toString());
		//draw match time
		findDrawableById("result_time").setText(Helpers.formatDuration($.match.getDuration()));
		//draw rallies
		var rallies_text = Ui.loadResource(Rez.Strings.end_total_rallies);
		findDrawableById("result_rallies").setText(Helpers.formatString(rallies_text, {"rallies" => $.match.getRalliesNumber().toString()}));
	}
}

class ResultViewDelegate extends Ui.BehaviorDelegate {

	function onKey(key) {
		if(key.getKey() == Ui.KEY_ENTER) {
			//return to type screen
			var view = new TypeView();
			Ui.switchToView(view, new TypeViewDelegate(view), Ui.SLIDE_IMMEDIATE);
			return true;
		}
		return false;
	}

	function onBack() {
		//undo last point
		$.match.undo();
		Ui.switchToView(new MatchView(), new MatchViewDelegate(), Ui.SLIDE_IMMEDIATE);
		return true;
	}
}