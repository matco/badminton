using Toybox.WatchUi;
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
		var match = Application.getApp().getMatch();
		var stats = match.getStats();

		var average_rally_duration_text = Helpers.formatString(
			WatchUi.loadResource(Rez.Strings.stats_average_rally_duration),
			{"average_rally_duration" => stats.averageRallyDuration.toString()}
		);
		findDrawableById("stats_average_rally_duration").setText(average_rally_duration_text);

		if(stats.percentageWinningServing != null) {
			var text = Helpers.formatString(
				WatchUi.loadResource(Rez.Strings.stats_percentage_winning_serving_rally),
				{"percentage_winning_serving_rally" => stats.percentageWinningServing.toString()}
			);
			findDrawableById("stats_percentage_winning_serving").setText(text);
		}

		if(stats.percentageWinningReceiving != null) {
			var text = Helpers.formatString(
				WatchUi.loadResource(Rez.Strings.stats_percentage_winning_receiving_rally),
				{"percentage_winning_receiving_rally" => stats.percentageWinningReceiving.toString()}
			);
			findDrawableById("stats_percentage_winning_receiving").setText(text);
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

	function onPreviousPage() {
		WatchUi.switchToView(new ResultView(), new ResultViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}

	function onNextPage() {
		WatchUi.switchToView(new ActivityStatsView(), new ActivityStatsViewDelegate(), WatchUi.SLIDE_IMMEDIATE);
		return true;
	}
}
