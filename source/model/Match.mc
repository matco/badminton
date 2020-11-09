using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.ActivityRecording as Recording;
using Toybox.Activity as Activity;
using Toybox.FitContributor as Contributor;
using Toybox.WatchUi as Ui;

class Match {

	const TOTAL_SCORE_PLAYER_1_FIELD_ID = 0;
	const TOTAL_SCORE_PLAYER_2_FIELD_ID = 1;
	const SET_WON_PLAYER_1_FIELD_ID = 2;
	const SET_WON_PLAYER_2_FIELD_ID = 3;
	const SET_SCORE_PLAYER_1_FIELD_ID = 4;
	const SET_SCORE_PLAYER_2_FIELD_ID = 5;

	hidden var type; //type of the match, :single or :double
	hidden var sets; //array of all sets containing -1 for a set not played

	hidden var server; //in double, true if the player 1 (watch carrier) is currently the server
	hidden var winner; //store the winner of the match, :player_1 or :player_2

	hidden var maximum_points;
	hidden var absolute_maximum_points;

	hidden var session;
	hidden var session_field_set_player_1;
	hidden var session_field_set_player_2;
	hidden var session_field_set_score_player_1;
	hidden var session_field_set_score_player_2;
	hidden var session_field_score_player_1;
	hidden var session_field_score_player_2;

	function initialize(match_type, sets_number, match_beginner, mp, amp) {
		type = match_type;
		server = true;

		//prepare array of sets and create first set
		sets = new [sets_number];
		sets[0] = new MatchSet(match_beginner);
		for(var i = 1; i < sets_number; i++) {
			sets[i] = -1;
		}

		maximum_points = mp;
		absolute_maximum_points = amp;

		//manage activity session
		session = Recording.createSession({:sport => Recording.SPORT_GENERIC, :subSport => Recording.SUB_SPORT_MATCH, :name => Ui.loadResource(Rez.Strings.fit_activity_name)});
		session_field_set_player_1 = session.createField("set_player_1", SET_WON_PLAYER_1_FIELD_ID, Contributor.DATA_TYPE_SINT8, {:mesgType => Contributor.MESG_TYPE_SESSION, :units => Ui.loadResource(Rez.Strings.fit_set_unit_label)});
		session_field_set_player_2 = session.createField("set_player_2", SET_WON_PLAYER_2_FIELD_ID, Contributor.DATA_TYPE_SINT8, {:mesgType => Contributor.MESG_TYPE_SESSION, :units => Ui.loadResource(Rez.Strings.fit_set_unit_label)});
		session_field_score_player_1 = session.createField("score_player_1", TOTAL_SCORE_PLAYER_1_FIELD_ID, Contributor.DATA_TYPE_SINT8, {:mesgType => Contributor.MESG_TYPE_SESSION, :units => Ui.loadResource(Rez.Strings.fit_score_unit_label)});
		session_field_score_player_2 = session.createField("score_player_2", TOTAL_SCORE_PLAYER_2_FIELD_ID, Contributor.DATA_TYPE_SINT8, {:mesgType => Contributor.MESG_TYPE_SESSION, :units => Ui.loadResource(Rez.Strings.fit_score_unit_label)});
		session_field_set_score_player_1 = session.createField("set_score_player_1", SET_SCORE_PLAYER_1_FIELD_ID, Contributor.DATA_TYPE_SINT8, {:mesgType => Contributor.MESG_TYPE_LAP, :units => Ui.loadResource(Rez.Strings.fit_score_unit_label)});
		session_field_set_score_player_2 = session.createField("set_score_player_2", SET_SCORE_PLAYER_2_FIELD_ID, Contributor.DATA_TYPE_SINT8, {:mesgType => Contributor.MESG_TYPE_LAP, :units => Ui.loadResource(Rez.Strings.fit_score_unit_label)});
		session.start();

		$.bus.dispatch(new BusEvent(:onMatchBegin, null));
	}

	function save() {
		//session can only be save once
		session.save();
	}

	function discard() {
		session.discard();
	}

	hidden function end(winner_player) {
		winner = winner_player;

		$.bus.dispatch(new BusEvent(:onMatchEnd, winner));
	}

	function nextSet() {
		//manage activity session
		session.addLap();

		//alternate beginner
		var i = getCurrentSetIndex();
		var beginner = sets[i].getBeginner();
		if(beginner == :player_1) {
			beginner = :player_2;
		}
		else {
			beginner = :player_1;
		}

		//create next set
		sets[i +1] = new MatchSet(beginner);
	}

