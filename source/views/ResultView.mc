using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class SaveMatchConfirmationDelegate extends Ui.ConfirmationDelegate {

	function initialize() {
		ConfirmationDelegate.initialize();
	}

	function onResponse(value) {
		if(value == CONFIRM_YES) {
			$.match.save();
		}
		else {
			$.match.discard();
		}
		//remove confirmation from view stack before going to back to type screen
		Ui.popView(Ui.SLIDE_IMMEDIATE);
		var view = new InitialView();
		Ui.switchToView(view, new InitialViewDelegate(view), Ui.SLIDE_IMMEDIATE);
	}
}

class ResultView extends Ui.View {

	function initialize() {
		View.initialize();
	}

	function onLayout(dc) {
		setLayout(Rez.Layouts.result(dc));
	}

	function onShow() {
		//draw end of match text
		var winner = $.match.getWinner();
		var won_text = Ui.loadResource(winner == YOU ? Rez.Strings.end_you_won : Rez.Strings.end_opponent_won);
		findDrawableById("result_won_text").setText(won_text);
		//draw match score or last set score
		var score_text = $.match.getSetsWon(YOU).toString() + " - " + $.match.getSetsWon(OPPONENT).toString();
		findDrawableById("result_score").setText(score_text);
		//draw match time
		findDrawableById("result_time").setText(Helpers.formatDuration($.match.getDuration()));
		//draw rallies
		var rallies_text = Ui.loadResource(Rez.Strings.end_total_rallies);
		findDrawableById("result_rallies").setText(Helpers.formatString(rallies_text, {"rallies" => $.match.getTotalRalliesNumber().toString()}));
	}
}

class ResultViewDelegate extends Ui.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onSelect() {
		var save_match_confirmation = new Ui.Confirmation(Ui.loadResource(Rez.Strings.end_save_garmin_connect));
		Ui.pushView(save_match_confirmation, new SaveMatchConfirmationDelegate(), Ui.SLIDE_IMMEDIATE);
		return true;
	}

	function onBack() {
		Ui.switchToView(new SetResultView(), new SetResultViewDelegate(), Ui.SLIDE_IMMEDIATE);
		return true;
	}

	function onPreviousPage() {
		return onNextPage();
	}

	function onNextPage() {
		Ui.switchToView(new StatsView(), new StatsViewDelegate(), Ui.SLIDE_IMMEDIATE);
		return true;
	}

}