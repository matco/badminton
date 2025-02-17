import Toybox.Lang;
import Toybox.Time;

class MatchSet {
	private var beginner as Team; //store the beginner of the set, USER or OPPONENT
	private var rallies as List; //list of all rallies

	private var scores as Dictionary<Team, Number>; //dictionary containing teams current scores
	private var winner as Team?; //store the winner of the match, USER or OPPONENT

	private var beginningTime as Moment; //datetime of the beginning of the set
	private var duration as Duration?; //store duration of the set (do not store the datetime of the end of the set to reduce memory footprint)

	function initialize(team as Team) {
		beginner = team;
		rallies = new List();
		scores = {USER => 0, OPPONENT => 0} as Dictionary<Team, Number>;
		beginningTime = Time.now();
	}

	function end(team as Team) as Void {
		winner = team;
		duration = Time.now().subtract(beginningTime) as Duration;
	}

	function hasEnded() as Boolean {
		return winner != null;
	}

	function getBeginner() as Team {
		return beginner;
	}

	function getWinner() as Team? {
		return winner;
	}

	function getRallies() as List {
		return rallies;
	}

	function getDuration() as Duration? {
		return duration;
	}

	function score(scorer as Team) as Void {
		if(hasEnded()) {
			throw new OperationNotAllowedException("Unable to score in a set that has ended");
		}
		rallies.push(scorer as Object);
		var score = scores[scorer] as Number;
		scores[scorer] = score + 1;
	}

	function undo() as Void {
		if(rallies.size() > 0) {
			winner = null;
			var rally = rallies.pop() as Team;
			var score = scores[rally] as Number;
			scores[rally] = score - 1;
		}
	}

	function getRalliesNumber() as Number {
		return rallies.size();
	}

	function getScore(team as Team) as Number {
		return scores[team] as Number;
	}

	function getServerTeam() as Team {
		//beginning of the match
		if(rallies.isEmpty()) {
			return beginner;
		}
		//last team who scores
		return rallies.last() as Team;
	}

	function getUserTeamIsServer() as Boolean {
		return getServerTeam() == USER;
	}

	function getServingCorner() as Corner {
		var server = getServerTeam();
		var server_score = getScore(server);
		if(server == USER) {
			return server_score % 2 == 0 ? USER_RIGHT : USER_LEFT;
		}
		return server_score % 2 == 0 ? OPPONENT_RIGHT : OPPONENT_LEFT;
	}
}
