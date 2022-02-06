import Toybox.Lang;
import Toybox.Time;

class MatchRally {
	private var beginner as Team; //store the server team of the rally (USER or OPPONENT)
	private var server as Boolean; //store the server player of the rally (true if the player is the server or false if the teammate is the server)

	private var winner as Team?; //store the winner of the match, USER or OPPONENT

	private var beginningTime as Moment; //datetime of the beginning of the rally
	private var duration as Duration?; //store duration of the rally (do not store the datetime of the end of the rally to reduce memory footprint)

	function initialize(team as Team, rally_server as Boolean) {
		beginner = team;
		server = rally_server;
		beginningTime = Time.now();
	}

	function getBeginner() as Team {
		return beginner;
	}

	function getUserIsServer() as Boolean {
		return server;
	}

	function end(team as Team) as Void {
		if(hasEnded()) {
			throw new OperationNotAllowedException("Unable to end a rally that has already ended");
		}
		winner = team;
		duration = Time.now().subtract(beginningTime) as Duration;
	}

	function undo() as Void {
		winner = null;
		duration = null;
	}

	function getWinner() as Team? {
		return winner;
	}

	function hasEnded() as Boolean {
		return winner != null;
	}

	function getDuration() as Duration? {
		return duration;
	}
}
