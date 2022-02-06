import Toybox.Lang;
import Toybox.Time;

class MatchSet {
	private var type as MatchType; //type of the set, SINGLE or DOUBLE
	private var beginner as Team; //store the beginner of the set, USER or OPPONENT
	private var server as Boolean; //in double, true if the user is currently the server
	private var rallies as List; //list of all rallies

	private var scores as Dictionary<Team, Number>; //dictionary containing teams current scores
	private var winner as Team?; //store the winner of the match, USER or OPPONENT

	private var beginningTime as Moment; //datetime of the beginning of the set
	private var duration as Duration?; //store duration of the set (do not store the datetime of the end of the set to reduce memory footprint)

	function initialize(match_type as MatchType, team as Team, set_server as Boolean) {
		type = match_type;
		beginner = team;
		server = set_server;
		rallies = new List();
		var rally = new MatchRally(team, set_server);
		rallies.push(rally);
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

	function getCurrentRally() as MatchRally {
		return rallies.last() as MatchRally;
	}

	function nextRally() as Void {
		//last team who score serves next
		var last_winner = getCurrentRally().getWinner() as Team;
		var server = getUserIsServer();
		var rally = new MatchRally(last_winner, server);
		rallies.push(rally);
	}

	function score(scorer as Team) as Void {
		if(hasEnded()) {
			throw new OperationNotAllowedException("Unable to score in a set that has ended");
		}
		getCurrentRally().end(scorer);
		var score = scores[scorer] as Number;
		scores[scorer] = score + 1;
		nextRally();
	}

	function undo() as Void {
		if(rallies.size() > 1) {
			winner = null;
			rallies.pop();
			var last_rally = getCurrentRally();
			var last_winner = last_rally.getWinner() as Team;
			var score = scores[last_winner] as Number;
			scores[last_winner] = score - 1;
			last_rally.undo();
		}
	}

	function getRalliesNumber() as Number {
		//when asking for the number of rallies, the number of ended rallies must be returned
		var count = rallies.size() - 1;
		//the last rally is often pending (it has started but is not finished yet)
		if(getCurrentRally().hasEnded()) {
			count++;
		}
		return count;
	}

	function getScore(team as Team) as Number {
		return scores[team] as Number;
	}

	function getServerTeam() as Team {
		return getCurrentRally().getBeginner();
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

	function getUserIsServer() as Boolean {
		return getUserCorner() == getServingCorner();
	}

	function getUserCorner() as Corner {
		//in singles, the user position only depends on the current score
		if(type == SINGLE) {
			var server_team = getServerTeam();
			var server_score = getScore(server_team);
			return server_score % 2 == 0 ? USER_RIGHT : USER_LEFT;
		}
		//in doubles, it's not possible to give the position using only the current score
		//remember that the one who serves changes each time the team gains the service (winning a rally while not serving)
		var beginner = getBeginner();
		var rallies = getRallies();
		//initialize the corner differently depending on which team begins the set and which player starts to serve
		//while the user team did not get a service, the position of the user depends on who has been configured to serve first (among the user and his teammate)
		var corner = beginner == USER ? server ? USER_RIGHT : USER_LEFT : server ? USER_LEFT : USER_RIGHT;
		var ended_rallies_number = getRalliesNumber();
		for(var i = 0; i < ended_rallies_number; i++) {
			var previous_rally_winner = i > 0 ? (rallies.get(i - 1) as MatchRally).getWinner() : beginner;
			var current_rally_winner = (rallies.get(i) as MatchRally).getWinner();
			if(previous_rally_winner == current_rally_winner && current_rally_winner == USER) {
				corner = corner == USER_RIGHT ? USER_LEFT : USER_RIGHT;
			}
		}
		return corner;
	}
}
