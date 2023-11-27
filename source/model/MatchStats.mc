import Toybox.Lang;

class MatchStats {
	public var averageRallyDuration as Number;
	public var averageRallyDurationServing as Number?;
	public var averageRallyDurationReceiving as Number?;
	public var percentageWinningServing as Number?;
	public var percentageWinningReceiving as Number?;

	function initialize(
			average_rally_duration as Number,
			average_rally_duration_serving as Number?,
			average_rally_duration_receiving as Number?,
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