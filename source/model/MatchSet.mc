class MatchSet {
	private var beginner; //store the beginner of the set, YOU or OPPONENT

	private var rallies; //list of all rallies

	private var scores; //dictionnary containing players current scores
	private var winner; //store the winner of the match, YOU or OPPONENT

	function initialize(player) {
		beginner = player;
		rallies = new List();
		scores = {YOU => 0, OPPONENT => 0};
	}

	function end(player) {
		winner = player;
	}

	function hasEnded() {
		return winner != null;
	}

	function getBeginner() {
		return beginner;
	}

	function getWinner() {
		return winner;
	}

	function getRallies() {
		return rallies;
	}

	function score(scorer) {
		if(!hasEnded()) {
			rallies.push(scorer);
			scores[scorer]++;
		}
	}

	function undo() {
		if(rallies.size() > 0) {
			winner = null;
			var rally = rallies.pop();
			scores[rally]--;
		}
	}

	function getRalliesNumber() {
		return rallies.size();
	}

	function getScore(player) {
		return scores[player];
	}

	function getServerTeam() {
		//beginning of the match
		if(rallies.isEmpty()) {
			return beginner;
		}
		//last team who scores
		return rallies.last();
	}

	function getServingCorner() {
		var server = getServerTeam();
		var server_score = getScore(server);
		if(server == YOU) {
			return server_score % 2 == 0 ? YOU_RIGHT : YOU_LEFT;
		}
		return server_score % 2 == 0 ? OPPONENT_RIGHT : OPPONENT_LEFT;
	}

	//methods used from perspective of player 1 (watch carrier)
	function getPlayerTeamIsServer() {
		return getServerTeam() == YOU;
	}
}