	function getSetsNumber() {
		return sets.size();
	}

	function getCurrentSetIndex() {
		var i = 0;
		while(i < sets.size() && sets[i] != -1) {
			i++;
		}
		return i - 1;
	}

	function getCurrentSet() {
		return sets[getCurrentSetIndex()];
	}

	function score(scorer) {
		if(!hasEnded()) {
			var set = getCurrentSet();
			var previous_rally = set.getRallies().last();
			set.score(scorer);

			//in double, change server if player 1 (watch carrier) team regains service
			if(type == :double) {
				if(previous_rally == :player_2 && scorer == :player_1) {
					server = !server;
				}
			}

			//detect if match has a set winner
			var set_winner = isSetWon(set);
			if(set_winner != null) {
				set.end(set_winner);

				//manage activity session
				session_field_set_score_player_1.setData(set.getScore(:player_1));
				session_field_set_score_player_2.setData(set.getScore(:player_2));

				var match_winner = isWon();
				if(match_winner != null) {
					end(match_winner);

					//manage activity session
					session_field_set_player_1.setData(getSetsWon(:player_1));
					session_field_set_player_2.setData(getSetsWon(:player_2));
					session_field_score_player_1.setData(getTotalScore(:player_1));
					session_field_score_player_2.setData(getTotalScore(:player_2));
					session.stop();
				}
			}
		}
	}

	hidden function isSetWon(set) {
		var scorePlayer1 = set.getScore(:player_1);
		var scorePlayer2 = set.getScore(:player_2);
		if(scorePlayer1 >= absolute_maximum_points || scorePlayer1 >= maximum_points && (scorePlayer1 - scorePlayer2) > 1) {
			return :player_1;
		}
		if(scorePlayer2 >= absolute_maximum_points || scorePlayer2 >= maximum_points && (scorePlayer2 - scorePlayer1) > 1) {
			return :player_2;
		}
		return null;
	}

	hidden function isWon() {
		var winning_sets = sets.size() / 2;
		var player_1_sets = getSetsWon(:player_1);
		if(player_1_sets > winning_sets) {
			return :player_1;
		}
		var player_2_sets = getSetsWon(:player_2);
		if(player_2_sets > winning_sets) {
			return :player_2;
		}
		return null;
	}

	function undo() {
		winner = null;

		var set = getCurrentSet();
		var undone_rally = set.getRallies().last();
		set.undo();

		//in double, change server if player 1 (watch carrier) team looses service
		if(type == :double) {
			if(undone_rally == :player_1 && set.getRallies().last() == :player_2) {
				server = !server;
			}
		}
	}

	function getActivity() {
		return Activity.getActivityInfo();
	}

	function getDuration() {
		var time = getActivity().elapsedTime;
		var seconds = time != null ? time / 1000 : 0;
		return new Time.Duration(seconds);
	}

	function getType() {
		return type;
	}

	function getSets() {
		return sets;
	}

	function hasEnded() {
		return winner != null;
	}

	function getTotalRalliesNumber() {
		var i = 0;
		var number = 0;
		while(i < sets.size() && sets[i] != -1) {
			number += sets[i].getRalliesNumber();
			i++;
		}
		return number;
	}

	function getTotalScore(player) {
		var score = 0;
		for(var i = 0; i <= getCurrentSetIndex(); i++) {
			score = score + sets[i].getScore(player);
		}
		return score;
	}

	function getSetsWon(player) {
		var won = 0;
		for(var i = 0; i <= getCurrentSetIndex(); i++) {
			if(sets[i].getWinner() == player) {
				won++;
			}
		}
		return won;
	}

	function getWinner() {
		return winner;
	}

	function getServerTeam() {
		return getCurrentSet().getServerTeam();
	}

	function getHighlightedCorner() {
		return getCurrentSet().getHighlightedCorner();
	}

	//methods used from perspective of player 1 (watch carrier)
	hidden function getPlayerTeamIsServer() {
		return getServerTeam() == :player_1;
	}

	function getPlayerCorner() {
		if(getPlayerTeamIsServer()) {
			var highlighted_corner = getHighlightedCorner();
			if(server) {
				return highlighted_corner;
			}
			//return other corner
			return highlighted_corner == 2 ? 3 : 2;
		}
		return null;
	}

}
