using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Activity as Activity;

class StatsView extends Ui.View {

	function onLayout(dc) {
		setLayout(Rez.Layouts.stats(dc));
	}

	function onShow(dc) {
		//retrieve stats from activity
		var activity = match.getActivity();

		if(activity.averageHeartRate != null) {
			var text = Helpers.formatString(Ui.loadResource(Rez.Strings.stats_average_heart_rate), {"average_heart_rate" => activity.averageHeartRate});
			findDrawableById("stats_average_heart_rate").setText(text);
		}
		if(activity.maxHeartRate != null) {
			var text = Helpers.formatString(Ui.loadResource(Rez.Strings.stats_max_heart_rate), {"max_heart_rate" => activity.maxHeartRate});
			findDrawableById("stats_max_heart_rate").setText(text);
		}
		if(activity.elapsedDistance != null) {
			var text = Helpers.formatString(Ui.loadResource(Rez.Strings.stats_meters), {"meters" => activity.elapsedDistance.format("%.0d")});
			findDrawableById("stats_meters").setText(text);
		}
		if(activity.calories != null) {
			var text = Helpers.formatString(Ui.loadResource(Rez.Strings.stats_calories), {"calories" => activity.calories});
			findDrawableById("stats_calories").setText(text);
		}
	}
}

class StatsViewDelegate extends Ui.BehaviorDelegate {

	function onBack() {
		//undo last point
		match.undo();
		Ui.switchToView(new MatchView(), new MatchViewDelegate(), Ui.SLIDE_IMMEDIATE);
		return true;
	}

	function onPreviousPage() {
		Ui.switchToView(new ResultView(), new ResultViewDelegate(), Ui.SLIDE_IMMEDIATE);
		return true;
	}

	function onNextPage() {
		return onPreviousPage();
	}
}