using Toybox.WatchUi;
using Toybox.Graphics;

class SaveMatchConfirmationDelegate extends WatchUi.ConfirmationDelegate {

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
		WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		WatchUi.switchToView(new InitialView(), new InitialViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}

class ResultView extends WatchUi.View {

	function initialize() {
		View.initialize();
	}

	function onLayout(dc) {
		setLayout(Rez.Layouts.result(dc));
	}

	function onShow() {
		//draw end of match text
		var winner = $.match.getWinner();
		var won_text = WatchUi.loadResource(winner == YOU ? Rez.Strings.end_you_won : Rez.Strings.end_opponent_won);
		findDrawableById("result_won_text").setText(won_text);
		//draw match score or last set score
		var score_text = $.match.getSetsWon(YOU).toString() + " - " + $.match.getSetsWon(OPPONENT).toString();
		findDrawableById("result_score").setText(score_text);
		//draw match time
		findDrawableById("result_time").setText(Helpers.formatDuration($.match.getDuration()));
		//draw rallies
		var rallies_text = WatchUi.loadResource(Rez.Strings.end_total_rallies);
		findDrawableById("result_rallies").setText(Helpers.formatString(rallies_text, {"rallies" => $.match.getTotalRalliesNumber().toString()}));
	}
}

class ResultViewDelegate extends WatchUi.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onSelect() {
		var save_match_confirmation = new WatchUi.Confirmation(WatchUi.loadResource(Rez.Strings.end_save_garmin_connect));
		WatchUi.pushView(save_match_confirmation, new SaveMatchConfirmationDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onBack() {
		WatchUi.switchToView(new SetResultView(), new SetResultViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onPreviousPage() {
		return onNextPage();
	}

	function onNextPage() {
		WatchUi.switchToView(new StatsView(), new StatsViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
