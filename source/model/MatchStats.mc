import Toybox.Lang;
import Toybox.Time;

class MatchStats {
	public var averageRallyDuration as Duration;
	public var averageRallyDurationServing as Duration?;
	public var averageRallyDurationReceiving as Duration?;
	public var percentageWinningServing as Number?;
	public var percentageWinningReceiving as Number?;

	function initialize(
			average_rally_duration as Duration,
			average_rally_duration_serving as Duration?,
			average_rally_duration_receiving as Duration?,
			percentage_winning_serving as Number?,
			percentage_winning_receiving as Number?
	) {
		averageRallyDuration = average_rally_duration;
		averageRallyDurationServing = average_rally_duration_serving;
		averageRallyDurationReceiving = average_rally_duration_receiving;
		percentageWinningServing = percentage_winning_serving;
		percentageWinningReceiving = percentage_winning_receiving;
	}
}
