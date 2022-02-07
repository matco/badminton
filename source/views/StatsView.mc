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
		var match = Application.getApp().getMatch();
		//retrieve stats from activity
		var activity = match.getActivity();
		var stats_available = false;

		var average_heart_rate = activity.averageHeartRate;
		if(average_heart_rate != null) {
			var text = Helpers.formatString(WatchUi.loadResource(Rez.Strings.stats_average_heart_rate), {"average_heart_rate" => average_heart_rate.toString()});
			findDrawableById("stats_average_heart_rate").setText(text);
			stats_available = true;
		}
		var max_heart_rate = activity.maxHeartRate;
		if(max_heart_rate != null) {
			var text = Helpers.formatString(WatchUi.loadResource(Rez.Strings.stats_max_heart_rate), {"max_heart_rate" => max_heart_rate.toString()});
			findDrawableById("stats_max_heart_rate").setText(text);
			stats_available = true;
		}
		var elapsed_distance = activity.elapsedDistance;
		if(elapsed_distance != null) {
			if(elapsed_distance > 0) {
				var text = Helpers.formatString(WatchUi.loadResource(Rez.Strings.stats_meters), {"meters" => elapsed_distance.format("%.0d")});
				findDrawableById("stats_meters").setText(text);
				stats_available = true;
			}
		}
		var calories = activity.calories;
		if(calories != null) {
			if(calories > 0) {
				var text = Helpers.formatString(WatchUi.loadResource(Rez.Strings.stats_calories), {"calories" => calories.format("%.0d")});
				findDrawableById("stats_calories").setText(text);
				stats_available = true;
			}
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
		var match = Application.getApp().getMatch();
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
