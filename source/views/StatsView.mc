using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Activity;

class StatsView extends WatchUi.View {

	function initialize() {
		View.initialize();
	}

	function onLayout(dc) {
		setLayout(Rez.Layouts.stats(dc));
	}

	function onShow() {
		//retrieve stats from activity
		var activity = match.getActivity();
		var stats_available = false;

		if(activity.averageHeartRate != null) {
			var text = Helpers.formatString(WatchUi.loadResource(Rez.Strings.stats_average_heart_rate), {"average_heart_rate" => activity.averageHeartRate.toString()});
			findDrawableById("stats_average_heart_rate").setText(text);
			stats_available = true;
		}
		if(activity.maxHeartRate != null) {
			var text = Helpers.formatString(WatchUi.loadResource(Rez.Strings.stats_max_heart_rate), {"max_heart_rate" => activity.maxHeartRate.toString()});
			findDrawableById("stats_max_heart_rate").setText(text);
			stats_available = true;
		}
		if(activity.elapsedDistance != null && activity.elapsedDistance > 0) {
			var text = Helpers.formatString(WatchUi.loadResource(Rez.Strings.stats_meters), {"meters" => activity.elapsedDistance.format("%.0d")});
			findDrawableById("stats_meters").setText(text);
			stats_available = true;
		}
		if(activity.calories != null && activity.calories > 0) {
			var text = Helpers.formatString(WatchUi.loadResource(Rez.Strings.stats_calories), {"calories" => activity.calories});
			findDrawableById("stats_calories").setText(text);
			stats_available = true;
		}
		//display a message of there is no stat to display
		if(!stats_available) {
			findDrawableById("stats_no_stats").setText(WatchUi.loadResource(Rez.Strings.stats_no_stats));
		}
	}
}

class StatsViewDelegate extends WatchUi.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onBack() {
		//undo last point
		match.undo();
		var view = new MatchView();
		WatchUi.switchToView(view, new MatchViewDelegate(view), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onPreviousPage() {
		WatchUi.switchToView(new ResultView(), new ResultViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onNextPage() {
		return onPreviousPage();
	}
}