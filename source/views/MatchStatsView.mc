import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Activity;

class MatchStatsView extends WatchUi.View {

	function initialize() {
		View.initialize();
	}

	function onLayout(dc) {
		setLayout(Rez.Layouts.match_stats(dc));
	}

	function onShow() {
		var match = Application.getApp().getMatch() as Match;
		var stats = match.calculateStats();

		var average_rally_duration_text = Helpers.formatString(
			WatchUi.loadResource(Rez.Strings.stats_average_rally_duration) as String,
			{"average_rally_duration" => stats.averageRallyDuration.toString()}
		);
		(findDrawableById("stats_average_rally_duration") as Text).setText(average_rally_duration_text);

		if(stats.percentageWinningServing != null) {
			var text = Helpers.formatString(
				WatchUi.loadResource(Rez.Strings.stats_percentage_winning_serving_rally) as String,
				{"percentage_winning_serving_rally" => (stats.percentageWinningServing as Number).toString()}
			);
			(findDrawableById("stats_percentage_winning_serving") as Text).setText(text);
		}

		if(stats.percentageWinningReceiving != null) {
			var text = Helpers.formatString(
				WatchUi.loadResource(Rez.Strings.stats_percentage_winning_receiving_rally) as String,
				{"percentage_winning_receiving_rally" => (stats.percentageWinningReceiving as Number).toString()}
			);
			(findDrawableById("stats_percentage_winning_receiving") as Text).setText(text);
		}
	}
}

class MatchStatsViewDelegate extends WatchUi.BehaviorDelegate {

	function initialize() {
		BehaviorDelegate.initialize();
	}

	function onBack() {
		return onPreviousPage();
	}

	function onPreviousPage() as Boolean {
		WatchUi.switchToView(new ResultView(), new ResultViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onNextPage() {
		WatchUi.switchToView(new ActivityStatsView(), new ActivityStatsViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
