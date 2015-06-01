using Toybox.System as Sys;
using Toybox.Time as Time;

class Match {

	var MAXIMUM_POINTS = 21;

	hidden var strokes;

	hidden var beginner;
	hidden var scores;

	var startTime;
	var stopTime;

	var listener;

	function initialize(state) {
		reset();
		restore(state);
	}

	function restore(state) {
		if(state != null) {
			//strokes = state.get(:match_strokes);
			//beginner = state.get("match_beginner");
			//scores = state.get("match_scores");
		}
	}

	function save(state) {
		//state.put("match_strokes", strokes);
		//state.put("match_beginner", beginner);
		//state.put("match_scores", scores);
	}

	function begin(player) {
		beginner = player;
		startTime = Time.now();
		if(listener != null && listener has :onMatchBegin) {
			listener.onMatchBegin();
		}
	}

	hidden function end(winner) {
		stopTime = Time.now();
		if(listener != null && listener has :onMatchEnd) {
			listener.onMatchEnd(winner);
		}
	}

	function score(player) {
		if(hasBegun()) {
			strokes.push(player);
			scores[player]++;
			var winner = getWinner();
			if(winner != null) {
				end(winner);
			}
		}
	}

	function undo() {
		stopTime = null;
		if(strokes.size() > 0) {
			scores[strokes.pop()]--;
		}
		else {
			beginner = null;
		}
	}

	function reset() {
		strokes = new List();
		beginner = null;
		scores = {:player_1 => 0, :player_2 => 0};
		startTime = null;
		stopTime = null;
	}

	function getStrokesNumber() {
		return strokes.size();
	}

	function getDuration() {
		if(startTime == null) {
			return null;
		}
		var time = stopTime != null ? stopTime : Time.now();
		return time.subtract(startTime);
	}

	function hasBegun() {
		return beginner != null;
	}

	function hasEnded() {
		return getWinner() != null;
	}

	function getScore(player) {
		return scores[player];
	}

	function getWinner() {
		var scorePlayer1 = getScore(:player_1);
		var scorePlayer2 = getScore(:player_2);
		if(scorePlayer1 >= MAXIMUM_POINTS && (scorePlayer1 - scorePlayer2) > 1) {
			return :player_1;
		}
		if(scorePlayer2 >= MAXIMUM_POINTS && (scorePlayer2 - scorePlayer1) > 1) {
			return :player_2;
		}
		return null;
	}

	function getHighlightedCorner() {
		//beginning of the match
		if(strokes.isEmpty()) {
			return beginner == :player_1 ? 3 : 0;
		}
		//last score from player 1
		if(strokes.last() == :player_1) {
			return 3 - getScore(:player_1) % 2;
		}
		return getScore(:player_2) % 2;
	}
}
