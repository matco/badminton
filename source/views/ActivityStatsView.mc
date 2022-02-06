import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Activity;
using Toybox.Graphics;

class ActivityStatsView extends WatchUi.View {

	function initialize() {
		View.initialize();
	}

	function onLayout(dc) {
		setLayout(Rez.Layouts.activity_stats(dc));
	}

	function onShow() {
		//retrieve stats from activity
		var activity = Activity.getActivityInfo() as Info;
		var stats_available = false;

		var average_heart_rate = activity.averageHeartRate;
		if(average_heart_rate != null) {
			var text = Helpers.formatString(WatchUi.loadResource(Rez.Strings.stats_average_heart_rate) as String, {"average_heart_rate" => average_heart_rate.toString()});
			(findDrawableById("stats_average_heart_rate") as Text).setText(text);
			stats_available = true;
		}
		var max_heart_rate = activity.maxHeartRate;
		if(max_heart_rate != null) {
			var text = Helpers.formatString(WatchUi.loadResource(Rez.Strings.stats_max_heart_rate) as String, {"max_heart_rate" => max_heart_rate.toString()});
			(findDrawableById("stats_max_heart_rate") as Text).setText(text);
			stats_available = true;
		}
		var elapsed_distance = activity.elapsedDistance;
		if(elapsed_distance != null) {
			if(elapsed_distance > 0) {
				var text = Helpers.formatString(WatchUi.loadResource(Rez.Strings.stats_meters) as String, {"meters" => elapsed_distance.format("%.0d")});
				(findDrawableById("stats_meters") as Text).setText(text);
				stats_available = true;
			}
		}
		var calories = activity.calories;
		if(calories != null) {
			if(calories > 0) {
				var text = Helpers.formatString(WatchUi.loadResource(Rez.Strings.stats_calories) as String, {"calories" => calories.format("%.0d")});
				(findDrawableById("stats_calories") as Text).setText(text);
				stats_available = true;
			}
		}
		//display a message of there is no stat to display
		if(!stats_available) {
			(findDrawableById("stats_no_stats") as Text).setText(WatchUi.loadResource(Rez.Strings.stats_no_stats) as String);
		}
	}
}

class ActivityStatsViewDelegate extends WatchUi.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onBack() {
		return onPreviousPage();
	}

	function onPreviousPage() as Boolean {
		WatchUi.switchToView(new MatchStatsView(), new MatchStatsViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onNextPage() {
		WatchUi.switchToView(new ResultView(), new ResultViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
