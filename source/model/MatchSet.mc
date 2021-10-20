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
		//last team who score
		return rallies.last();
	}

	function getHighlightedCorner() {
		var server = getServerTeam();
		var server_score = getScore(server);
		//player 1 serves from corner 2 or 3
		if(server == YOU) {
			return 3 - server_score % 2;
		}
		//player 2 serves from corner 0 or 1
		return server_score % 2;
	}

	//methods used from perspective of player 1 (watch carrier)
	hidden function getPlayerTeamIsServer() {
		return getServerTeam() == YOU;
	}
}
