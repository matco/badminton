using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class ResultView extends Ui.View {

	//! Load your resources here
	function onLayout(dc) {
		setLayout(Rez.Layouts.result(dc));
	}

	//! Restore the state of the app and prepare the view to be shown
	function onShow() {
	}

	//! Called when this View is removed from the screen. Save the
	//! state of your app here.
	function onHide() {
	}

	//! Update the view
	function onUpdate(dc) {
		View.onUpdate(dc);
		//draw end of match text
		var winner = match.getWinner();
		var won_text = Ui.loadResource(winner == :player_1 ? Rez.Strings.end_you_won : Rez.Strings.end_opponent_won);
		findDrawableById("result_won_text").setText(won_text);
		//draw score
		findDrawableById("result_score").setText(match.getScore(:player_1).toString() + " - " + match.getScore(:player_2).toString());
		//draw match time
		findDrawableById("result_time").setText(Helpers.formatDuration(match.getDuration()));
		//draw rallies
		var rallies_text = Ui.loadResource(Rez.Strings.end_total_rallies);
		findDrawableById("result_rallies").setText(Helpers.formatString(rallies_text, {"rallies" => match.getRalliesNumber().toString()}));
	}
}

class ResultViewDelegate extends Ui.BehaviorDelegate {

	function onKey(key) {
		if(key.getKey() == Ui.KEY_ENTER) {
			//return to type screen
			var view = new TypeView();
			Ui.pushView(view, new TypeViewDelegate(view), Ui.SLIDE_IMMEDIATE);
			return true;
		}
		return false;
	}

	function onBack() {
		//undo last point
		match.undo();
		//let default behavior happen, back to previous view
		return false;
	}

}