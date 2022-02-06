import Toybox.Lang;

class MatchSet {
	private var type; //type of the set, SINGLE or DOUBLE
	private var beginner as Player; //store the beginner of the set, YOU or OPPONENT
	private var server; //in double, true if the player 1 (watch carrier) is currently the server
	private var rallies as List; //list of all rallies

	private var scores as Dictionary<Player, Number>; //dictionnary containing players current scores
	private var winner as Player?; //store the winner of the match, ME or OPPONENT

	function initialize(match_type as MatchType, player as Player, set_server as Boolean) {
		type = match_type;
		beginner = player;
		server = set_server;
		rallies = new List();
		var rally = new MatchRally(player, set_server);
		rallies.push(rally);
		scores = {YOU => 0, OPPONENT => 0} as Dictionary<Player, Number>;
	}

	function end(player as Player) as Void {
		winner = player;
	}

	function hasEnded() as Boolean {
		return winner != null;
	}

	function getBeginner() as Player {
		return beginner;
	}

	function getWinner() as Player? {
		return winner;
	}

	function getRallies() as List {
		return rallies;
	}

	function nextRally() as Void {
		//last team who score serves next
		var last_winner = rallies.last().getWinner();
		var server = getPlayerIsServer();
		var rally = new MatchRally(last_winner, server);
		rallies.push(rally);
	}

	function score(scorer as Player) as Void {
		if(hasEnded()) {
			throw new OperationNotAllowedException("Unable to score in a set that has ended");
		}
		rallies.last().end(scorer);
		var score = scores[scorer] as Number;
		scores[scorer] = score + 1;
		nextRally();
	}

	function undo() as Void {
		if(rallies.size() > 1) {
			winner = null;
			rallies.pop();
			var last_rally = rallies.last() as MatchRally;
			scores[last_rally.getWinner()]--;
			last_rally.undo();
		}
	}

	function getCurrentRally() as MatchRally {
		return rallies.last();
	}

	function getRalliesNumber() as Number {
		//when asking for the number of rallies, the number of ended rallies must be returned
		var count = rallies.size() - 1;
		//the last rally is often pending (it has started but is not finished yet)
		if(rallies.last().hasEnded()) {
			count++;
		}
		return count;
	}

	function getScore(player as Player) as Number {
		return scores[player] as Number;
	}

	function getServerTeam() as Player {
		return rallies.last().getBeginner();
	}

	function getServingCorner() as Corner {
		var server = getServerTeam();
		var server_score = getScore(server);
		if(server == YOU) {
			return server_score % 2 == 0 ? YOU_RIGHT : YOU_LEFT;
		}
		return server_score % 2 == 0 ? OPPONENT_RIGHT : OPPONENT_LEFT;
	}

	function getPlayerIsServer() as Boolean {
		return getPlayerCorner() == getServingCorner();
	}

	//methods used from perspective of player 1 (watch carrier)
	function getPlayerTeamIsServer() as Boolean {
		return getServerTeam() == YOU;
	}

	function getPlayerCorner() as Corner {
		//in singles, the player 1 (watch carrier) position only depends on the current score
		if(type == SINGLE) {
			var server_team = getServerTeam();
			var server_score = getScore(server_team);
			return server_score % 2 == 0 ? YOU_RIGHT : YOU_LEFT;
		}
		//in doubles, it's not possible to give the position using only the current score
		//remember that the one who serves changes each time the team gains the service (winning a rally while not serving)
		var beginner = getBeginner();
		var rallies = getRallies();
		//initialize the corner differently depending on which team begins the set and which player starts to serve
		//while the player 1 team (watch carrier) did not get a service, the position of the player depends on who has been configured to serve first (among the player and his teammate)
		var corner = beginner == YOU ? server ? YOU_RIGHT : YOU_LEFT : server ? YOU_LEFT : YOU_RIGHT;
		var ended_rallies_number = getRalliesNumber();
		for(var i = 0; i < ended_rallies_number; i++) {
			var previous_rally_winner = i > 0 ? rallies.get(i - 1).getWinner() : beginner;
			var current_rally_winner = rallies.get(i).getWinner();
			if(previous_rally_winner == current_rally_winner && current_rally_winner == YOU) {
				corner = corner == YOU_RIGHT ? YOU_LEFT : YOU_RIGHT;
			}
		}
		return corner;
	}
}
