using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.ActivityRecording as Recording;
using Toybox.Activity as Activity;
using Toybox.FitContributor as Contributor;
using Toybox.WatchUi as Ui;

class MatchSet {

	hidden var beginner; //store the beginner of the set, :player_1 or :player_2

	hidden var rallies; //list of all rallies

	hidden var scores; //dictionnary containing players current scores
	hidden var winner; //store the winner of the match, :player_1 or :player_2

	function initialize(player) {
		beginner = player;
		rallies = new List();
		scores = {:player_1 => 0, :player_2 => 0};
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
		if(server == :player_1) {
			return 3 - server_score % 2;
		}
		//player 2 serves from corner 0 or 1
		return server_score % 2;
	}

	//methods used from perspective of player 1 (watch carrier)
	hidden function getPlayerTeamIsServer() {
		return getServerTeam() == :player_1;
	}


}
