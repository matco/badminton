import Toybox.Lang;
import Toybox.Time;

class MatchRally {
	private var beginner as Player; //store the server team of the rally (YOU or OPPONENT)
	private var server as Boolean; //store the server player of the rally (true if the player is the server or false if the teammate is the server)

	private var winner as Player?; //store the winner of the match, YOU or OPPONENT

	private var beginning_time as Moment; //datetime of the beginning of the rally
	private var duration as Number?; //store duration of the rally (do not store the datetime of the end of the rally to reduce memory footprint)

	function initialize(player as Player, rally_server as Boolean) {
		beginner = player;
		server = rally_server;
		beginning_time = Time.now();
	}

	function getBeginner() as Player {
		return beginner;
	}

	function getPlayerIsServer() as Boolean {
		return server;
	}

	function end(player as Player) as Void {
		if(hasEnded()) {
			throw new OperationNotAllowedException("Unable to end a rally that has already ended");
		}
		winner = player;
		duration = Time.now().subtract(beginning_time).value();
	}

	function undo() as Void {
		winner = null;
		duration = null;
	}

	function getWinner() as Player? {
		return winner;
	}

	function hasEnded() as Boolean {
		return winner != null;
	}

	function getDuration() as Number? {
		return duration;
	}
}