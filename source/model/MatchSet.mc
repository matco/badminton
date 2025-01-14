import Toybox.Lang;

class MatchSet {
	private var beginner as Player; //store the beginner of the set, YOU or OPPONENT
	private var rallies as List; //list of all rallies

	private var scores as Dictionary<Player, Number>; //dictionary containing players current scores
	private var winner as Player?; //store the winner of the match, ME or OPPONENT

	function initialize(player as Player) {
		beginner = player;
		rallies = new List();
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

	function score(scorer as Player) as Void {
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
			var rally = rallies.pop() as Player;
			var score = scores[rally] as Number;
			scores[rally] = score - 1;
		}
	}

	function getRalliesNumber() as Number {
		return rallies.size();
	}

	function getScore(player as Player) as Number {
		return scores[player] as Number;
	}

	function getServerTeam() as Player {
		//beginning of the match
		if(rallies.isEmpty()) {
			return beginner;
		}
		//last team who scores
		return rallies.last() as Player;
	}

	function getServingCorner() as Corner {
		var server = getServerTeam();
		var server_score = getScore(server);
		if(server == YOU) {
			return server_score % 2 == 0 ? YOU_RIGHT : YOU_LEFT;
		}
		return server_score % 2 == 0 ? OPPONENT_RIGHT : OPPONENT_LEFT;
	}

	//methods used from perspective of player 1 (watch carrier)
	function getPlayerTeamIsServer() as Boolean {
		return getServerTeam() == YOU;
	}
}
