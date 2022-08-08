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

	function getPlayerIsServer(type, player_server) {
		//if the opponent team is serving, the player 1 (watch carrier) is necessary not the server
		if(!getPlayerTeamIsServer()) {
			return false;
		}
		//starting from here, we are sure it is the player 1 (watch carrier) team who serves
		//in singles, the player 1 (watch carrier) is necessary the server
		if(type == SINGLE) {
			return true;
		}
		//if this is the beginning of the set, the server is the one who has been configured to serve first (among the player and his teammate)
		if(rallies.isEmpty()) {
			return player_server;
		}
		//remember that the one who serves changes each time the team gains the service (winning a rally while not serving)
		//initialize the server differently depending on which team begins the set
		//that's because if the opponent team begins the set, the first time the watch carrier team gains the service, it must not induce a switch of the server
		//the idea is to inverse the server to counteract this switch in the following loop (this will happen only once)
		var server = beginner == YOU ? player_server : !player_server;
		for(var i = 0; i < rallies.size(); i++) {
			var previous_rally = i > 0 ? rallies.get(i - 1) : beginner;
			var current_rally = rallies.get(i);
			if(previous_rally == OPPONENT && current_rally == YOU) {
				server = !server;
			}
		}
		return server;
	}
}
